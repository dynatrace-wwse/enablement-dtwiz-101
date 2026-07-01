# 02. Deploy the Todo App (Summon the Quest Board)

![A very serious enterprise Todo app](img/dtwiz-todo.png){ width="220" align=right }

Every wizard keeps a quest board. Ours is a humble **Todo app** - a Node.js API
with a web UI, backed by a database, running on the cluster you just conjured. It
is deliberately unremarkable, which makes it perfect for watching Dynatrace work.

## Deploy it

```bash
source .devcontainer/util/source_framework.sh
deployTodoWizardApp
```

This applies the Todo app manifests to your cluster and registers it behind the
ingress. When it is ready, open the app UI at `http://localhost:8080` and add a
quest or two (`Defeat the flaky test`, `Rename a variable`, the usual).

## Generate a little traffic

So Dynatrace has something to observe later, cast a tagged Todo via the API:

```bash
generateWizardTraffic
```

## Verify the app is Running

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the Todo app pods are Running"
buttonText: "Check the Quest Board"
command: "kubectl get pods -n todoapp --no-headers 2>/dev/null | grep -q Running"
expect:
  operator: exit-zero
hint: "Run deployTodoWizardApp, then wait for the rollout and re-check."
explanation: "The Todo app is Running on your cluster. The quest board is open for business."
-->

<!-- LAB_SOLUTION
commands:
  - deployTodoWizardApp
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && waitForTodoApp
reveal: |
  ### The spell explained
  `deployTodoWizardApp` wraps the framework's `deployTodoApp`, which applies the
  Todo manifests, waits for the rollout, and registers the app behind the ingress
  so it is reachable at `http://localhost:8080`.
-->

<!-- boundScenarioId: enablement-dtwiz-101-02-deploy-todo-app retake=false -->

<div class="grid cards" markdown>
- [Section 03: Observe with Dynatrace](03-observe-with-dynatrace.md)
</div>
