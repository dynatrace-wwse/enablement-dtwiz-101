# 4. Read the recommendations

`dtwiz recommend` turns the inventory from step 3 into a list of ingestion methods. Each entry
says what it would monitor, why dtwiz suggests it (`detection_info`), what it needs, and the
command that installs it. Like `analyze`, it runs locally.

## Read the list

```bash
dtwiz recommend
```

Expect several entries. Because step 1's cluster is the current context, one of them is
**Kubernetes cluster**, installed with `dtwiz install kubernetes`. The host-level entries
(OneAgent, OpenTelemetry Collector) appear because dtwiz also sees the Linux machine itself. In
a container such as this one, the Kubernetes method is the one that matches what runs here.
Save the list as JSON:

```bash
dtwiz recommend --json > ~/dtwiz/recommendations.json
jq -r '.[] | "\(.method)\t\(.detection_info // "")"' ~/dtwiz/recommendations.json
```

The Kubernetes entry's `detection_info` names the distribution, your cluster and its node count:
the evidence behind the recommendation.

The check reads `~/dtwiz/recommendations.json` and passes only when it contains a `kubernetes`
method whose detection names your cluster. It fails until you save the file. Check it:

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the saved recommendations contain the Kubernetes method for your cluster"
buttonText: "Check recommendations"
command: "checkDtwizRecommendation"
expect:
  operator: exit-zero
hint: "Run dtwiz recommend --json > ~/dtwiz/recommendations.json, then check again."
explanation: "dtwiz recommends the Dynatrace Operator because it detected your cluster, and names the cluster as its evidence."
-->

!!! tip "`dtwiz setup`"
    `dtwiz setup` chains the three commands interactively: analyze, recommend, then install the
    method you pick. On a customer machine it is the usual entry point. In this training you run
    the commands one at a time so you can read each result.

<!-- LAB_QUESTION
type: multiple-choice
question: "dtwiz recommend lists no Kubernetes method, although the customer has a cluster. What is the first thing to check?"
options:
  - "That the current kubeconfig context on this machine points at that cluster"
  - "That the platform token carries the Kubernetes scopes"
  - "That the Dynatrace Operator is already installed"
  - "That the tenant has a Kubernetes app installed"
correct: 0
explanation: "dtwiz detects Kubernetes only through the current kubeconfig context. No context, or a context for another cluster, means no recommendation, or a recommendation for the wrong cluster."
-->

<!-- LAB_SOLUTION
reveal: |
  Run `dtwiz recommend`, then save the list with
  `dtwiz recommend --json > ~/dtwiz/recommendations.json`. `checkDtwizRecommendation` requires
  an entry with `method == "kubernetes"` whose `detection_info` names your cluster.
commands:
  - dtwiz recommend
  - dtwiz recommend --json > ~/dtwiz/recommendations.json
  - jq -r '.[] | "\(.method)\t\(.detection_info // "")"' ~/dtwiz/recommendations.json
verify:
  - checkDtwizRecommendation
-->
