#!/bin/bash
# Builds the environment the learner finds in step 1: a k3d Kubernetes cluster, named for
# this learner, already running and selected as the current kubectl context.
#
# Deliberately NOT done here: installing dtwiz and deploying Dynatrace. Installing dtwiz
# (step 2) and letting it deploy the Dynatrace Operator (step 5) is what the training teaches.
export SECONDS=0
source .devcontainer/util/source_framework.sh

setUpTerminal

# dtwiz reads DT_ENVIRONMENT and DT_PLATFORM_TOKEN from the environment. A missing token
# does not stop the build: steps 1, 3 and 4 work without one, and step 2's check names the
# missing token instead of failing somewhere later. Values are never printed.
variablesNeeded DT_ENVIRONMENT:true DT_PLATFORM_TOKEN:false

# The cluster runs before the learner arrives, under a per-learner name (dtwizK3dName),
# because dtwiz names the DynaKube - and so the cluster in the shared tenant - after it.
startDtwizCluster

mkdir -p "$DTWIZ_WORKDIR"

finalizePostCreation

printInfoSection "dtwiz 101 is ready: cluster $(dtwizClusterName) is running. Continue with step 1."
