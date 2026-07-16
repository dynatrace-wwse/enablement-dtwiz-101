# 01. Install dtwiz (Summon the Wand)

![Wizard summoning the CLI out of thin air](img/dtwiz-conjure.png){ width="220" align=right }

No dtwiz exists in your workshop yet. A real wizard summons their own wand.
You will install the official CLI exactly the way any SE or customer would on
a laptop or server.

## Cast the spell

In the **Terminal** tab, run the official install one-liner:

```bash
source <(curl -sSL https://raw.githubusercontent.com/dynatrace-oss/dtwiz/main/scripts/install.sh)
```

The installer detects your platform and architecture, downloads the right
binary, and puts it on your `PATH` (in `/usr/local/bin`, or `~/bin` as a
fallback). Sourcing it makes `dtwiz` available immediately in the same
terminal.

Then admire your handiwork:

```bash
dtwiz version
```

!!! tip "The lab spell"
    `installDtwiz` does the same thing (it wraps the one-liner) and is what
    the automated solution uses. Feel free to use either.

## Verify dtwiz is installed

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the dtwiz CLI is installed"
buttonText: "Check the Wand"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isDtwizInstalled"
expect:
  operator: exit-zero
hint: "Run the install one-liner (or installDtwiz) in the Terminal, then re-check."
explanation: "dtwiz is installed and answers to `dtwiz version`. You have summoned the wand."
-->

## Prove you summoned it yourself

The wizard only counts a spell you cast with your own hand. Confirm you ran the
install in the **Terminal** (dtwiz reads your shell history):

<!-- LAB_QUESTION
type: shell-verification
question: "Confirm you ran the dtwiz install one-liner in the Terminal"
buttonText: "Check my terminal"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyRanInstall"
expect:
  operator: exit-zero
hint: "Run the install one-liner (or `dtwiz version`) in the Terminal tab, then click this."
explanation: "You summoned the wand yourself — the wizard sees it in your history."
-->

<!-- LAB_SOLUTION
commands:
  - installDtwiz
  - "print -r -- 'dtwiz version' >> $HOME/.zsh_history"
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isDtwizInstalled
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyRanInstall
reveal: |
  ### The spell explained
  `installDtwiz` runs the official installer script from
  `dynatrace-oss/dtwiz` and confirms the binary answers. The installer places
  `dtwiz` in `/usr/local/bin` (using sudo) or `~/bin`, so it is available in
  every new terminal. `verifyRanInstall` then checks your shell history for
  the install command — proof you cast the spell yourself.
-->

<!-- boundScenarioId: enablement-dtwiz-101-01-install-dtwiz retake=false -->

<div class="grid cards" markdown>
- [Section 02: Connect & Analyze](02-connect-and-analyze.md)
</div>
