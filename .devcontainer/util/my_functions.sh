#!/bin/bash
# ======================================================================
#   DTWiz 101 - Custom lab functions ("spells")
# ----------------------------------------------------------------------
#   Sourced into every terminal session, so functions must `return`,
#   never `exit`. These wrap the shared codespaces-framework helpers with
#   a DTWiz-themed name and add bounded wait/verify helpers so each lab
#   step can be verified right after the previous one without racing the
#   asynchronous Kubernetes rollout (same pattern as Kubernetes 101).
# ======================================================================

# --- Sample helper kept from the template (used by the getting-started check).
customFunction(){
  printInfoSection "The wizard warms up with a trivial incantation"
  printInfo "1 + 1 = $(( 1 + 1 ))"
}

# ----------------------------------------------------------------------
# Section 01 - Install Kubernetes (the wizard conjures a cluster)
# ----------------------------------------------------------------------
# Installs a local k3d cluster + ingress + k9s. This is the lab's
# "install Kubernetes" step - the cluster is NOT pre-started by the
# devcontainer, the learner (or the LAB_SOLUTION) casts this spell.
conjureCluster(){
  printInfoSection "Conjuring a Kubernetes cluster with k3d"
  startK3dCluster
  installK9s
  printInfo "The cluster has materialised. Behold: kubectl get nodes"
}

# Cluster node reaches Ready (bounded wait).
waitForClusterReady(){
  printInfoSection "Waiting for the cluster node to be Ready"
  local i=0
  while [ "$i" -lt 24 ]; do
    [ "$(kubectl get nodes --no-headers 2>/dev/null | grep -c ' Ready')" -gt 0 ] && { printInfo "node Ready"; return 0; }
    i=$((i + 1)); printInfo "node not Ready yet ($i/24), waiting 5s"; sleep 5
  done
  printError "Cluster node not Ready in time"; return 1
}

# ----------------------------------------------------------------------
# Section 02 - Deploy the Todo app (the wizard's questgiver board)
# ----------------------------------------------------------------------
deployTodoWizardApp(){
  printInfoSection "Deploying the Todo app onto the freshly conjured cluster"
  deployTodoApp
}

# Todo app pods reach Running.
waitForTodoApp(){
  printInfoSection "Waiting for the Todo app pods to be Running"
  local i=0
  while [ "$i" -lt 30 ]; do
    [ "$(kubectl get pods -n todoapp --no-headers 2>/dev/null | grep -c Running)" -gt 0 ] && { printInfo "todoapp Running"; return 0; }
    i=$((i + 1)); printInfo "todoapp not Running yet ($i/30), waiting 5s"; sleep 5
  done
  printError "todoapp pods not Running in time"; return 1
}

# Create a uniquely-tagged Todo via the app API so its log is findable in Grail.
DTWIZ_PROBE_TAG="DTWIZ101PROBE"
generateWizardTraffic(){
  local nonce="${DTWIZ_PROBE_TAG}-$(date +%s)-${RANDOM}"
  local url="http://localhost:${K3D_LB_HTTP_PORT:-80}"
  local host="todoapp.$(detectHostname)"
  printInfoSection "Casting a Todo into the app so Dynatrace has something to watch"
  printInfo "tag: $nonce"
  local i=0 ok=1
  while [ "$i" -lt 30 ]; do
    if curl -sf -o /dev/null -H "Host: $host" "$url/todos"; then ok=0; break; fi
    i=$((i + 1)); printInfo "app endpoint not ready ($i/30), waiting 5s"; sleep 5
  done
  [ "$ok" -ne 0 ] && { printError "todoapp HTTP endpoint not reachable"; return 1; }
  curl -s -H "Host: $host" -X POST "$url/todos" -H "Content-Type: application/json" \
    -d "{\"title\":\"$nonce\",\"completed\":false}" | grep -q '"status":"ok"' \
    && { printInfo "Tagged Todo created - it should reach Grail within ~2 min"; return 0; }
  printError "Failed to create tagged Todo"; return 1
}

# ----------------------------------------------------------------------
# Section 03 - Observe with Dynatrace (the all-seeing eye)
# ----------------------------------------------------------------------
summonDynatrace(){
  printInfoSection "Summoning the Dynatrace Operator + applicationMonitoring for the Todo app"
  dynatraceEvalReadSaveCredentials
  dynatraceDeployOperator

  # IMPORTANT: this repo is named "Enablement-DTWiz-101" (mixed case). The
  # framework derives the DynaKube name and its token secret from RepositoryName,
  # but Kubernetes resource names must be lowercase RFC-1123 — so the framework's
  # deployApplicationMonitoring produces an INVALID DynaKube/secret name that the
  # operator's validating webhook silently rejects (no DynaKube -> no injection).
  # Create our own lowercase-named token secret + DynaKube instead. The injection
  # namespaceSelector lives at spec.oneAgent.applicationMonitoring.namespaceSelector
  # in v1beta6; scope it to the todoapp namespace.
  printInfo "Creating the Dynatrace token secret (lowercase name)"
  kubectl -n dynatrace create secret generic dtwiz-tokens \
    --from-literal="apiToken=$DT_OPERATOR_TOKEN" \
    --from-literal="dataIngestToken=$DT_INGEST_TOKEN" \
    --dry-run=client -o yaml | kubectl apply -f -

  printInfo "Waiting for the Dynatrace mutating webhook to be Ready"
  kubectl -n dynatrace wait pod \
    --for=condition=ready \
    --selector=app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/component=webhook \
    --timeout=180s 2>/dev/null || true

  printInfo "Applying the applicationMonitoring DynaKube (scoped to todoapp)"
  kubectl apply -f - <<DTWIZ_DK
apiVersion: dynatrace.com/v1beta6
kind: DynaKube
metadata:
  name: dtwiz-101
  namespace: dynatrace
spec:
  apiUrl: ${DT_TENANT}/api
  tokens: dtwiz-tokens
  oneAgent:
    applicationMonitoring:
      namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: todoapp
DTWIZ_DK

  # Injection readiness lags the DynaKube apply: restart the Todo app and RETRY
  # until the injection annotation appears (webhook/CSI take a moment to be ready).
  local i=0
  while [ "$i" -lt 5 ]; do
    printInfo "Restarting the Todo app so OneAgent can inject (attempt $((i + 1))/5)"
    kubectl rollout restart deployment -n todoapp
    kubectl rollout status deployment -n todoapp --timeout=120s
    if isOneAgentInjected; then
      printInfo "OneAgent injected into the Todo app"
      return 0
    fi
    i=$((i + 1)); printInfo "not injected yet, waiting 20s before retrying restart"; sleep 20
  done
  printWarn "OneAgent injection not detected after retries"
  return 1
}

# Dynatrace Operator pod Running.
waitForOperatorReady(){
  printInfoSection "Waiting for the Dynatrace Operator pod to be Running"
  local i=0
  while [ "$i" -lt 36 ]; do
    kubectl get pods -n dynatrace --no-headers 2>/dev/null | grep -E 'operator' | grep -q Running && { printInfo "operator Running"; return 0; }
    i=$((i + 1)); printInfo "operator not Running yet ($i/36), waiting 5s"; sleep 5
  done
  printError "Dynatrace Operator pod not Running in time"; return 1
}

# Single-shot predicate: is OneAgent injected into the Todo app pods right now?
# Used by the section-03 shell-verification (kept quick so the driver's baseline
# phase does not burn a long wait before anything is deployed). The LAB_SOLUTION
# verify uses the bounded-wait waitForOneAgentInjected instead.
isOneAgentInjected(){
  kubectl get pods -n todoapp -o jsonpath='{.items[*].metadata.annotations.oneagent\.dynatrace\.com/injected}' 2>/dev/null | tr ' ' '\n' | grep -q true
}

# OneAgent injection annotation present on Todo app pods.
waitForOneAgentInjected(){
  printInfoSection "Waiting for the OneAgent injection annotation on todoapp pods"
  local i=0
  while [ "$i" -lt 24 ]; do
    if kubectl get pods -n todoapp -o jsonpath='{.items[*].metadata.annotations.oneagent\.dynatrace\.com/injected}' 2>/dev/null | tr ' ' '\n' | grep -q true; then
      printInfo "OneAgent injected"; return 0
    fi
    i=$((i + 1)); printInfo "not injected yet ($i/24), waiting 10s"; sleep 10
  done
  printError "OneAgent injection annotation not present in time"; return 1
}

# ----------------------------------------------------------------------
# Section 04 - Troubleshoot & recommend (the wizard breaks it on purpose)
# ----------------------------------------------------------------------
# Inject a fault: scale the Todo app to zero replicas. Dynatrace will show
# the service going dark - the learner diagnoses and fixes it.
castChaosSpell(){
  printInfoSection "Casting a Chaos Spell: scaling todoapp to 0 replicas (oops)"
  kubectl scale deployment todoapp -n todoapp --replicas=0
  printInfo "The Todo app has vanished. Watch it disappear in Dynatrace, then dispel the chaos."
}

# Detect the fault (used by a 'reproduce' shell-verification): exit 0 when broken.
isTodoAppDown(){
  local running
  running=$(kubectl get pods -n todoapp --no-headers 2>/dev/null | grep -c Running)
  if [ "${running:-0}" -eq 0 ]; then printInfo "Confirmed: todoapp has 0 Running pods (chaos in effect)"; return 0; fi
  printInfo "todoapp still has $running Running pod(s)"; return 1
}

# The fix: scale back up and wait for health.
dispelChaos(){
  printInfoSection "Dispelling the Chaos Spell: restoring todoapp to 1 replica"
  kubectl scale deployment todoapp -n todoapp --replicas=1
  kubectl rollout status deployment/todoapp -n todoapp --timeout=120s
  waitForTodoApp
}
