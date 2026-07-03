# DTWiz 101: One Wizard to Instrument Them All

> In which a mildly over-caffeinated wizard hands you their favourite wand —
> **dtwiz**, the Dynatrace Ingest CLI — and teaches you to analyze any
> environment, deploy a demo app, and let Dynatrace see all. No slides, no
> hand-waving: a real terminal, a real tenant, one very opinionated CLI.

Welcome, apprentice. [dtwiz](https://github.com/dynatrace-oss/dtwiz) analyzes
a system and figures out the **best way to get Dynatrace observability into
it** — OneAgent, Kubernetes Operator, OpenTelemetry, cloud integrations — then
installs it for you. In this lab you learn to wield it end to end.

![DTWiz, your questionably qualified guide](img/dtwiz-wizard.png){ width="260" }
/// caption
DTWiz: 100% confidence, 60% documentation.
///

| You will learn to | Command used |
| --- | --- |
| Install the dtwiz CLI from scratch | `installDtwiz` (or the one-liner) |
| Check the connection to your tenant | `dtwiz status` |
| Analyze what a system runs | `dtwiz analyze` |
| Get ranked ingestion recommendations | `dtwiz recommend` |
| Deploy & instrument the schnitzel demo app | `dtwiz install demo` |
| Watch data arrive in Dynatrace | `dtwiz watch` |

!!! tip "Why this lab is different"
    Most labs pre-install everything. Not here. You will **install dtwiz
    yourself** in Section 01 — because a wizard who cannot summon their own
    wand is just a person in a pointy hat.

<div class="grid cards" markdown>
- [Begin: Getting Started](00-getting-started.md)
</div>
