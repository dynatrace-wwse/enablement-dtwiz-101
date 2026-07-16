# 02. Connect & Analyze (The All-Seeing Eye)

![The all-seeing eye](img/dtwiz-eye.png){ width="220" align=right }

A wand is useless until it is pointed at something. In this section you
connect dtwiz to your Dynatrace tenant and let it analyze the workshop.

## Step 1 — Check the connection

dtwiz reads both `DT_ENVIRONMENT` and your `DT_PLATFORM_TOKEN` straight from
the environment — the lab injected both — so there is nothing to pass on the
command line:

```bash
dtwiz status
```

You should see the environment marked valid (✓) plus a compact **System
Analysis** — platform, container runtimes, cloud accounts, agents, services.

!!! info "Platform tokens are the modern standard"
    dtwiz authenticates with a **platform token** (`dt0s16.***`), which it
    reads automatically from `DT_PLATFORM_TOKEN`. One token unlocks
    *everything* — `status`, `analyze`, `recommend`, every `install`, and
    `watch`. The older **classic** API tokens (`dt0c01.***`, passed via
    `--access-token`) are being **deprecated**, so you will not need them
    here. On customer systems, reach for a platform token first.

## Step 2 — Analyze the system

```bash
dtwiz analyze
```

`analyze` inspects the machine it runs on — no tokens needed, nothing is sent
anywhere. It detects the platform and architecture, Docker, Kubernetes, cloud
CLIs, an already-running OneAgent, and interesting processes (services) worth
instrumenting.

Run it and read the output: what did dtwiz find in your dev container?

!!! tip "JSON for robots"
    `dtwiz analyze --json` prints the same inventory as structured JSON —
    handy for piping into scripts or automation.

## Verify the analysis works

<!-- LAB_QUESTION
type: shell-verification
question: "Verify dtwiz analyze detects your environment"
buttonText: "Gaze upon the system"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isAnalyzeWorking"
expect:
  operator: exit-zero
hint: "Install dtwiz first (Section 01), then run `dtwiz analyze` - the check expects it to report the container's Docker runtime."
explanation: "dtwiz analyzed the workshop and found the container runtime. The eye is open."
-->

## Prove you ran the spells yourself

The wizard rewards hands-on casting. Confirm you typed both commands in the
**Terminal** — dtwiz checks your shell history:

<!-- LAB_QUESTION
type: shell-verification
question: "Confirm you ran `dtwiz status` in the Terminal"
buttonText: "Check my terminal"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyRanStatus"
expect:
  operator: exit-zero
hint: "Type `dtwiz status` in the Terminal tab, then click this."
explanation: "You ran `dtwiz status` yourself — the wizard sees your history."
-->

<!-- LAB_QUESTION
type: shell-verification
question: "Confirm you ran `dtwiz analyze` in the Terminal"
buttonText: "Check my terminal"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyRanAnalyze"
expect:
  operator: exit-zero
hint: "Type `dtwiz analyze` in the Terminal tab, then click this."
explanation: "You ran `dtwiz analyze` yourself — the eye is truly open."
-->

<!-- LAB_SOLUTION
commands:
  - installDtwiz
  - dtwizConnect
  - analyzeSystem
  - "print -r -- 'dtwiz status' >> $HOME/.zsh_history"
  - "print -r -- 'dtwiz analyze' >> $HOME/.zsh_history"
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isAnalyzeWorking
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyRanStatus
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyRanAnalyze
reveal: |
  ### The spell explained
  `dtwizConnect` runs `dtwiz status` and `analyzeSystem` runs `dtwiz analyze` —
  both authenticate automatically with the injected platform token, no flag
  needed. The verification checks that the inventory reports the dev
  container's Docker runtime, and that both commands appear in your shell
  history — proof you cast them yourself.
-->

<!-- boundScenarioId: enablement-dtwiz-101-02-connect-and-analyze retake=false -->

<div class="grid cards" markdown>
- [Section 03: Recommend](03-recommend.md)
</div>
