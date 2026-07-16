#!/bin/bash
# DTWiz 101 integration smoke test.
# This lab does NOT pre-install the dtwiz CLI - the learner installs it in
# Section 01. So the plain integration-test only asserts that the toolchain
# and framework helpers are present. Full end-to-end coverage (installDtwiz ->
# analyzeSystem -> deployDtwizDemo -> dtwizRecommend) is exercised by the
# Orbital app-layer-test job, which runs every section's LAB_SOLUTION headless.
source .devcontainer/util/source_framework.sh

printInfoSection "Running integration smoke tests for $RepositoryName"

_fail=0
for tool in curl python3; do
  if command -v "$tool" >/dev/null 2>&1; then
    printInfo "found: $tool"
  else
    printError "missing tool: $tool"; _fail=1
  fi
done

# Framework helper must be loadable and every lab spell defined. This is the
# cheap guard that a rename in my_functions.sh doesn't silently break a
# LAB_QUESTION/LAB_SOLUTION that references the function by name.
_spells="installDtwiz isDtwizInstalled dtwizConnect analyzeSystem dtwizRecommend \
  deployDtwizDemo verifyDemoOrSkip removeDtwizDemo installDtwizKubernetes \
  patchDynakubeDisableKspm isKspmDisabled verifyOtelTracesInGrail \
  verifyRanInstall verifyRanStatus verifyRanAnalyze verifyRanRecommend verifyRanDemo"
_missing=""
for _fn in $_spells; do
  type "$_fn" >/dev/null 2>&1 || _missing="$_missing $_fn"
done
if [ -z "$_missing" ]; then
  printInfo "All DTWiz lab spells are defined ($(echo $_spells | wc -w) functions)"
else
  printError "DTWiz lab helpers missing from my_functions.sh:$_missing"; _fail=1
fi

# KSPM patch + OTel-trace checks must be safe no-ops without a cluster / token
# (so they never wedge the smoke test on a plain container).
if isKspmDisabled >/dev/null 2>&1; then
  printInfo "isKspmDisabled is a safe no-op without a cluster"
else
  printError "isKspmDisabled failed on a cluster-less container"; _fail=1
fi

# The install one-liner must actually work in this image (fast, ~seconds).
if installDtwiz >/dev/null 2>&1 && isDtwizInstalled >/dev/null 2>&1; then
  printInfo "dtwiz installs and answers to 'dtwiz version'"
else
  printError "dtwiz install failed"; _fail=1
fi

if [ "$_fail" -ne 0 ]; then
  printError "Integration smoke test FAILED"; exit 1
fi
printInfoSection "Integration smoke test passed"
