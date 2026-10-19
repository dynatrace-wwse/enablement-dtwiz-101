# dtwiz 101: deploy Dynatrace with the Dynatrace Ingest CLI

[![Integration tests](https://github.com/dynatrace-wwse/enablement-dtwiz-101/actions/workflows/integration-tests.yaml/badge.svg)](https://github.com/dynatrace-wwse/enablement-dtwiz-101/actions)
[![Version](https://img.shields.io/github/v/release/dynatrace-wwse/enablement-dtwiz-101?color=blueviolet)](https://github.com/dynatrace-wwse/enablement-dtwiz-101/releases)
[![Commits](https://img.shields.io/github/commits-since/dynatrace-wwse/enablement-dtwiz-101/latest?color=ff69b4&include_prereleases)](https://github.com/dynatrace-wwse/enablement-dtwiz-101/graphs/commit-activity)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?color=green)](https://github.com/dynatrace-wwse/enablement-dtwiz-101/blob/main/LICENSE)
[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live-green)](https://dynatrace-wwse.github.io/enablement-dtwiz-101/)

Hands-on training for [dtwiz](https://github.com/dynatrace-oss/dtwiz), the Dynatrace Ingest CLI,
delivered through the Dynatrace Enablement App or a GitHub Codespace.

## What the training covers

The environment starts with a running k3d Kubernetes cluster. The learner:

1. verifies the environment (cluster running, credentials present)
2. installs dtwiz and validates the platform token with `dtwiz status`
3. inventories the machine and the cluster with `dtwiz analyze`
4. reads the ranked ingestion methods from `dtwiz recommend`
5. deploys the Dynatrace Operator with `dtwiz install kubernetes`
6. troubleshoots authentication, cluster context, network and a pod that never becomes Ready
7. confirms the cluster in Dynatrace with `dtwiz watch` and scoped DQL assertions (`dtctl`)
8. removes the deployment with `dtwiz uninstall kubernetes`

Every step has a check that fails before the step and passes after it, and a solution that
replays the step's commands. `.devcontainer/test/integration.sh` runs them all in order.

## Token

dtwiz uses one platform token (`dt0s16`) from `DT_PLATFORM_TOKEN`, and writes the same token
into the DynaKube Secret, so the Dynatrace Operator runs on it too. The scopes are declared in
[`.devcontainer/yaml/dt-tokens.yaml`](.devcontainer/yaml/dt-tokens.yaml), each next to the
command or component that needs it. The Enablement App mints the token per seat from that file.

## Repository layout

```text
docs/                    lesson pages (MkDocs), one per step
docs/diagrams/*.mmd      diagram sources (mermaid); docs/img/*.svg are rendered from them
queries/                 DQL used in step 7, with the cluster name as a dtctl template variable
.assessment/             scored assessment
.devcontainer/           environment: post-create, framework pin, functions, token spec, tests
mkdocs.yaml              step order and site configuration
```

## Authoring

- Logic lives in `.devcontainer/util/my_functions.sh`; pages call `check*` functions.
- Diagrams: edit `docs/diagrams/*.mmd`, then render with the training generator's `tg diagrams`.
  Never edit the `.svg` by hand.
- Validate with `tg lint .` from the training generator.
- Do not commit secrets, tenant URLs or `.env` values.
