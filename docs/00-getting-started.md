# 00. Getting Started

Every wizard needs a workshop. Yours is a Dev Container (in the Dynatrace
Enablement App or a GitHub Codespace) with the framework spells loaded and your
Dynatrace credentials already injected — but, crucially, **no dtwiz yet**. That
is on purpose. You will summon it in Section 01.

## Your workshop surfaces

| URL | What it is |
| --- | --- |
| `http://localhost:8000` | This training guide (MkDocs) |
| Your Dynatrace tenant | Where the data lands (`$DT_ENVIRONMENT`) |

The **Terminal** tab is your wand. Everything in this lab is typed there — or
run for you by clicking a check button.

## Your credentials

The lab injected two environment variables you will use throughout:

- `DT_ENVIRONMENT` — your Dynatrace tenant URL. dtwiz reads it automatically.
- `DT_OPERATOR_TOKEN` — a Classic API token (`dt0c01.***`). dtwiz accepts it
  via the `--access-token` flag — **never** from an environment variable
  (that's a dtwiz safety choice, so you always know which credential you use).

```bash
echo $DT_ENVIRONMENT
```

## Warm-up incantation

Confirm the framework spells are loaded. Run the sample helper — it should do
arithmetic no wizard should be proud of:

```bash
customFunction
```

<!-- LAB_QUESTION
type: shell-verification
question: "Confirm the framework helper functions are loaded"
buttonText: "Warm up the wand"
command: "source .devcontainer/util/source_framework.sh >/dev/null 2>&1 && customFunction 2>&1 | grep -c '1 + 1'"
expect:
  operator: gt
  value: 0
hint: "The helper is defined in .devcontainer/util/my_functions.sh - make sure the file exists."
explanation: "The wand is warm - framework helpers are loaded. On to the wizard itself."
-->

!!! info "No dtwiz yet - that is expected"
    If you run `dtwiz` right now you will get *command not found*. Good. That
    is the whole point of Section 01.

<div class="grid cards" markdown>
- [Section 01: Install dtwiz](01-install-dtwiz.md)
</div>
