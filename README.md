# DTWiz 101: The Kubernetes Observability Spellbook

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
