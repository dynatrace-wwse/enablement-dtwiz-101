# 7. Analyze the cluster in Dynatrace

The Operator registered your cluster with the tenant through the Kubernetes-monitoring
ActiveGate, and the log module ships container logs to Grail. This step shows that data twice:
with `dtwiz watch`, which is built for exactly this moment after an install, and with DQL
assertions that prove it.

## Watch the data arrive

`dtwiz watch` polls the tenant every few seconds with DQL and shows what has arrived since a
point in time: Kubernetes entities, hosts, services, logs and requests. `--from` sets that point;
the install ran within the last half hour:

```bash
timeout 2m dtwiz watch --from "now()-30m"
```

`watch` runs until you press ++ctrl+c++; `timeout 2m` stops it on its own. Expect the
Kubernetes and log sections to fill. Services and requests stay empty, because no application
runs in this cluster yet.

## Prove it with DQL

`dtwiz watch` shows the whole tenant, which every learner shares. A check must see only your
cluster. The framework installs `dtctl` and connects it with a read token from your seat
(`DT_DTCTL_TOKEN`); `enableDtctl` makes sure that context exists and changes nothing when it
does:

```bash
enableDtctl
```

The two queries live in files, with the cluster name as a dtctl template variable. Look for your
cluster in the Smartscape topology, then read its newest log lines:

```bash
dtctl query -f queries/cluster-entity.dql --set cluster="$(dtwizClusterName)"
dtctl query -f queries/cluster-logs.dql --set cluster="$(dtwizClusterName)"
```

The same two queries, packaged as assertions in `my_functions.sh`:

```text
checkClusterInDynatrace [cluster]   smartscapeNodes K8S_CLUSTER | filter name == "<cluster>"
checkClusterLogs [cluster]          fetch logs, from:now()-15m | filter k8s.cluster.name == "<cluster>"
```

Both default to your cluster and pass only when a row comes back.

## Run a negative control

A filter that matches nothing is not an error in DQL: the query succeeds and returns zero rows.
An assertion you have never seen fail therefore proves nothing. Run one against a cluster that
does not exist:

```bash
checkClusterInDynatrace k3d-enablement-00000000; echo "exit=$?"
```

It prints `exit=1`. The query ran; it found no row, and the function turned that into a failure.

<!-- LAB_QUESTION
type: multiple-choice
question: "checkClusterInDynatrace k3d-enablement-00000000 exits 1 while checkClusterInDynatrace exits 0. What does that prove?"
options:
  - "The assertion really filters on the cluster name, so its pass is evidence of your cluster"
  - "dtctl is not configured"
  - "The DQL query has a syntax error"
  - "The other cluster was deleted"
correct: 0
explanation: "A filter that matches nothing returns zero rows without error. The function fails on zero rows, so the pass for your name comes from your cluster's own entity."
-->

The first check confirms the tenant knows your cluster. It fails before the Operator registers
it. Check it:

<!-- LAB_QUESTION
type: shell-verification
question: "Verify your Kubernetes cluster is in Dynatrace"
buttonText: "Check cluster in Dynatrace"
command: "checkClusterInDynatrace"
expect:
  operator: exit-zero
hint: "Registration takes a few minutes after the ActiveGate is Ready (step 6). Check again shortly."
explanation: "Your cluster is a Smartscape entity in the tenant: the Operator and ActiveGate report it."
-->

The second check confirms container logs from your cluster are in Grail. It fails until the log
module ships its first lines. Check it:

<!-- LAB_QUESTION
type: shell-verification
question: "Verify container logs from your cluster are in Grail"
buttonText: "Check cluster logs"
command: "checkClusterLogs"
expect:
  operator: exit-zero
hint: "The log module needs a few minutes after it becomes Ready. Check again shortly."
explanation: "Logs from your cluster are in Grail, filtered on its name."
-->

## In the Dynatrace UI

Open the Kubernetes app and search for your cluster's name (`dtwizClusterName`):

[dt-app|dynatrace.kubernetes|Open the Kubernetes app](placeholder)

<!-- LAB_SOLUTION
reveal: |
  `dtwiz watch` shows arriving data tenant-wide. `checkClusterInDynatrace` and
  `checkClusterLogs` scope the same signals to your cluster with dtctl, and fail on a cluster
  name that does not exist.
commands:
  - timeout 2m dtwiz watch --from "now()-30m"
  - enableDtctl
  - dtctl query -f queries/cluster-entity.dql --set cluster="$(dtwizClusterName)"
  - dtctl query -f queries/cluster-logs.dql --set cluster="$(dtwizClusterName)"
verify:
  - LAB_WAIT=1 checkClusterInDynatrace
  - LAB_WAIT=1 checkClusterLogs
-->
