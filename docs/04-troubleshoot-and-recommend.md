# 04. Troubleshoot and Recommend (Break It On Purpose)

![Wizard casting a chaos spell and immediately regretting it](img/dtwiz-chaos.png){ width="220" align=right }

A wizard who has never broken production is not a wizard - just lucky. In this
final section you will **cast a Chaos Spell** that takes the Todo app down, watch
Dynatrace catch it, then **dispel the chaos** and confirm recovery. This is the
observe -> diagnose -> remediate loop, wizard edition.

## Cast the Chaos Spell (break it)

```bash
source .devcontainer/util/source_framework.sh
castChaosSpell
```

This scales the Todo app to **0 replicas**. Refresh `http://localhost:8080` - it
is gone. Now open Dynatrace:

- **Kubernetes app** -> the `todoapp` workload shows 0 running pods.
- **Services / Problems** -> the service goes unavailable; Davis may raise a problem.

Confirm the outage from the Terminal too:

<!-- LAB_QUESTION
type: shell-verification
question: "Confirm the Todo app is down (the Chaos Spell worked)"
buttonText: "Confirm the Outage"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && isTodoAppDown"
expect:
  operator: exit-zero
hint: "Run castChaosSpell first - it scales todoapp to 0 replicas."
explanation: "Confirmed: zero Running pods. Dynatrace now shows the service going dark."
-->

## Diagnose

In Dynatrace, the story is obvious once you know where to look. Query recent
problems for the namespace:

```text
fetch events
| filter event.kind == "DAVIS_PROBLEM"
| filter not(dt.davis.is_duplicate)
| filter event.status == "ACTIVE"
| filter timestamp > now() - 2h
| fields timestamp, event.name, event.category, event.status
| limit 20
```

!!! info "Wizard's recommendation"
    Availability incidents like this are exactly what **Davis anomaly detection**
    and **Kubernetes workload alerting** are for. In a real environment you would
    wire a Dynatrace **workflow** to notify on the problem and, where safe,
    auto-remediate. For today, you are the workflow.

## Dispel the Chaos (fix it)

```bash
dispelChaos
```

This scales the Todo app back to 1 replica and waits for it to become healthy.
Refresh `http://localhost:8080` - the quest board returns, and Dynatrace shows
the service recovering.

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the Todo app has recovered"
buttonText: "Confirm Recovery"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && waitForTodoApp"
expect:
  operator: exit-zero
hint: "Run dispelChaos to scale the app back up, then re-check."
explanation: "The Todo app is Running again. Observe, diagnose, remediate - loop complete."
-->

<!-- LAB_SOLUTION
commands:
  - dispelChaos
verify:
  - source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && waitForTodoApp
reveal: |
  ### The spell explained
  `dispelChaos` scales the `todoapp` deployment back to 1 replica and waits for
  the rollout plus a Running pod. In the automated (dummy-user) run the app is
  brought to a healthy state here; the "confirm the outage" check holds during
  the pre-deploy baseline, and the "confirm recovery" check holds post-solve.
-->

<!-- boundScenarioId: enablement-dtwiz-101-04-troubleshoot-and-recommend retake=false -->

!!! success "You are now a DTWiz"
    You conjured a cluster, summoned an app, opened the all-seeing eye, and
    survived your own chaos. Go forth and observe responsibly.

<div class="grid cards" markdown>
- [Resources](resources.md)
- [Cleanup](cleanup.md)
</div>
