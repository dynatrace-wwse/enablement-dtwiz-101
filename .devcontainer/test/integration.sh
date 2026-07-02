#!/bin/bash
# DTWiz 101 integration smoke test.
# This lab does NOT pre-deploy Kubernetes or the app - the learner installs them
# in Sections 01-03. So the plain integration-test only asserts that the toolchain
# and framework helpers are present. Full end-to-end coverage (conjureCluster ->
# deployTodoWizardApp -> summonDynatrace -> dispelChaos) is exercised by the
# Orbital app-layer-test job, which runs every section's LAB_SOLUTION headless.
source .devcontainer/util/source_framework.sh

printInfoSection "Running integration smoke tests for $RepositoryName"

_fail=0
# k3d is intentionally NOT preinstalled — installing the cluster IS Section 01
# (conjureCluster downloads it). Only the tools the image must ship are required.
for tool in kubectl helm; do
  if command -v "$tool" >/dev/null 2>&1; then
    printInfo "found: $tool"
  else
    printError "missing tool: $tool"; _fail=1
  fi
done
if command -v k3d >/dev/null 2>&1; then
  printInfo "found: k3d (optional — Section 01 installs it)"
else
  printInfo "k3d not present yet — installed by the lab in Section 01 (expected)"
fi

# Framework helper must be loadable and the lab spells defined.
if type conjureCluster >/dev/null 2>&1 && type dispelChaos >/dev/null 2>&1; then
  printInfo "DTWiz lab helpers are defined (conjureCluster, dispelChaos, ...)"
else
  printError "DTWiz lab helpers not sourced from my_functions.sh"; _fail=1
fi

if [ "$_fail" -ne 0 ]; then
  printError "Integration smoke test FAILED"; exit 1
fi
printInfoSection "Integration smoke test passed"
