# 03. Recommend (The Wizard's Counsel)

![The wizard's counsel](img/dtwiz-todo.png){ width="220" align=right }

You installed the wand and analyzed the workshop. Time for the wizard's real
party trick: telling you what to do next.

## Ask for recommendations

dtwiz already has everything it needs — your tenant URL and the platform token
are read straight from the environment, so no flags:

```bash
dtwiz recommend
```

`recommend` combines the system analysis with your tenant's state and returns
a **ranked list of ingestion methods** with the reasoning behind each: what to
monitor, which method fits (OneAgent, Kubernetes Operator, OpenTelemetry,
cloud integration), and what is already covered.

Read the output: what does dtwiz suggest for your dev container?

!!! tip "The interactive shortcut"
    `dtwiz setup` chains everything — analyze → recommend → install — as one
    guided interactive wizard. Now that you know the individual spells, you
    know exactly what it does under the hood. On a customer machine, `setup`
    is usually where you start.

!!! info "From counsel to action"
    Each recommendation maps to an install command: `dtwiz install oneagent`,
    `dtwiz install kubernetes`, `dtwiz install otel`, `dtwiz install aws` …
    All of them support `--yes` for automation.

## Verify the wizard's counsel

<!-- LAB_QUESTION
type: shell-verification
question: "Verify dtwiz recommend produces ingestion recommendations"
buttonText: "Ask the Wizard"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isRecommendWorking"
expect:
  operator: exit-zero
hint: "Install dtwiz first (Section 01), then run `dtwiz recommend`."
explanation: "dtwiz produced ranked ingestion recommendations for this system."
-->

## Prove you asked the wizard yourself

<!-- LAB_QUESTION
type: shell-verification
question: "Confirm you ran `dtwiz recommend` in the Terminal"
buttonText: "Check my terminal"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyRanRecommend"
expect:
  operator: exit-zero
hint: "Type `dtwiz recommend` in the Terminal tab, then click this."
explanation: "You asked the wizard yourself — the counsel was earned, not clicked."
-->

<!-- LAB_SOLUTION
commands:
  - installDtwiz
  - dtwizRecommend
  - "print -r -- 'dtwiz recommend' >> $HOME/.zsh_history"
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isRecommendWorking
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && verifyRanRecommend
reveal: |
  ### The spell explained
  `dtwizRecommend` runs `dtwiz recommend` — authenticated automatically with
  the injected platform token. The verification checks that a ranked
  recommendation list is produced, and that you ran the command yourself —
  proof that dtwiz can combine the local analysis with your tenant's state.
-->

<!-- boundScenarioId: enablement-dtwiz-101-03-recommend retake=false -->

<div class="grid cards" markdown>
- [Section 03b: Install on Kubernetes](03b-install-kubernetes.md)
</div>
