# DTWiz 101: The Kubernetes Observability Spellbook

[![Integration tests](https://github.com/dynatrace-wwse/enablement-dtwiz-101/actions/workflows/integration-tests.yaml/badge.svg)](https://github.com/dynatrace-wwse/enablement-dtwiz-101/actions)
[![Version](https://img.shields.io/github/v/release/dynatrace-wwse/enablement-dtwiz-101?color=blueviolet)](https://github.com/dynatrace-wwse/enablement-dtwiz-101/releases)
[![Commits](https://img.shields.io/github/commits-since/dynatrace-wwse/enablement-dtwiz-101/latest?color=ff69b4&include_prereleases)](https://github.com/dynatrace-wwse/enablement-dtwiz-101/graphs/commit-activity)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?color=green)](https://github.com/dynatrace-wwse/enablement-dtwiz-101/blob/main/LICENSE)
[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live-green)](https://dynatrace-wwse.github.io/enablement-dtwiz-101/)
Dynatrace in-app enablement lab — hands-on training for sales engineers.

## What this lab covers

- See `docs/` for lesson pages.

## How to run

Open this repository in GitHub Codespaces. The devcontainer starts MkDocs automatically on port `8000`.

- Training guide: `http://localhost:8000`
- Demo app: `http://localhost:8080`

## Repository layout

```
docs/              MkDocs lesson pages
.assessment/       Scored assessment definitions
.devcontainer/     Codespaces and Orbital runtime
mkdocs.yaml        Lesson order and site config
enablement.yaml    Lab metadata
```

## Authoring

- Edit lesson pages in `docs/` and update `mkdocs.yaml` nav order
- Interactive blocks: `LAB_QUESTION` for shell-verification, dql-verification, multiple-choice
- Gated assessments: `boundScenarioId` + matching `.assessment/*.json`
- Do not commit secrets, tenant URLs, or `.env` values
