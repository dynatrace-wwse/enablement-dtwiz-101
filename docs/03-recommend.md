# 03. Recommend (The Wizard's Counsel)

![The wizard's counsel](img/dtwiz-todo.png){ width="220" align=right }

You installed the wand and analyzed the workshop. Time for the wizard's real
party trick: telling you what to do next.

## Ask for recommendations

```bash
dtwiz recommend --access-token "$DT_OPERATOR_TOKEN"
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
  The verification checks that a ranked recommendation list is produced —
  proof that dtwiz can combine the local analysis with your tenant's state.
-->

<!-- boundScenarioId: enablement-dtwiz-101-03-recommend retake=false -->

<div class="grid cards" markdown>
- [Section 04: The Demo App & Watch](04-demo-and-watch.md)
</div>
