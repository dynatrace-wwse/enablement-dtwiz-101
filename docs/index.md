# DTWiz 101: The Kubernetes Observability Spellbook

> In which a mildly over-caffeinated wizard teaches you to conjure a Kubernetes
> cluster, summon a Todo app, and make Dynatrace see all - then breaks
> everything on purpose so you can fix it. Standard wizard behaviour.

Welcome, apprentice. You are about to learn the ancient art of *observability*
the hands-on way: no slides, no hand-waving, just a real cluster you build
yourself and a real app you watch Dynatrace watch.

![DTWiz, your questionably qualified guide](img/dtwiz-wizard.png){ width="260" }
/// caption
DTWiz: 100% confidence, 60% documentation.
///

| You will learn to | Spell used |
| --- | --- |
| Install Kubernetes from scratch (nothing is pre-baked) | `conjureCluster` |
| Deploy a Todo app onto your cluster | `deployTodoWizardApp` |
| Make Dynatrace observe the app end to end | `summonDynatrace` |
| Diagnose and fix a deliberately broken service | `dispelChaos` |

!!! tip "Why this lab is different"
    Most labs hand you a running cluster. Not here. You will **install
    Kubernetes yourself** in Section 01 - because a wizard who cannot conjure
    their own cluster is just a person in a pointy hat.

<div class="grid cards" markdown>
- [Begin: Getting Started](00-getting-started.md)
</div>
