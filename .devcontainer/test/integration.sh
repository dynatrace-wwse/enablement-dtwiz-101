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

# Framework helper must be loadable and the lab spells defined.
if type installDtwiz >/dev/null 2>&1 && type deployDtwizDemo >/dev/null 2>&1; then
  printInfo "DTWiz lab helpers are defined (installDtwiz, deployDtwizDemo, ...)"
else
  printError "DTWiz lab helpers not sourced from my_functions.sh"; _fail=1
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
