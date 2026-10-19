# 3. Analyze the system

`dtwiz analyze` inventories the machine it runs on. It sends nothing to the tenant and needs no
token. It detects:

- the operating system and CPU architecture
- container runtimes (Docker) and running containers
- Kubernetes: the current kubeconfig context, the cluster name, the distribution and the nodes
- a running OneAgent or OpenTelemetry Collector
- cloud CLIs that are logged in (AWS, Azure, Google Cloud)
- running processes that look like services worth instrumenting

## Read the inventory

```bash
dtwiz analyze
```

Read the **Kubernetes** line: dtwiz found the cluster from step 1 through the kubeconfig and
reports its distribution as `k3s`, because k3d runs k3s inside Docker.

For scripts and for sharing with a colleague, `--json` prints the same inventory as structured
data. Save it in the working directory post-create created for you:

```bash
dtwiz analyze --json > ~/dtwiz/analysis.json
jq '{orchestrator, kubernetes}' ~/dtwiz/analysis.json
```

`kubernetes.cluster` is the name dtwiz will give the DynaKube in step 5, and the name of your
cluster in Dynatrace. Compare it with `dtwizClusterName`.

The check reads `~/dtwiz/analysis.json` and passes only when the inventory reports Kubernetes as
available with your cluster's name. It fails until you save the file. Check it:

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the saved inventory reports your k3d cluster"
buttonText: "Check inventory"
command: "checkDtwizAnalysis"
expect:
  operator: exit-zero
hint: "Run dtwiz analyze --json > ~/dtwiz/analysis.json, then check again. If the file reports no Kubernetes, check kubectl config current-context."
explanation: "dtwiz found the cluster through the kubeconfig. That is the only source it uses for Kubernetes."
-->

<!-- LAB_QUESTION
type: multiple-choice
question: "Which credential does dtwiz analyze need?"
options:
  - "None: it inspects the local machine and the current kubeconfig only"
  - "DT_PLATFORM_TOKEN, to look up existing entities"
  - "A classic API token passed with --access-token"
  - "Cluster-admin rights in every kubeconfig context"
correct: 0
explanation: "analyze sends nothing to the tenant. It reads the local machine and the current kubeconfig context, so it runs anywhere, even before a token exists."
-->

<!-- LAB_SOLUTION
reveal: |
  Run `dtwiz analyze` to read the inventory, then save it as JSON with
  `dtwiz analyze --json > ~/dtwiz/analysis.json`. `checkDtwizAnalysis` reads the file and
  requires `orchestrator == "kubernetes"` and your cluster's name in `kubernetes.cluster`.
commands:
  - dtwiz analyze
  - dtwiz analyze --json > ~/dtwiz/analysis.json
  - jq '{orchestrator, kubernetes}' ~/dtwiz/analysis.json
verify:
  - checkDtwizAnalysis
-->
