#!/bin/bash
# ======================================================================
#   DTWiz 101 - Custom lab functions ("spells")
# ----------------------------------------------------------------------
#   Sourced into every terminal session, so functions must `return`,
#   never `exit`. This lab teaches the dtwiz CLI (dynatrace-oss/dtwiz):
#   install it, analyze the environment, deploy the schnitzel demo app,
#   and read dtwiz's recommendations. Each section has a solution spell
#   plus a bounded verify helper so the LAB_SOLUTION runner can solve and
#   check a step without racing asynchronous work.
# ======================================================================

# --- Sample helper kept from the template (used by the getting-started check).
customFunction(){
  printInfoSection "The wizard warms up with a trivial incantation"
  printInfo "1 + 1 = $(( 1 + 1 ))"
}

DTWIZ_INSTALL_URL="https://raw.githubusercontent.com/dynatrace-oss/dtwiz/main/scripts/install.sh"

# ----------------------------------------------------------------------
# Shell-history verification — confirm the learner actually TYPED a command
# ----------------------------------------------------------------------
# The training gates progression on the learner running real dtwiz commands
# themselves (not just clicking a solve button). These helpers grep the shell
# history for a pattern so a check button can confirm "you ran `dtwiz status`".
# Works for zsh (default here) and bash; the framework opens a login zsh.
ranCommand(){
  local pattern="$1"
  local hist
  for hist in "$HOME/.zsh_history" "$HISTFILE" "$HOME/.bash_history"; do
    [ -n "$hist" ] && [ -f "$hist" ] || continue
    # zsh history lines are ": <ts>:0;<cmd>" — grep the command part.
    if grep -aE "${pattern}" "$hist" >/dev/null 2>&1; then
      return 0
    fi
  done
  return 1
}

# Named checks the LAB_QUESTIONs call. Each passes if the learner ran the
# command in their terminal (history), so they progress on their own doing.
verifyRanInstall(){ ranCommand "dtwiz .*(version|install\.sh)|install\.sh" \
  && { printInfo "✅ You installed dtwiz"; return 0; } \
  || { printError "Run the dtwiz install one-liner in the Terminal first"; return 1; }; }
verifyRanStatus(){ ranCommand "dtwiz +status" \
  && { printInfo "✅ You ran 'dtwiz status'"; return 0; } \
  || { printError "Run 'dtwiz status' in the Terminal first"; return 1; }; }
verifyRanAnalyze(){ ranCommand "dtwiz +analyze" \
  && { printInfo "✅ You ran 'dtwiz analyze'"; return 0; } \
  || { printError "Run 'dtwiz analyze' in the Terminal first"; return 1; }; }
verifyRanRecommend(){ ranCommand "dtwiz +recommend" \
  && { printInfo "✅ You ran 'dtwiz recommend'"; return 0; } \
  || { printError "Run 'dtwiz recommend' in the Terminal first"; return 1; }; }
verifyRanDemo(){ ranCommand "dtwiz +install +demo" \
  && { printInfo "✅ You deployed the schnitzel demo"; return 0; } \
  || { printError "Run 'dtwiz install demo --experimental --yes' first"; return 1; }; }

# Make dtwiz visible in non-interactive shells too: the installer may land in
# ~/bin, which login shells add to PATH but plain `zsh -c` does not.
_dtwizPath(){
  command -v dtwiz >/dev/null 2>&1 && return 0
  [ -x "$HOME/bin/dtwiz" ] && export PATH="$HOME/bin:$PATH" && return 0
  [ -x /usr/local/bin/dtwiz ] && return 0
  return 1
}

# ----------------------------------------------------------------------
# Section 01 - Install the dtwiz CLI
# ----------------------------------------------------------------------
installDtwiz(){
  printInfoSection "Summoning the dtwiz CLI (dynatrace-oss/dtwiz)"
  if _dtwizPath; then
    printInfo "dtwiz already installed: $(dtwiz version 2>/dev/null | head -1)"
    return 0
  fi
  curl -sSL "$DTWIZ_INSTALL_URL" | sh
  _dtwizPath || { printError "dtwiz not found after install"; return 1; }
  printInfo "dtwiz installed: $(dtwiz version 2>/dev/null | head -1)"
}

isDtwizInstalled(){
  _dtwizPath || { printError "dtwiz is not installed - run installDtwiz (or the install one-liner)"; return 1; }
  dtwiz version
}

# ----------------------------------------------------------------------
# Section 02 - Connect & analyze  (platform-token-native)
# ----------------------------------------------------------------------
# The lab injects BOTH the tenant URL and a PLATFORM token automatically:
#   DT_ENVIRONMENT      - your tenant URL (dtwiz reads it from the environment)
#   DT_PLATFORM_TOKEN   - a platform token (dt0s16); dtwiz reads it from the
#                         environment too, so `dtwiz status/analyze/recommend/
#                         watch/install` all just work with NO --access-token.
# This is the platform-token-native path Dynatrace is standardizing on
# (classic dt0c01 tokens are being deprecated). Nothing to export by hand.
dtwizConnect(){
  isDtwizInstalled >/dev/null || return 1
  printInfoSection "Checking the connection to $DT_ENVIRONMENT"
  dtwiz status
}

analyzeSystem(){
  isDtwizInstalled >/dev/null || return 1
  printInfoSection "dtwiz gazes upon the system (dtwiz analyze)"
  dtwiz analyze
}

# The analyze output must at least detect the container's Docker runtime.
isAnalyzeWorking(){
  isDtwizInstalled >/dev/null || return 1
  dtwiz analyze 2>&1 | grep -qi "docker" \
    && { printInfo "dtwiz analyze detects the environment"; return 0; } \
    || { printError "dtwiz analyze did not report the environment"; return 1; }
}

# ----------------------------------------------------------------------
# Section 04 - Deploy the schnitzel demo app (platform-token tier)
# ----------------------------------------------------------------------
# `dtwiz install demo` and `dtwiz watch` use the Dynatrace platform APIs, so
# they require a platform token (dt0s16) in DT_PLATFORM_TOKEN. The lab only
# injects a Classic access token - the demo tier is skipped cleanly when the
# platform token is absent so the training stays completable everywhere.
# ----------------------------------------------------------------------
# dtwiz install kubernetes — deploy the Operator, then make it k3d-clean
# ----------------------------------------------------------------------
# `dtwiz install kubernetes` deploys the Dynatrace Operator + a DynaKube with
# KSPM (Kubernetes Security Posture Management) enabled by default. KSPM's
# node-config-collector DaemonSet needs REAL node host access (it mounts the
# host filesystem to run CIS/security benchmarks) — impossible on k3d, whose
# "nodes" are containers — so that one pod sits in ContainerCreating forever
# and dtwiz's own wait eventually times out even though the operator is up.
# On k3d we simply remove KSPM: it isn't what this training teaches, and it
# can't work here. Everything else (operator, ActiveGate, OTel collector,
# code injection) stays fully functional.
installDtwizKubernetes(){
  isDtwizInstalled >/dev/null || return 1
  printInfoSection "Deploying the Dynatrace Operator (dtwiz install kubernetes)"
  dtwiz install kubernetes --yes < /dev/null
  patchDynakubeDisableKspm
}

# Remove the kspm block from every DynaKube so the operator drops the stuck
# node-config-collector DaemonSet. Idempotent; safe to run more than once.
patchDynakubeDisableKspm(){
  command -v kubectl >/dev/null 2>&1 || { printWarn "kubectl not found — skipping KSPM patch"; return 0; }
  local dk patched=0
  for dk in $(kubectl -n dynatrace get dynakube -o name 2>/dev/null); do
    if kubectl -n dynatrace get "$dk" -o jsonpath='{.spec.kspm}' 2>/dev/null | grep -q .; then
      kubectl -n dynatrace patch "$dk" --type=json \
        -p='[{"op":"remove","path":"/spec/kspm"}]' >/dev/null 2>&1 && patched=1
      printInfo "KSPM removed from $dk (not supported on k3d container nodes)"
    fi
  done
  if [ "$patched" = "1" ]; then
    # Give the operator a moment to reconcile the DaemonSet away.
    local i=0
    while [ "$i" -lt 12 ]; do
      kubectl -n dynatrace get pods --no-headers 2>/dev/null | grep -q node-config || {
        printInfo "✅ node-config-collector removed — cluster is k3d-clean"; return 0; }
      i=$((i + 1)); sleep 5
    done
    printInfo "KSPM patched; collector teardown still in progress (harmless)"
  else
    printInfo "No KSPM block present — nothing to patch"
  fi
  return 0
}

isKspmDisabled(){
  command -v kubectl >/dev/null 2>&1 || { printInfo "kubectl not present — check skipped"; return 0; }
  # No dynakube at all (e.g. demo-only path) → nothing to assert.
  kubectl -n dynatrace get dynakube -o name >/dev/null 2>&1 || { printInfo "No DynaKube — step not applicable"; return 0; }
  if kubectl -n dynatrace get pods --no-headers 2>/dev/null | grep -q node-config; then
    printError "node-config-collector still present — run patchDynakubeDisableKspm"; return 1
  fi
  printInfo "✅ No stuck node-config-collector — KSPM cleanly disabled"; return 0
}

# ----------------------------------------------------------------------
# OpenTelemetry — verify the schnitzel spans landed in Grail
# ----------------------------------------------------------------------
# The schnitzel demo is instrumented with OpenTelemetry and ships OTLP spans
# straight to the tenant — no OneAgent, no operator. In Dynatrace those spans
# are first-class Grail records you query with DQL (`fetch spans`). This helper
# proves the end-to-end OTel pipeline (app → OTLP → Grail) by querying the
# tenant for recent schnitzel spans, using the injected platform token.
otelTracesQuery(){ printf 'fetch spans, from:now()-15m\n| filter in(service.name, {"frontend","order","delivery","loadgenerator"}) or contains(service.name, "schnitzel")\n| summarize spans = count()'; }

# Run a DQL query against Grail and return the record count. The query:execute
# API is ASYNC: the first POST usually returns {state:RUNNING, requestToken};
# you then poll query:poll until state==SUCCEEDED. (A single POST that ignores
# the token will always read zero — the classic gotcha.)
_grailCount(){
  local dql="$1" body resp state token i=0
  body=$(printf '%s' "$dql" | python3 -c 'import json,sys; print(json.dumps({"query": sys.stdin.read()}))')
  resp=$(curl -s -X POST "${DT_ENVIRONMENT%/}/platform/storage/query/v1/query:execute" \
    -H "Authorization: Bearer $DT_PLATFORM_TOKEN" -H "Content-Type: application/json" -d "$body" 2>/dev/null)
  state=$(printf '%s' "$resp" | python3 -c 'import json,sys;print(json.load(sys.stdin).get("state",""))' 2>/dev/null)
  if [ "$state" = "SUCCEEDED" ]; then
    printf '%s' "$resp" | python3 -c 'import json,sys;r=(json.load(sys.stdin).get("result") or {}).get("records",[]);print(r[0].get("spans",len(r)) if r else 0)' 2>/dev/null; return 0
  fi
  token=$(printf '%s' "$resp" | python3 -c 'import json,sys;print(json.load(sys.stdin).get("requestToken",""))' 2>/dev/null)
  [ -n "$token" ] || { echo 0; return 0; }
  while [ "$i" -lt 15 ]; do
    resp=$(curl -s -G "${DT_ENVIRONMENT%/}/platform/storage/query/v1/query:poll" \
      -H "Authorization: Bearer $DT_PLATFORM_TOKEN" --data-urlencode "request-token=$token" 2>/dev/null)
    state=$(printf '%s' "$resp" | python3 -c 'import json,sys;print(json.load(sys.stdin).get("state",""))' 2>/dev/null)
    if [ "$state" = "SUCCEEDED" ]; then
      printf '%s' "$resp" | python3 -c 'import json,sys;r=(json.load(sys.stdin).get("result") or {}).get("records",[]);print(r[0].get("spans",len(r)) if r else 0)' 2>/dev/null; return 0
    fi
    i=$((i + 1)); sleep 2
  done
  echo 0
}

verifyOtelTracesInGrail(){
  if [ -z "${DT_PLATFORM_TOKEN:-}" ]; then
    printInfo "No DT_PLATFORM_TOKEN — OTel-trace check skipped (OK)."; return 0
  fi
  printInfoSection "Querying Grail for schnitzel OpenTelemetry spans"
  local count i=0
  while [ "$i" -lt 12 ]; do
    count=$(_grailCount "$(otelTracesQuery)")
    if [ "${count:-0}" -gt 0 ] 2>/dev/null; then
      printInfo "✅ $count schnitzel OpenTelemetry span(s) in Grail — the OTLP pipeline works end-to-end"; return 0
    fi
    i=$((i + 1)); printInfo "spans not in Grail yet ($i/12) — OTLP ingest takes a minute, waiting 15s"; sleep 15
  done
  printWarn "No schnitzel spans in Grail yet — give ingest more time, or check the demo is running (isDemoRunning)"
  return 1
}

deployDtwizDemo(){
  isDtwizInstalled >/dev/null || return 1
  if [ -z "${DT_PLATFORM_TOKEN:-}" ]; then
    printWarn "DT_PLATFORM_TOKEN is not set - the demo installer needs a platform token (dt0s16)."
    printInfo "This lab injects one automatically; if it is missing, tell your instructor."
    return 0
  fi
  printInfoSection "Deploying the schnitzel demo app (dtwiz install demo)"
  # dtwiz extracts the demo under $TMPDIR and rename()s it into the current
  # directory - in Codespaces /tmp and /workspaces are different mounts, so the
  # rename fails with "invalid cross-device link" unless TMPDIR shares the
  # workspace mount. stdin from /dev/null skips the interactive watch screen.
  mkdir -p "${REPO_PATH:-.}/.dtwiz-tmp"
  TMPDIR="${REPO_PATH:-.}/.dtwiz-tmp" dtwiz install demo --experimental --yes < /dev/null

  # dtwiz extracts + OTel-instruments the app and starts a local OTel collector,
  # but it does NOT keep the four schnitzel services running (they exit with the
  # installer). Start them in the background so orders keep flowing and OTLP
  # spans keep arriving in Grail — this is the "app → OTLP → Dynatrace" pipeline
  # the training demonstrates. Auto-instrument with opentelemetry-instrument when
  # present (dtwiz installs it); fall back to plain python if not.
  startSchnitzel
}

# Start the four schnitzel services (order, delivery, frontend, loadgenerator)
# in the background with OpenTelemetry auto-instrumentation. Idempotent.
startSchnitzel(){
  local dir="${REPO_PATH:-.}/schnitzel"
  [ -d "$dir" ] || { printWarn "schnitzel/ not found — run 'dtwiz install demo' first"; return 1; }
  if pgrep -f "schnitzel/(order|delivery|frontend|loadgenerator)/app.py" >/dev/null 2>&1; then
    printInfo "schnitzel services already running"; return 0
  fi
  printInfoSection "Starting the schnitzel services (OTel-instrumented)"
  # The image ships python3 (not always a bare `python`); pick whatever exists.
  local py; py="$(command -v python3 || command -v python)"
  [ -n "$py" ] || { printError "no python interpreter found"; return 1; }
  # Install the app deps + the OpenTelemetry auto-instrumentation toolchain
  # (pip may need --break-system-packages on a PEP-668 externally-managed image).
  local pipflags="--quiet"
  "$py" -m pip install $pipflags flask >/dev/null 2>&1 \
    || pipflags="--quiet --break-system-packages"
  "$py" -m pip install $pipflags -r "$dir/requirements.txt" \
    opentelemetry-distro opentelemetry-exporter-otlp >/dev/null 2>&1
  "$py" -m opentelemetry.instrumentation.bootstrap -a install >/dev/null 2>&1 \
    || opentelemetry-bootstrap -a install >/dev/null 2>&1 || true
  # pip may drop the OTel console scripts in ~/.local/bin — ensure it's on PATH.
  export PATH="$HOME/.local/bin:$PATH"
  # dtwiz points the app at its local collector via OTEL_* env; default to the
  # standard local OTLP endpoint if dtwiz didn't export one into this shell.
  : "${OTEL_EXPORTER_OTLP_ENDPOINT:=http://localhost:4318}"
  export OTEL_EXPORTER_OTLP_ENDPOINT OTEL_TRACES_EXPORTER=otlp OTEL_METRICS_EXPORTER=otlp OTEL_LOGS_EXPORTER=otlp
  local runner="$py"
  command -v opentelemetry-instrument >/dev/null 2>&1 && runner="opentelemetry-instrument $py"
  local svc
  for svc in order delivery frontend loadgenerator; do
    [ -f "$dir/$svc/app.py" ] || continue
    ( cd "$dir/$svc" && OTEL_SERVICE_NAME="$svc" nohup $runner app.py \
        >"/tmp/schnitzel-$svc.log" 2>&1 & )
    sleep 1
  done
  sleep 4
  printInfo "schnitzel services launched (logs in /tmp/schnitzel-*.log)"
}

# Demo up? Check the actual service processes (not a name that never matches).
waitForDemoRunning(){
  printInfoSection "Waiting for the schnitzel demo services"
  local i=0
  while [ "$i" -lt 24 ]; do
    if pgrep -f "schnitzel/(order|delivery|frontend|loadgenerator)/app.py" >/dev/null 2>&1; then
      printInfo "schnitzel services are running"; return 0
    fi
    i=$((i + 1)); printInfo "services not up yet ($i/24), waiting 5s"; sleep 5
  done
  printError "schnitzel services not found in time"; return 1
}

isDemoRunning(){
  # Deployment proof = the schnitzel/ dir exists AND its services are running.
  if [ -d "${REPO_PATH:-.}/schnitzel" ] \
     && pgrep -f "schnitzel/(order|delivery|frontend|loadgenerator)/app.py" >/dev/null 2>&1; then
    printInfo "schnitzel demo is running"; return 0
  fi
  printError "schnitzel demo is not running - run deployDtwizDemo (or startSchnitzel)"; return 1
}

# Section-04 check: the schnitzel demo was DEPLOYED (dtwiz extracted the app +
# set up OpenTelemetry). Deployment proof = the schnitzel/ directory exists;
# the services running and spans landing in Grail are the richer signal but
# are best-effort (OTLP ingest lag, and a shared training tenant carries other
# apps' spans too). Skips cleanly if no platform token is available.
verifyDemoOrSkip(){
  if [ -z "${DT_PLATFORM_TOKEN:-}" ]; then
    printInfo "No DT_PLATFORM_TOKEN in this environment - demo tier skipped (OK)."
    return 0
  fi
  if [ -d "${REPO_PATH:-.}/schnitzel" ]; then
    printInfo "✅ schnitzel demo deployed (dtwiz install demo extracted + instrumented it)"
    isDemoRunning >/dev/null 2>&1 && printInfo "   …and its services are running"
    return 0
  fi
  printError "schnitzel/ not found - run deployDtwizDemo (dtwiz install demo)"
  return 1
}

# ----------------------------------------------------------------------
# Section 04 - Recommend, watch & status
# ----------------------------------------------------------------------
dtwizRecommend(){
  isDtwizInstalled >/dev/null || return 1
  printInfoSection "Asking the wizard for advice (dtwiz recommend)"
  dtwiz recommend
}

isRecommendWorking(){
  isDtwizInstalled >/dev/null || return 1
  dtwiz recommend 2>&1 | grep -qi "recommend" \
    && { printInfo "dtwiz recommend produced recommendations"; return 0; } \
    || { printError "dtwiz recommend produced no output"; return 1; }
}

# ----------------------------------------------------------------------
# Cleanup
# ----------------------------------------------------------------------
removeDtwizDemo(){
  isDtwizInstalled >/dev/null || return 1
  printInfoSection "Uninstalling the schnitzel demo app"
  dtwiz uninstall demo --experimental --yes 2>/dev/null || true
  pkill -f "schnitzel" 2>/dev/null || true
  printInfo "Demo removed"
}
