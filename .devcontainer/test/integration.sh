#!/bin/bash
# Integration test for dtwiz 101. Runs every step's solution in order, and asserts each step's
# check FAILS before its solution and PASSES after it: a check never seen failing proves nothing.
#
# Steps 1, 3 and 4 need no tenant. Steps 2 and 5-8 need DT_ENVIRONMENT and a DT_PLATFORM_TOKEN
# carrying the scopes in .devcontainer/yaml/dt-tokens.yaml; without one they are skipped and the
# run says so.
source .devcontainer/util/source_framework.sh

printInfoSection "Running integration tests for $RepositoryName"

fail() {
  printError "$1"
  # Never leave the Operator behind: it holds the platform token in a Secret.
  kubectl get namespace dynatrace >/dev/null 2>&1 && dtwiz uninstall kubernetes --yes >/dev/null 2>&1
  exit 1
}

# --- Step 1: post-create built the cluster ---------------------------------------------
checkClusterReady || fail "checkClusterReady failed: post-create did not start the cluster"

# --- Step 2: install dtwiz ------------------------------------------------------------------
checkDtwizInstalled >/dev/null 2>&1 && fail "checkDtwizInstalled passed before the install: check cannot fail"
source <(curl -sSL https://raw.githubusercontent.com/dynatrace-oss/dtwiz/main/scripts/install.sh)
checkDtwizInstalled || fail "checkDtwizInstalled failed after the install"

# --- Step 3: analyze ------------------------------------------------------------------------
checkDtwizAnalysis >/dev/null 2>&1 && fail "checkDtwizAnalysis passed before analyze: check cannot fail"
dtwiz analyze --json > "$DTWIZ_WORKDIR/analysis.json"
checkDtwizAnalysis || fail "checkDtwizAnalysis failed after step 3's solution"
# Negative control: the same inventory taken with no kubeconfig context must not pass.
KUBECONFIG=/dev/null dtwiz analyze --json > "$DTWIZ_WORKDIR/analysis.json"
checkDtwizAnalysis >/dev/null 2>&1 && fail "checkDtwizAnalysis passed with no cluster context"
dtwiz analyze --json > "$DTWIZ_WORKDIR/analysis.json"

# --- Step 4: recommend ----------------------------------------------------------------------
checkDtwizRecommendation >/dev/null 2>&1 && fail "checkDtwizRecommendation passed before recommend: check cannot fail"
dtwiz recommend --json > "$DTWIZ_WORKDIR/recommendations.json"
checkDtwizRecommendation || fail "checkDtwizRecommendation failed after step 4's solution"

# --- Steps 2 (connect) and 5-8 need the tenant ----------------------------------------------
if [ -z "${DT_ENVIRONMENT:-}" ] || [ -z "${DT_PLATFORM_TOKEN:-}" ]; then
  printWarn "DT_ENVIRONMENT or DT_PLATFORM_TOKEN not set: skipping step 2's connection check and steps 5-8"
  printInfoSection "Steps 1, 3 and 4 passed; steps 2 (connect) and 5-8 were NOT tested"
  exit 0
fi

DT_PLATFORM_TOKEN=dt0s16.EXAMPLE.invalid checkDtwizConnected >/dev/null 2>&1 \
  && fail "checkDtwizConnected passed with an invalid token: check cannot fail"
checkDtwizConnected || fail "checkDtwizConnected failed: the platform token does not validate (scopes?)"

# --- Step 5: deploy ------------------------------------------------------------------------
checkDynakubeApplied >/dev/null 2>&1 && fail "checkDynakubeApplied passed before the install: check cannot fail"
timeout 5m dtwiz install kubernetes --yes 2>&1 | redactTokens | tail -20
LAB_WAIT=1 checkDynakubeApplied || fail "checkDynakubeApplied failed after step 5's solution"

# --- Step 6: KSPM ---------------------------------------------------------------------------
checkKspmRemoved >/dev/null 2>&1 && fail "checkKspmRemoved passed while the DynaKube requests KSPM: check cannot fail"
kubectl -n dynatrace patch dynakube "$(dtwizClusterName)" --type=json -p='[{"op":"remove","path":"/spec/kspm"}]'
LAB_WAIT=1 checkKspmRemoved || fail "checkKspmRemoved failed after step 6's solution"
LAB_WAIT=1 checkDynatracePodsReady || fail "checkDynatracePodsReady failed after step 6's solution"

# --- Step 7: the cluster in Dynatrace -------------------------------------------------------
enableDtctl
checkClusterInDynatrace k3d-enablement-00000000 && fail "checkClusterInDynatrace passed for a cluster that does not exist"
LAB_WAIT=1 checkClusterInDynatrace || fail "checkClusterInDynatrace failed after step 7"
LAB_WAIT=1 checkClusterLogs || fail "checkClusterLogs failed after step 7"

# --- Step 8: remove -------------------------------------------------------------------------
checkOperatorRemoved >/dev/null 2>&1 && fail "checkOperatorRemoved passed while the Operator runs: check cannot fail"
dtwiz uninstall kubernetes --yes
LAB_WAIT=1 checkOperatorRemoved || fail "checkOperatorRemoved failed after step 8's solution"

printInfoSection "All step checks failed before their solutions and passed after"
