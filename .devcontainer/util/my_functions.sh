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
# Section 02 - Connect & analyze
# ----------------------------------------------------------------------
# The lab injects DT_ENVIRONMENT + DT_OPERATOR_TOKEN (a Classic API token).
# dtwiz reads DT_ENVIRONMENT from the environment; the Classic token must be
# passed explicitly via --access-token (dtwiz refuses to read it from env on
# purpose). A platform token (dt0s16) unlocks `dtwiz watch` - see Section 04.
dtwizConnect(){
  isDtwizInstalled >/dev/null || return 1
  printInfoSection "Checking the connection to $DT_ENVIRONMENT"
  dtwiz status --access-token "$DT_OPERATOR_TOKEN"
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
deployDtwizDemo(){
  isDtwizInstalled >/dev/null || return 1
  if [ -z "${DT_PLATFORM_TOKEN:-}" ]; then
    printWarn "DT_PLATFORM_TOKEN is not set - the demo installer needs a platform token (dt0s16)."
    printInfo "Export one (Settings -> Platform tokens in your tenant) and re-run, or skip this tier."
    return 0
  fi
  printInfoSection "Deploying the schnitzel demo app (dtwiz install demo)"
  # dtwiz extracts the demo under $TMPDIR and rename()s it into the current
  # directory - in Codespaces /tmp and /workspaces are different mounts, so the
  # rename fails with "invalid cross-device link" unless TMPDIR shares the
  # workspace mount. stdin from /dev/null skips the interactive watch screen.
  mkdir -p "${REPO_PATH:-.}/.dtwiz-tmp"
  TMPDIR="${REPO_PATH:-.}/.dtwiz-tmp" dtwiz install demo --experimental --yes < /dev/null
}

# Demo processes alive? (bounded wait - the app takes a moment to boot).
waitForDemoRunning(){
  printInfoSection "Waiting for the schnitzel demo app processes"
  local i=0
  while [ "$i" -lt 24 ]; do
    if pgrep -f "schnitzel" >/dev/null 2>&1; then
      printInfo "schnitzel demo is running"; return 0
    fi
    i=$((i + 1)); printInfo "demo not up yet ($i/24), waiting 5s"; sleep 5
  done
  printError "schnitzel demo processes not found in time"; return 1
}

isDemoRunning(){
  pgrep -f "schnitzel" >/dev/null 2>&1 \
    && { printInfo "schnitzel demo is running"; return 0; } \
    || { printError "schnitzel demo is not running - run deployDtwizDemo"; return 1; }
}

# Section-04 check: demo running, OR cleanly skipped because no platform token
# is available in this environment (keeps the lab completable with only the
# injected Classic access token).
verifyDemoOrSkip(){
  if [ -z "${DT_PLATFORM_TOKEN:-}" ]; then
    printInfo "No DT_PLATFORM_TOKEN in this environment - demo tier skipped (OK)."
    return 0
  fi
  waitForDemoRunning
}

# ----------------------------------------------------------------------
# Section 04 - Recommend, watch & status
# ----------------------------------------------------------------------
dtwizRecommend(){
  isDtwizInstalled >/dev/null || return 1
  printInfoSection "Asking the wizard for advice (dtwiz recommend)"
  dtwiz recommend --access-token "$DT_OPERATOR_TOKEN"
}

isRecommendWorking(){
  isDtwizInstalled >/dev/null || return 1
  dtwiz recommend --access-token "$DT_OPERATOR_TOKEN" 2>&1 | grep -qi "recommend" \
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
