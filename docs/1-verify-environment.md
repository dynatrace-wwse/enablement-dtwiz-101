# 1. Verify the environment

Your environment was built before you opened this page. `post-create.sh` ran these functions:

```text
setUpTerminal          # shell, prompt, greeting
variablesNeeded        # DT_ENVIRONMENT required, DT_PLATFORM_TOKEN reported (names only)
startDtwizCluster      # k3d cluster named for your session, kubectl context selected
finalizePostCreation   # verifies the build, installs dtctl, reports errors in the greeting
```

dtwiz is **not** installed, and nothing from Dynatrace runs in the cluster yet. Both are what
this training is about.

## The cluster

dtwiz decides what to recommend from what it finds on the machine. For Kubernetes it reads the
current kubeconfig context and asks that cluster for its version and nodes. You can do the same
with read-only commands:

```bash
kubectl config current-context
kubectl get nodes
```

The context is `k3d-enablement-…` and the single node is `Ready`. The check confirms that the
context is the one named for your session and that its node is Ready, which is what dtwiz reads
in step 3. Check it:

<!-- LAB_QUESTION
type: shell-verification
question: "Verify the k3d cluster for your session is the current kubectl context and its node is Ready"
buttonText: "Check cluster"
command: "checkClusterReady"
expect:
  operator: exit-zero
hint: "The cluster is started by post-create. Read the greeting in the terminal for a build error, run kubectl get nodes, then check again."
explanation: "The k3d cluster runs, its node is Ready and it is the current kubectl context. dtwiz will find it there."
-->

## The credentials

dtwiz reads two environment variables and no configuration file:

| Variable | Content |
|---|---|
| `DT_ENVIRONMENT` | your tenant URL |
| `DT_PLATFORM_TOKEN` | a platform token (`dt0s16.…`) minted for your seat |

Show the tenant URL and only the prefix of the token. The value of a token is a credential;
never print it in full:

```bash
echo "$DT_ENVIRONMENT"
echo "${DT_PLATFORM_TOKEN:0:7}"
```

The second line prints `dt0s16.`. dtwiz accepts a classic API token (`dt0c01`) only through an
explicit `--access-token` flag, never from the environment, so a leftover variable cannot change
which token it uses.

<!-- LAB_QUESTION
type: multiple-choice
question: "Where does dtwiz take its platform token from in this environment?"
options:
  - "From DT_PLATFORM_TOKEN in the environment (or the --platform-token flag)"
  - "From a configuration file that dtwiz writes on first start"
  - "From DT_ACCESS_TOKEN, if it is set"
  - "From the kubeconfig of the k3d cluster"
correct: 0
explanation: "dtwiz reads DT_PLATFORM_TOKEN, or --platform-token, which takes precedence. A classic token is only used when passed explicitly with --access-token."
-->

<!-- LAB_NO_SOLUTION: provisioning sanity check — post-create.sh builds everything, nothing for the learner to do -->
