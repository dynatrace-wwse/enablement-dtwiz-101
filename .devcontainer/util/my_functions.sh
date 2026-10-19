#!/bin/bash
# Functions for the training "dtwiz 101".
# Sourced on top of the framework in every shell, check, setup and solution:
# use return, never exit. Every function is idempotent.
#
# Check pattern: a check probes once and answers immediately when the learner clicks.
# When automation sets LAB_WAIT=1 (nightly training-test, resume, solution verify), the
# checks that wait on the cluster or on Grail retry, so they never race asynchronous work.
#
# Placeholders such as DT_SESSION_ID do not resolve in shell: the learner's session id is
# read from $DT_HOSTGROUP.

# Where the learner keeps what dtwiz writes: the inventory, the recommendations and the
# install log. One directory, so every check reads a file the learner produced.
DTWIZ_WORKDIR="${DTWIZ_WORKDIR:-$HOME/dtwiz}"

# ----------------------------------------------------------------------------------------
# Cluster identity
# ----------------------------------------------------------------------------------------
# dtwiz names the DynaKube after the kubeconfig cluster ("k3d-<k3d cluster name>"), and the
# Dynatrace Operator reports the cluster to the tenant under that name. Every learner shares
# one tenant, so the name must be unique per learner, and dtwiz cuts it to 23 characters.
# The k3d name must also contain "enablement": the framework's startK3dCluster finds an
# existing cluster by that word. "enablement-" + 8 hex characters of the session id hash
# gives "k3d-enablement-1a2b3c4d", 23 characters exactly.
dtwizK3dName() {
  local sid="${DT_HOSTGROUP:-}"
  [ -z "$sid" ] && sid="local-$(hostname 2>/dev/null)"
  printf 'enablement-%s\n' "$(printf '%s' "$sid" | sha256sum | cut -c1-8)"
}

# The name dtwiz gives the DynaKube, and the Kubernetes cluster name in Dynatrace.
dtwizClusterName() {
  printf 'k3d-%s\n' "$(dtwizK3dName)"
}

# ----------------------------------------------------------------------------------------
# Environment (built by post-create)
# ----------------------------------------------------------------------------------------
# post-create.sh: start the k3d cluster under this learner's name before the learner arrives.
startDtwizCluster() {
  export K3D_CLUSTER_NAME
  K3D_CLUSTER_NAME="$(dtwizK3dName)"
  startCluster
}

# checkClusterReady: the kubeconfig points at this learner's k3d cluster and its node is Ready.
# This is what dtwiz reads in step 3.
checkClusterReady() {
  local expected ctx
  expected="$(dtwizClusterName)"
  ctx="$(kubectl config current-context 2>/dev/null)"
  if [ "$ctx" != "$expected" ]; then
    printError "kubectl context is '${ctx:-none}', expected '$expected' — the cluster is not attached"
    return 1
  fi
  checkNodeReady
}

# ----------------------------------------------------------------------------------------
# Step 2: install dtwiz and connect it to the tenant
# ----------------------------------------------------------------------------------------
# The installer puts dtwiz in /usr/local/bin, or in ~/bin without sudo. A check runs in a
# fresh non-interactive shell, so put ~/bin on PATH before looking.
_dtwizOnPath() {
  case ":$PATH:" in
    *":$HOME/bin:"*) ;;
    *) export PATH="$HOME/bin:$PATH" ;;
  esac
  command -v dtwiz >/dev/null 2>&1
}

# checkDtwizInstalled: dtwiz is on PATH and answers `dtwiz version`. post-create does not
# install it, so this fails until the learner runs the installer.
checkDtwizInstalled() {
  if ! _dtwizOnPath; then
    printError "dtwiz is not installed — run the install one-liner, then check again"
    return 1
  fi
  if ! dtwiz version >/dev/null 2>&1; then
    printError "dtwiz is on PATH but 'dtwiz version' fails"
    return 1
  fi
  printInfo "dtwiz is installed: $(dtwiz version 2>/dev/null | head -1)"
  return 0
}

# checkDtwizConnected: `dtwiz status` validates the platform token against the tenant.
# dtwiz validates it with a DQL query (fetch dt.system.events | limit 1); a ✓ on the
# Platform Token line means the tenant answered that query with this token.
checkDtwizConnected() {
  local out
  checkDtwizInstalled >/dev/null 2>&1 || { printError "dtwiz is not installed yet"; return 1; }
  if [ -z "${DT_ENVIRONMENT:-}" ]; then
    printError "DT_ENVIRONMENT is not set"; return 1
  fi
  if [ -z "${DT_PLATFORM_TOKEN:-}" ]; then
    printError "DT_PLATFORM_TOKEN is not set — the environment was provisioned without a platform token"
    return 1
  fi
  out="$(dtwiz status 2>&1)"
  if printf '%s\n' "$out" | grep -E 'Platform Token:' | grep -q '✓'; then
    printInfo "dtwiz authenticated to $DT_ENVIRONMENT with the platform token"
    return 0
  fi
  printError "dtwiz status did not validate the platform token:"
  printf '%s\n' "$out" | grep -E 'Environment:|Platform Token:'
  return 1
}

# ----------------------------------------------------------------------------------------
# Step 3: analyze
# ----------------------------------------------------------------------------------------
# checkDtwizAnalysis: the learner saved `dtwiz analyze --json` to analysis.json, and the
# inventory reports this learner's k3d cluster: Kubernetes available, the k3s distribution,
# and the cluster name dtwiz will give the DynaKube.
checkDtwizAnalysis() {
  local file="$DTWIZ_WORKDIR/analysis.json"
  [ -s "$file" ] || { printError "$file not found — save the inventory with dtwiz analyze --json"; return 1; }
  if jq -e --arg c "$(dtwizClusterName)" \
      '.orchestrator == "kubernetes" and .kubernetes.available == true and .kubernetes.cluster == $c' \
      "$file" >/dev/null 2>&1; then
    printInfo "The inventory reports Kubernetes: $(jq -r '.kubernetes.distribution + ", cluster " + .kubernetes.cluster' "$file")"
    return 0
  fi
  printError "The inventory in $file does not report the cluster $(dtwizClusterName):"
  jq -c '{orchestrator, kubernetes}' "$file" 2>/dev/null
  return 1
}

# ----------------------------------------------------------------------------------------
# Step 4: recommend
# ----------------------------------------------------------------------------------------
# checkDtwizRecommendation: the learner saved `dtwiz recommend --json`, and the list
# contains the Kubernetes method that names this cluster.
checkDtwizRecommendation() {
  local file="$DTWIZ_WORKDIR/recommendations.json"
  [ -s "$file" ] || { printError "$file not found — save the recommendations with dtwiz recommend --json"; return 1; }
  if jq -e --arg c "$(dtwizClusterName)" \
      'any(.[]; .method == "kubernetes" and ((.detection_info // "") | contains($c)))' \
      "$file" >/dev/null 2>&1; then
    printInfo "dtwiz recommends: $(jq -r '[.[] | .method] | join(", ")' "$file")"
    return 0
  fi
  printError "No Kubernetes recommendation for $(dtwizClusterName) in $file. Methods found:"
  jq -r '[.[] | .method] | join(", ")' "$file" 2>/dev/null
  return 1
}

# ----------------------------------------------------------------------------------------
# Step 5: deploy the Dynatrace Operator
# ----------------------------------------------------------------------------------------
# checkDynakubeApplied: dtwiz applied its DynaKube for this cluster. Fails before the install.
checkDynakubeApplied() {
  local dk i=0
  dk="$(dtwizClusterName)"
  if [ -n "${LAB_WAIT:-}" ]; then
    while [ "$i" -lt 36 ]; do
      kubectl -n dynatrace get dynakube "$dk" >/dev/null 2>&1 && break
      i=$((i + 1)); printInfo "DynaKube $dk not applied yet ($i/36), waiting 10s"; sleep 10
    done
  fi
  if kubectl -n dynatrace get dynakube "$dk" >/dev/null 2>&1; then
    printInfo "DynaKube $dk is applied"
    return 0
  fi
  printError "No DynaKube $dk in namespace dynatrace — run dtwiz install kubernetes, then check again"
  return 1
}

# ----------------------------------------------------------------------------------------
# Step 6: troubleshoot
# ----------------------------------------------------------------------------------------
# checkKspmRemoved: the DynaKube no longer requests KSPM, and no node-config-collector pod is
# left. Fails while the DynaKube still carries spec.kspm, and fails without a DynaKube.
checkKspmRemoved() {
  local dk
  dk="$(dtwizClusterName)"
  if ! kubectl -n dynatrace get dynakube "$dk" >/dev/null 2>&1; then
    printError "No DynaKube $dk — deploy the operator first (step 5)"; return 1
  fi
  if [ -n "$(kubectl -n dynatrace get dynakube "$dk" -o jsonpath='{.spec.kspm}' 2>/dev/null)" ]; then
    printError "DynaKube $dk still requests KSPM (spec.kspm) — remove it, then check again"; return 1
  fi
  if kubectl -n dynatrace get pods --no-headers 2>/dev/null | grep -q node-config-collector; then
    if [ -n "${LAB_WAIT:-}" ]; then
      local i=0
      while [ "$i" -lt 18 ] && kubectl -n dynatrace get pods --no-headers 2>/dev/null | grep -q node-config-collector; do
        i=$((i + 1)); printInfo "node-config-collector still terminating ($i/18), waiting 10s"; sleep 10
      done
    fi
    if kubectl -n dynatrace get pods --no-headers 2>/dev/null | grep -q node-config-collector; then
      printError "spec.kspm is gone but a node-config-collector pod is still there — wait a moment, then check again"; return 1
    fi
  fi
  printInfo "KSPM removed from $dk; no node-config-collector pod left"
  return 0
}

# checkDynatracePodsReady: the condition `dtwiz install kubernetes` waits for — every pod in
# namespace dynatrace Ready, and at least one ActiveGate pod among them. Checked on the cluster,
# not in the install log: dtwiz stops waiting after 10 minutes, the cluster does not.
checkDynatracePodsReady() {
  local i=0 tries=1 total notready ag
  [ -n "${LAB_WAIT:-}" ] && tries=60
  while :; do
    total="$(kubectl -n dynatrace get pods --no-headers 2>/dev/null | grep -vc Completed)"
    notready="$(kubectl -n dynatrace get pods --no-headers 2>/dev/null | grep -v Completed \
      | awk '{split($2,a,"/"); if (a[1]!=a[2] || a[1]==0) n++} END {print n+0}')"
    ag="$(kubectl -n dynatrace get pods --no-headers 2>/dev/null | grep -i activegate \
      | awk '{split($2,a,"/"); if (a[1]==a[2] && a[1]>0) n++} END {print n+0}')"
    if [ "$total" -gt 0 ] && [ "$notready" -eq 0 ] && [ "$ag" -gt 0 ]; then
      printInfo "All $total Dynatrace pods are Ready, ActiveGate included"
      return 0
    fi
    i=$((i + 1))
    [ "$i" -ge "$tries" ] && break
    printInfo "$notready of $total Dynatrace pods not Ready yet ($i/$tries), waiting 10s"; sleep 10
  done
  printError "$notready of $total Dynatrace pods are not Ready (ActiveGate Ready: $ag):"
  kubectl -n dynatrace get pods --no-headers 2>/dev/null | grep -v Completed \
    | awk '{split($2,a,"/"); if (a[1]!=a[2] || a[1]==0) print "  " $1 " " $2 " " $3}'
  return 1
}

# ----------------------------------------------------------------------------------------
# Step 7: analyze the monitored system in Dynatrace (dtctl, configured by the framework)
# ----------------------------------------------------------------------------------------
# Number of probes: 1 for a learner's click, 30 x 10 s when LAB_WAIT is set.
_dtwizProbeCount() {
  if [ -n "${LAB_WAIT:-}" ]; then echo 30; else echo 1; fi
}

# _dtwizDtctlAssert <description> <dql>
# The query must keep a row only when the assertion holds and add
# verdict = concat("ASSERT", "_PASS"). The marker is built inside DQL, so it appears in the
# output only when a row came back, never because dtctl echoed the query in an error.
_dtwizDtctlAssert() {
  local description="$1" dql="$2" tries out i=1
  command -v dtctl >/dev/null 2>&1 || { printError "dtctl is not installed"; return 1; }
  tries=$(_dtwizProbeCount)
  while [ "$i" -le "$tries" ]; do
    if out=$(dtctl query "$dql" 2>&1) && printf '%s' "$out" | grep -q "ASSERT_PASS"; then
      printInfo "PASS: $description"
      return 0
    fi
    [ "$i" -lt "$tries" ] && sleep 10
    i=$((i + 1))
  done
  printError "FAIL: $description"
  [ -n "${out:-}" ] && printf '%s\n' "$out" | tail -5
  return 1
}

# checkClusterInDynatrace [cluster]: the tenant knows a Kubernetes cluster of that name
# (default: this learner's). The operator registers it through the ActiveGate.
checkClusterInDynatrace() {
  local c="${1:-$(dtwizClusterName)}"
  _dtwizDtctlAssert "Kubernetes cluster $c is in Dynatrace" \
    "smartscapeNodes K8S_CLUSTER | filter name == \"$c\" | limit 1 | fieldsAdd verdict = concat(\"ASSERT\", \"_PASS\")"
}

# checkClusterLogs [cluster]: container logs of that cluster reached Grail in the last
# 15 minutes (the DynaKube's logMonitoring module).
checkClusterLogs() {
  local c="${1:-$(dtwizClusterName)}"
  _dtwizDtctlAssert "logs of cluster $c are in Grail" \
    "fetch logs, from:now()-15m | filter k8s.cluster.name == \"$c\" | limit 1 | fieldsAdd verdict = concat(\"ASSERT\", \"_PASS\")"
}

# ----------------------------------------------------------------------------------------
# Step 8: remove what dtwiz installed
# ----------------------------------------------------------------------------------------
# checkOperatorRemoved: no DynaKube and no operator pod left. Fails while the operator runs.
checkOperatorRemoved() {
  local i=0
  # An unreachable cluster also lists no DynaKube: without this the check passes vacuously.
  if ! kubectl get nodes >/dev/null 2>&1; then
    printError "The cluster is not reachable — cannot tell whether the Operator is removed"; return 1
  fi
  if [ -n "${LAB_WAIT:-}" ]; then
    while [ "$i" -lt 18 ]; do
      kubectl -n dynatrace get dynakube --no-headers 2>/dev/null | grep -q . || \
        kubectl -n dynatrace get pods --no-headers 2>/dev/null | grep -q operator || break
      i=$((i + 1)); printInfo "operator still being removed ($i/18), waiting 10s"; sleep 10
    done
  fi
  if kubectl -n dynatrace get dynakube --no-headers 2>/dev/null | grep -q .; then
    printError "A DynaKube is still applied — run dtwiz uninstall kubernetes, then check again"; return 1
  fi
  if kubectl -n dynatrace get pods --no-headers 2>/dev/null | grep -q operator; then
    printError "The Dynatrace Operator is still running"; return 1
  fi
  printInfo "The Dynatrace Operator and its DynaKubes are removed"
  return 0
}

# ----------------------------------------------------------------------------------------
# Output hygiene
# ----------------------------------------------------------------------------------------
# redactTokens: filter for dtwiz output. `dtwiz install kubernetes` prints the manifest it
# applies, and the Secret in it holds the platform token as apiToken and dataIngestToken.
# Replaces both values, and any other dt0s16/dt0c01 token, before the output is shown or saved.
redactTokens() {
  sed -E -e 's/((apiToken|dataIngestToken):[[:space:]]*).*/\1<redacted>/' \
         -e 's/dt0(s16|c01|s01|g02)\.[A-Za-z0-9._-]+/dt0\1.<redacted>/g'
}
