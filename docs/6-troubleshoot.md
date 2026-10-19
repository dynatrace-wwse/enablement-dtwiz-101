# 6. Troubleshoot

dtwiz reports most problems in one line. This step shows the messages you will meet on customer
systems, what each one means, and how to resolve the one this cluster has right now.

## Connection and authentication

Each command below changes one input for a single command only. Your real variables stay as
they are.

A token the tenant does not recognise:

```bash
DT_PLATFORM_TOKEN=dt0s16.EXAMPLE.invalid dtwiz status | grep 'Platform Token'
```

```text
Platform Token:  ✗ platform token: authentication failed: auth error: authentication_failed
```

A tenant URL that cannot be reached (a typo, a proxy, a firewall, no DNS):

```bash
DT_ENVIRONMENT=https://abc00000.apps.dynatrace.com dtwiz status | grep -E 'Environment|Platform Token'
```

```text
Platform Token:  ✗ platform token: environment not reachable (https://abc00000.apps.dynatrace.com): network error: environment_not_reachable (https://abc00000.apps.dynatrace.com)
```

A valid token without the scope of dtwiz's validation query (`storage:system:read`) gives a third
message, and every `dtwiz install` stops on it:

```text
Platform Token:  ✗ platform token: insufficient permissions: auth error: invalid_token
```

dtwiz checks only that one scope up front. Every other
missing scope surfaces later, at the call that needs it: as an error from that `install`, as an
empty section in `dtwiz watch`, or as an Operator that cannot fetch its connection info.

| Message | Cause | Resolution |
|---|---|---|
| `authentication failed` | token unknown, expired or revoked | create a new platform token |
| `insufficient permissions` | token valid, `storage:system:read` missing | add the scope, or use a token that has it |
| `environment not reachable` | URL, DNS, proxy or firewall | test `curl -sI "$DT_ENVIRONMENT"` from the same machine |
| `missing DT_ENVIRONMENT, DT_PLATFORM_TOKEN` | variables not exported in this shell | `export` them, or pass `--environment` / `--platform-token` |

<!-- LAB_QUESTION
type: multiple-choice
question: "dtwiz status shows ✓ valid, but dtwiz watch stays empty for logs. What is the most likely cause?"
options:
  - "The token lacks a read scope that watch's log query needs; status validates only storage:system:read"
  - "The tenant URL is wrong"
  - "The token has expired"
  - "dtwiz analyze has not been run"
correct: 0
explanation: "A ✓ proves the token and one scope. A wrong URL or an expired token would fail status itself. Missing read scopes make watch queries fail quietly, so the section stays empty."
-->

## No cluster context

dtwiz detects Kubernetes only through the current kubeconfig context. Point it at an empty
kubeconfig for one command:

```bash
KUBECONFIG=/dev/null dtwiz analyze | grep Kubernetes
```

```text
Kubernetes:  <none> — connect to a cluster with 'kubectl' to detect it
```

Without the context, `recommend` has no Kubernetes entry. `install kubernetes` does not stop:
it builds the DynaKube name from kubectl's error message (`error-current-context-m…`) and then
fails at Helm. On a customer system, run `kubectl config current-context` before anything else.

<!-- LAB_QUESTION
type: multiple-choice
question: "A customer has three clusters in one kubeconfig. Which one does dtwiz install kubernetes deploy to?"
options:
  - "The cluster of the current kubeconfig context"
  - "All three, one DynaKube each"
  - "The first cluster listed in the kubeconfig file"
  - "The one it asks for in an interactive prompt"
correct: 0
explanation: "dtwiz reads the current context (kubectl config view --minify). Switch with kubectl config use-context before installing."
-->

## A pod that never becomes Ready

Return to your cluster. The install from step 5 stopped waiting, so look at what it waited for:

```bash
kubectl get pods -n dynatrace
```

All pods are Running except `…-node-config-collector-…`, which stays in `ContainerCreating`. Ask
Kubernetes why:

```bash
kubectl get events -n dynatrace --field-selector reason=FailedMount | tail -3
```

```text
MountVolume.SetUp failed for volume "node-path-5" : hostPath type check failed: /sys/kernel/security/apparmor is not a directory
```

The node-config-collector belongs to **KSPM** (Kubernetes Security Posture Management). It runs
security benchmarks against each node's host file system and mounts host paths for that. dtwiz
enables KSPM on generic distributions, k3s included. A k3d "node" is a container, not a host,
and the path it needs does not exist, so the pod can never start. On a real k3s node it would.

KSPM is not part of this training. Remove it from the DynaKube: the Operator then deletes the
collector, and every other component keeps running:

```bash
kubectl -n dynatrace patch dynakube "$(dtwizClusterName)" --type=json -p='[{"op":"remove","path":"/spec/kspm"}]'
kubectl get pods -n dynatrace
```

The first check confirms the DynaKube no longer requests KSPM and no collector pod remains. It
fails until you apply the patch. Check it:

<!-- LAB_QUESTION
type: shell-verification
question: "Verify KSPM is removed from your DynaKube and no node-config-collector pod remains"
buttonText: "Check KSPM removed"
command: "checkKspmRemoved"
expect:
  operator: exit-zero
hint: "Run the kubectl patch command above. The collector pod takes a few seconds to go."
explanation: "The DynaKube no longer requests KSPM and the Operator removed the collector."
-->

The second check applies dtwiz's own success condition, on the cluster instead of in the install
log: every pod in `dynatrace` Ready, an ActiveGate among them. It fails while the collector
blocks. Check it:

<!-- LAB_QUESTION
type: shell-verification
question: "Verify every Dynatrace pod is Ready, ActiveGate included"
buttonText: "Check Dynatrace pods"
command: "checkDynatracePodsReady"
expect:
  operator: exit-zero
hint: "The ActiveGates take two to three minutes to become Ready after the install. Run kubectl get pods -n dynatrace and check again."
explanation: "The deployment dtwiz started is complete: Operator, ActiveGates and log module are Ready."
-->

<!-- LAB_SOLUTION
reveal: |
  The connection and context commands only print messages and change nothing. The cluster
  problem is the KSPM node-config-collector, which cannot mount host paths on a k3d node.
  Removing `spec.kspm` from the DynaKube makes the Operator delete it.
  `checkKspmRemoved` and `checkDynatracePodsReady` confirm the result.
commands:
  - DT_PLATFORM_TOKEN=dt0s16.EXAMPLE.invalid dtwiz status | grep 'Platform Token'
  - DT_ENVIRONMENT=https://abc00000.apps.dynatrace.com dtwiz status | grep -E 'Environment|Platform Token'
  - KUBECONFIG=/dev/null dtwiz analyze | grep Kubernetes
  - kubectl get pods -n dynatrace
  - kubectl get events -n dynatrace --field-selector reason=FailedMount | tail -3
  - kubectl -n dynatrace patch dynakube "$(dtwizClusterName)" --type=json -p='[{"op":"remove","path":"/spec/kspm"}]'
  - kubectl get pods -n dynatrace
verify:
  - LAB_WAIT=1 checkKspmRemoved
  - LAB_WAIT=1 checkDynatracePodsReady
-->
