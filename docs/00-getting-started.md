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

The lab injected the two environment variables dtwiz needs — and dtwiz reads
**both automatically**, so you never type a token on the command line:

- `DT_ENVIRONMENT` — your Dynatrace tenant URL.
- `DT_PLATFORM_TOKEN` — a modern **platform token** (`dt0s16.***`).

Because dtwiz picks both up straight from the environment, `dtwiz status`,
`dtwiz analyze`, `dtwiz recommend`, `dtwiz install …` and `dtwiz watch` all
just work — **no `--access-token` flag, nothing to export by hand**. Platform
tokens are the standard dtwiz is built around; the old classic `dt0c01` API
tokens are being deprecated.

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
