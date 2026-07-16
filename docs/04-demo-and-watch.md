# 04. The Demo App & Watch (The Platform Tier)

![Chaos, observed](img/dtwiz-chaos.png){ width="220" align=right }

Analysis and counsel are nice; **data** is better. dtwiz's two most satisfying
commands — `install demo` and `watch` — talk to the Dynatrace *platform* APIs.

## Already authenticated

Good news: there is nothing to set up. `install demo` and `watch` use the same
**platform token** (`dt0s16.***`) the lab already injected as
`DT_PLATFORM_TOKEN`, and dtwiz reads it automatically. No flags, no exports —
just run the commands below.

## Step 1 — Deploy the schnitzel demo app

```bash
export TMPDIR=$PWD/.dtwiz-tmp && mkdir -p $TMPDIR
dtwiz install demo --experimental --yes
```

!!! note "Why the TMPDIR line?"
    dtwiz extracts the demo under `/tmp` and renames it into your current
    directory. In a Codespace those are **different mounts**, so the rename
    fails with *invalid cross-device link* — pointing `TMPDIR` at the
    workspace mount fixes it. (The `deployDtwizDemo` spell does this for you.)

- `--experimental` — the demo installer is an experimental feature; this flag
  opts in.
- `--yes` — skip the confirmation prompts (every dtwiz install supports it,
  for automation).

dtwiz downloads the **schnitzel** demo — a multi-service Python app — into
`./schnitzel/`, instruments it with OpenTelemetry, starts it, and points the
telemetry at your tenant. One command, an instrumented app.

Watch the processes:

```bash
ps aux | grep -i schnitzel | grep -v grep
```

## OpenTelemetry is first-class in Dynatrace

Notice what *didn't* happen: no OneAgent, no operator, no code changes. The
schnitzel services are already **instrumented with OpenTelemetry** — the
open, vendor-neutral standard — and they ship their telemetry as **OTLP**
(the OpenTelemetry wire protocol) **straight to your tenant**.

In Dynatrace those spans are not second-class citizens. They land in
**Grail** as first-class records, unified with every other signal, and you
query them with **DQL** just like anything else. Give ingest a minute, then
run this in your tenant's **Notebook** or **Query** app:

```dql
fetch spans, from:now()-15m
| filter contains(service.name, "schnitzel")
| limit 20
```

That is the whole promise of OpenTelemetry on Dynatrace: instrument with an
open standard, send OTLP directly, and get the full Dynatrace analytics
experience on top — no proprietary agent required.

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the schnitzel OpenTelemetry spans reached Grail (auto-passes if no platform token)"
buttonText: "Check Grail for spans"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyOtelTracesInGrail"
expect:
  operator: exit-zero
hint: "Deploy the demo first, then wait a minute for OTLP ingest. Without a platform token the check passes as 'skipped'."
explanation: "The schnitzel spans are queryable in Grail — the app → OTLP → Grail pipeline works end to end."
-->

## Step 2 — Watch the data arrive

```bash
dtwiz watch
```

`watch` live-tails your tenant for **newly arriving data** (services, logs,
traces) — instant feedback that the instrumentation works. Give the schnitzel
telemetry a minute or two, then see it roll in. Stop with ++ctrl+c++.

## Step 3 — See it in Dynatrace

The schnitzel services appear in your tenant like any other instrumented app:

[dt-app|dynatrace.services|Open Services App](placeholder)

## Verify the demo (needs the platform token)

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the schnitzel demo app is running (auto-passes if no platform token is available)"
buttonText: "Check the Demo"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyDemoOrSkip"
expect:
  operator: exit-zero
hint: "Run `dtwiz install demo --experimental --yes` (the platform token is already injected). Without a platform token the check passes as 'skipped'."
explanation: "Either the schnitzel demo is running and instrumented, or the platform-token tier was skipped - both complete this step."
-->

<!-- LAB_SOLUTION
commands:
  - installDtwiz
  - deployDtwizDemo
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyDemoOrSkip
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyOtelTracesInGrail
reveal: |
  ### The spell explained
  `deployDtwizDemo` runs `dtwiz install demo --experimental --yes` using the
  injected `DT_PLATFORM_TOKEN` (and prints a clear skip message in the rare
  case a platform token is missing, so the lab stays completable everywhere).
  `verifyDemoOrSkip` passes when the schnitzel processes are up (or the tier
  was skipped), and `verifyOtelTracesInGrail` queries Grail for the demo's
  OpenTelemetry spans — proving the app → OTLP → Grail pipeline end to end.
-->

## Knowledge check

Answer the final questions to complete the training.

<!-- boundScenarioId: enablement-dtwiz-101-04-demo-and-watch retake=false -->

!!! success "Training complete!"
    You can now walk onto any system, summon dtwiz, analyze what runs there,
    read its counsel, deploy instrumentation, and prove the data arrives.
    Hasta la vista, blind spots.

<div class="grid cards" markdown>
- [Cleanup](cleanup.md)
</div>
