# 04. The Demo App & Watch (The Platform Tier)

![Chaos, observed](img/dtwiz-chaos.png){ width="220" align=right }

Analysis and counsel are nice; **data** is better. dtwiz's two most satisfying
commands — `install demo` and `watch` — talk to the Dynatrace *platform* APIs,
so they need the stronger credential: a **platform token**.

## The platform token

Everything so far ran with the lab's Classic access token (`dt0c01`). The
platform tier needs a **platform token** (`dt0s16.***`), which dtwiz reads
from `DT_PLATFORM_TOKEN`:

```bash
export DT_PLATFORM_TOKEN=dt0s16.****   # from your tenant, or your instructor
```

You can create one in your tenant under **Settings → Platform tokens** (or
ask your instructor for the training tenant's token). If you cannot get one,
read along — the quiz at the end covers what matters.

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
hint: "Export DT_PLATFORM_TOKEN, then run `dtwiz install demo --experimental --yes`. Without a platform token the check passes as 'skipped'."
explanation: "Either the schnitzel demo is running and instrumented, or the platform-token tier was skipped - both complete this step."
-->

<!-- LAB_SOLUTION
commands:
  - installDtwiz
  - deployDtwizDemo
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyDemoOrSkip
reveal: |
  ### The spell explained
  `deployDtwizDemo` runs `dtwiz install demo --experimental --yes` when
  `DT_PLATFORM_TOKEN` is set, and prints a clear skip message when it is not
  (the demo installer and `dtwiz watch` are platform-API features - the lab's
  Classic access token cannot drive them). `verifyDemoOrSkip` passes when the
  schnitzel processes are up, or when the tier was skipped for lack of a
  platform token.
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
