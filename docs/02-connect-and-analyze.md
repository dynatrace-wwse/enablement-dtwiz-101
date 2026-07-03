# 02. Connect & Analyze (The All-Seeing Eye)

![The all-seeing eye](img/dtwiz-eye.png){ width="220" align=right }

A wand is useless until it is pointed at something. In this section you
connect dtwiz to your Dynatrace tenant and let it analyze the workshop.

## Step 1 — Check the connection

dtwiz reads `DT_ENVIRONMENT` automatically. Your lab credential is a Classic
API token, which dtwiz only accepts **explicitly** via `--access-token`:

```bash
dtwiz status --access-token "$DT_OPERATOR_TOKEN"
```

You should see the environment marked valid (✓) plus a compact **System
Analysis** — platform, container runtimes, cloud accounts, agents, services.

!!! info "Platform token vs. access token"
    dtwiz prefers a **platform token** (`dt0s16.***`, via `DT_PLATFORM_TOKEN`)
    — that unlocks everything, including `dtwiz watch`. A **Classic access
    token** (`dt0c01.***`, what this lab injects as `DT_OPERATOR_TOKEN`)
    covers the classic APIs: status, recommend and installs work fine. Keep
    this distinction in mind on customer systems.

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

<!-- LAB_SOLUTION
commands:
  - installDtwiz
  - analyzeSystem
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isAnalyzeWorking
reveal: |
  ### The spell explained
  `analyzeSystem` simply runs `dtwiz analyze`. The verification checks that
  the inventory reports the dev container's Docker runtime — proof that dtwiz
  can see the system it stands on. `dtwizConnect` additionally runs
  `dtwiz status --access-token "$DT_OPERATOR_TOKEN"` to confirm the tenant
  connection.
-->

<!-- boundScenarioId: enablement-dtwiz-101-02-connect-and-analyze retake=false -->

<div class="grid cards" markdown>
- [Section 03: Deploy the Demo App](03-install-demo.md)
</div>
