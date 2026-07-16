# 03b. Install on Kubernetes (The Operator Familiar)

![The all-seeing eye, now watching a cluster](img/dtwiz-eye.png){ width="220" align=right }

`recommend` will happily suggest the **Kubernetes Operator** for a cluster.
This workshop *has* a cluster — a lightweight [k3d](https://k3d.io) one running
right inside your dev container — so let us conjure the operator into it.

## Cast the spell

```bash
dtwiz install kubernetes --yes
```

`install kubernetes` deploys the **Dynatrace Operator** plus a **DynaKube**
(the custom resource that tells the operator what to monitor): an ActiveGate,
the OpenTelemetry collector, and code injection for your pods.

## The k3d caveat — one familiar won't behave

By default the DynaKube also enables **KSPM** (Kubernetes Security Posture
Management). KSPM runs a `node-config-collector` DaemonSet that needs **real
node host access** — it mounts the host filesystem to run CIS/security
benchmarks. On k3d the "nodes" are *containers*, not real hosts, so that one
pod is stuck in `ContainerCreating` forever and dtwiz's own wait eventually
times out — even though the operator itself came up fine.

The fix on k3d is simply to **remove KSPM**: it is not what this lab teaches
and it cannot work here. Everything else (operator, ActiveGate, OTel collector,
code injection) stays fully functional.

```bash
patchDynakubeDisableKspm
```

!!! tip "The lab spell does both"
    `installDtwizKubernetes` runs `dtwiz install kubernetes --yes` **and** then
    `patchDynakubeDisableKspm` for you — one call, a clean k3d-ready cluster.

## Verify the cluster is k3d-clean

<!-- LAB_QUESTION
type: shell-verification
question: "Verify KSPM's stuck node-config-collector is gone (k3d-clean)"
buttonText: "Check the cluster"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isKspmDisabled"
expect:
  operator: exit-zero
hint: "Run `installDtwizKubernetes` (or `dtwiz install kubernetes --yes` then `patchDynakubeDisableKspm`) in the Terminal."
explanation: "No stuck node-config-collector — the operator is up and the cluster is k3d-clean."
-->

<!-- LAB_SOLUTION
commands:
  - installDtwizKubernetes
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isKspmDisabled
reveal: |
  ### The spell explained
  `installDtwizKubernetes` runs `dtwiz install kubernetes --yes` to deploy the
  Dynatrace Operator, then `patchDynakubeDisableKspm` removes the `kspm` block
  from every DynaKube so the operator drops the `node-config-collector`
  DaemonSet that cannot run on k3d's container "nodes". `isKspmDisabled`
  confirms no stuck collector remains (and is a safe no-op if there is no
  cluster or DynaKube).
-->

<!-- boundScenarioId: enablement-dtwiz-101-03b-install-kubernetes retake=false -->

<div class="grid cards" markdown>
- [Section 04: The Demo App & Watch](04-demo-and-watch.md)
</div>
