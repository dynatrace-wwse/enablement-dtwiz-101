# 04. Recommend & Watch (The Wizard's Counsel)

![Chaos, observed](img/dtwiz-chaos.png){ width="220" align=right }

You installed the wand, analyzed the workshop, and deployed an instrumented
app. Time for the wizard's real party trick: telling you what to do next —
and watching the data arrive.

## Step 1 — Ask for recommendations

```bash
dtwiz recommend --access-token "$DT_OPERATOR_TOKEN"
```

`recommend` combines the system analysis with your tenant's state and returns
a **ranked list of ingestion methods** with the reasoning behind each: what to
monitor, which method fits (OneAgent, Kubernetes Operator, OpenTelemetry,
cloud integration), and what is already covered.

Read the output: what does dtwiz suggest for your dev container, now that the
schnitzel demo is running?

!!! tip "The interactive shortcut"
    `dtwiz setup` chains everything you did by hand — analyze → recommend →
    install — as one interactive wizard. Now that you know the individual
    spells, you know exactly what it does under the hood. On a customer
    machine, `setup` is usually where you start.

## Step 2 — Watch the data arrive

`dtwiz watch` live-tails your tenant for **newly arriving data** (services,
logs, traces) — instant feedback that instrumentation works.

```bash
dtwiz watch
```

!!! warning "watch needs a platform token"
    `watch` queries the platform APIs, so it requires a **platform token**
    (`dt0s16.***`) via `DT_PLATFORM_TOKEN` — the lab's Classic access token
    is not enough. If you have one for your tenant, export it and watch the
    schnitzel telemetry roll in; otherwise verify the arrival with the Grail
    check below — same proof, different door.

## Step 3 — Verify the demo telemetry reached your tenant

The check below runs a DQL query against your tenant for spans emitted by the
schnitzel demo in the last 15 minutes — the end-to-end proof that
`dtwiz install demo` instrumented the app and the data arrived.

<!-- LAB_QUESTION
type: dql-verification
question: "Verify schnitzel telemetry reached Dynatrace"
buttonText: "Check data in Grail"
dql: |
  fetch spans
  | filter contains(service.name, "schnitzel")
  | filter start_time > now() - 15m
  | limit 1
expect:
  operator: not-empty
hint: "Complete Section 03 first. Telemetry takes ~1-2 minutes to reach Grail - the check retries, so give it a moment."
explanation: "Schnitzel spans are in Grail - the full dtwiz install demo → OpenTelemetry → Dynatrace pipeline is verified end to end."
-->

## Verify the wizard's counsel

<!-- LAB_QUESTION
type: shell-verification
question: "Verify dtwiz recommend produces ingestion recommendations"
buttonText: "Ask the Wizard"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isRecommendWorking"
expect:
  operator: exit-zero
hint: "Install dtwiz first (Section 01), then run `dtwiz recommend --access-token \"$DT_OPERATOR_TOKEN\"`."
explanation: "dtwiz produced ranked ingestion recommendations for this system."
-->

<!-- LAB_SOLUTION
commands:
  - installDtwiz
  - dtwizRecommend
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isRecommendWorking
reveal: |
  ### The spell explained
  `dtwizRecommend` runs `dtwiz recommend --access-token "$DT_OPERATOR_TOKEN"`.
  The verification checks that a ranked recommendation list is produced.
  `dtwiz watch` is the live-tail counterpart, but requires a platform token
  (dt0s16) - which is why the telemetry arrival is verified via the DQL check
  instead.
-->

## Knowledge check

Answer the final questions to complete the training.

<!-- boundScenarioId: enablement-dtwiz-101-04-recommend-and-watch retake=false -->

!!! success "Training complete!"
    You can now walk onto any system, summon dtwiz, analyze what runs there,
    deploy instrumentation, and prove the data arrives. Hasta la vista,
    blind spots.

<div class="grid cards" markdown>
- [Cleanup](cleanup.md)
</div>
