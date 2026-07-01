# 01. Install Kubernetes (Conjure a Cluster)

![Wizard summoning a cluster out of thin air](img/dtwiz-conjure.png){ width="220" align=right }

No cluster exists yet. A real wizard makes their own. You will install a
lightweight Kubernetes distribution (**k3d** - Kubernetes in Docker) right here in
your workshop.

## Cast the spell

In the **Terminal** tab, run:

```bash
source .devcontainer/util/source_framework.sh
conjureCluster
```

`conjureCluster` starts a k3d cluster, wires up the ingress controller, and
installs `k9s` (a delightful terminal UI for Kubernetes). Give it ~30 seconds.

Then admire your handiwork:

```bash
kubectl get nodes
```

You should see one node with status `Ready`.

!!! tip "k9s: the crystal ball"
    Run `k9s` in the Terminal to watch pods live. Press `:` then type `pods`,
    and `0` to see all namespaces. Quit with `:q`.

## Verify the cluster is Ready

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the Kubernetes node is Ready"
buttonText: "Check the Cluster"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && waitForClusterReady"
expect:
  operator: exit-zero
hint: "Run conjureCluster in the Terminal, then wait ~30 seconds and re-check."
explanation: "Your cluster node is Ready. You have conjured Kubernetes from nothing. Show-off."
-->

<!-- LAB_SOLUTION
commands:
  - conjureCluster
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && waitForClusterReady
reveal: |
  ### The spell explained
  `conjureCluster` calls the framework's `startK3dCluster` (creates or attaches a
  k3d cluster + ingress) and `installK9s`. Once the node reports `Ready`, the
  cluster is usable and Section 01 is complete.
-->

<!-- boundScenarioId: enablement-dtwiz-101-01-install-kubernetes retake=false -->

<div class="grid cards" markdown>
- [Section 02: Deploy the Todo App](02-deploy-todo-app.md)
</div>
