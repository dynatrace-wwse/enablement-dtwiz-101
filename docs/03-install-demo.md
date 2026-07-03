# 03. Deploy the Demo App (The Questgiver Board)

![The demo app](img/dtwiz-todo.png){ width="220" align=right }

Analysis is nice; data is better. dtwiz ships an experimental **demo install**
that downloads the *schnitzel* demo application — a 4-service Python app —
instruments it with OpenTelemetry, and points the telemetry at **your**
tenant. One command, an instrumented app.

## Cast the spell

```bash
dtwiz install demo --experimental --yes --access-token "$DT_OPERATOR_TOKEN"
```

- `--experimental` — the demo installer is an experimental feature; this flag
  opts in.
- `--yes` — skip the confirmation prompts (the same flag every dtwiz install
  supports, for automation).

dtwiz downloads the app into `./schnitzel/`, makes sure Python is available,
wires up OpenTelemetry instrumentation, and starts the services.

Watch the processes:

```bash
ps aux | grep -i schnitzel | grep -v grep
```

## Verify the demo is running

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the schnitzel demo app is running"
buttonText: "Check the Demo"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && waitForDemoRunning"
expect:
  operator: exit-zero
hint: "Run `dtwiz install demo --experimental --yes --access-token \"$DT_OPERATOR_TOKEN\"` in the Terminal. The check waits up to ~2 min for the app processes."
explanation: "The schnitzel demo is up and instrumented - its telemetry is on the way to your tenant."
-->

<!-- LAB_SOLUTION
commands:
  - installDtwiz
  - deployDtwizDemo
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && waitForDemoRunning
reveal: |
  ### The spell explained
  `deployDtwizDemo` runs `dtwiz install demo --experimental --yes` with the
  lab's access token. dtwiz downloads the schnitzel app, instruments it with
  OpenTelemetry and starts it - the bounded verify waits for the app
  processes to appear.
-->

## See it in Dynatrace

Give the telemetry a couple of minutes, then look for the schnitzel services
in your tenant.

[dt-app|dynatrace.services|Open Services App](placeholder)

<!-- boundScenarioId: enablement-dtwiz-101-03-install-demo retake=false -->

<div class="grid cards" markdown>
- [Section 04: Recommend & Watch](04-recommend-and-watch.md)
</div>
