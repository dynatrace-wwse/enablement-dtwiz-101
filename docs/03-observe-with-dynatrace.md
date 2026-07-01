# 03. Observe with Dynatrace (The All-Seeing Eye)

![The all-seeing Dynatrace eye](img/dtwiz-eye.png){ width="220" align=right }

Your app is running, but you are flying blind. Time to summon the **all-seeing
eye**: the Dynatrace Operator deploys OneAgent, which auto-instruments the Todo
app - traces, metrics, logs, and topology, with zero code changes.

## Summon Dynatrace

```bash
source .devcontainer/util/source_framework.sh
summonDynatrace
```

`summonDynatrace` deploys the Dynatrace Operator, applies an
`applicationMonitoring` DynaKube, and restarts the Todo app so OneAgent can
inject into it. This takes a couple of minutes - the eye blinks slowly.

## Verify the Operator is Running

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the Dynatrace Operator pod is Running"
buttonText: "Check the Operator"
command: "kubectl get pods -n dynatrace --no-headers 2>/dev/null | grep operator | grep -q Running"
expect:
  operator: exit-zero
hint: "Run summonDynatrace, then wait for the operator pod and re-check."
explanation: "The Dynatrace Operator is Running - it will manage OneAgent and injection."
-->

## Verify OneAgent injected into the Todo app

<!-- LAB_QUESTION
type: shell-verification
question: "Verify OneAgent injected into the Todo app pods"
buttonText: "Check Injection"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isOneAgentInjected"
expect:
  operator: exit-zero
hint: "Injection happens on the pod restart summonDynatrace performs. Give it a minute."
explanation: "OneAgent is injected - the Todo app is now fully observed by Dynatrace."
-->

## See it in your tenant (DQL)

Once traffic has flowed for a couple of minutes, confirm Dynatrace is collecting
logs from the app. Run this in **Notebooks**, or click the check:

```text
fetch logs
| filter k8s.namespace.name == "todoapp"
| filter timestamp > now() - 10m
| limit 5
```

<!-- LAB_QUESTION
type: dql-verification
question: "Verify Dynatrace is collecting logs from the Todo app"
buttonText: "Check DT Logs"
dql: |
  fetch logs
  | filter k8s.namespace.name == "todoapp"
  | filter timestamp > now() - 10m
  | limit 1
expect:
  operator: not-empty
hint: "Add a few Todos (or run generateWizardTraffic), then wait 2 minutes."
explanation: "Logs are flowing into Grail - the all-seeing eye is open."
-->

<!-- LAB_SOLUTION
commands:
  - summonDynatrace
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && waitForOperatorReady
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && waitForOneAgentInjected
reveal: |
  ### The spell explained
  `summonDynatrace` runs `dynatraceDeployOperator` (Helm-installs the Operator +
  creates the API-token secret), `deployApplicationMonitoring` (applies a DynaKube
  in applicationMonitoring mode), then restarts the Todo app deployment so the
  OneAgent code module injects into the new pods. The two verifies confirm the
  Operator is Running and the injection annotation is present.
-->

<!-- boundScenarioId: enablement-dtwiz-101-03-observe-with-dynatrace retake=false -->

<div class="grid cards" markdown>
- [Section 04: Troubleshoot and Recommend](04-troubleshoot-and-recommend.md)
</div>
