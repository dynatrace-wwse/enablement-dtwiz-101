# 00. Getting Started

Every wizard needs a workshop. Yours is a Dev Container (in the Dynatrace
Enablement App or a GitHub Codespace) that already has `kubectl`, `k3d`, `helm`,
`k9s`, and the framework spells loaded — but, crucially, **no running cluster
yet**. That is on purpose. You will conjure the cluster in Section 01.

## Your workshop surfaces

| URL | What it is |
| --- | --- |
| `http://localhost:8000` | This training guide (MkDocs) |
| `http://localhost:8080` | The Todo app web UI (after Section 02) |
| `http://localhost:3000` | Alternate app port |

The **Terminal** tab is your wand. Everything in this lab is typed there — or
run for you by clicking a check button.

## Warm-up incantation

Confirm the framework spells are loaded. Run the sample helper — it should do
arithmetic no wizard should be proud of:

```bash
source .devcontainer/util/source_framework.sh
customFunction
```

<!-- LAB_QUESTION
type: shell-verification
question: "Confirm the framework helper functions are loaded"
buttonText: "Warm up the wand"
command: "source .devcontainer/util/source_framework.sh && customFunction 2>&1 | grep -c '1 + 1'"
expect:
  operator: gt
  value: 0
hint: "The helper is defined in .devcontainer/util/my_functions.sh - make sure the file exists."
explanation: "The wand is warm - framework helpers are loaded. On to the cluster."
-->

!!! info "No cluster yet - that is expected"
    If you run `kubectl get nodes` right now you will get an error. Good. That
    is the whole point of Section 01.

<div class="grid cards" markdown>
- [Section 01: Install Kubernetes](01-install-kubernetes.md)
</div>
