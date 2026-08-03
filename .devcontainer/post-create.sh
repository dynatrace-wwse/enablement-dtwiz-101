#!/bin/bash
#loading functions to script
export SECONDS=0
source .devcontainer/util/source_framework.sh

# Validate the Dynatrace credentials declared in devcontainer.json (secrets).
# Codespaces silently omits unset secrets, so without this the container can
# half-create and later dtwiz steps fail with no clear cause. Fail loudly
# instead. The validator logs missing vars by name only (never the values).

# TODO: Add the DT_PLATFORM_TOKEN as needed variable we dont need here the other tokens. WHat are the scopes?
# [] Update devcontainer.json with token
# [] do we need enablement.yaml? Where is it used? how with other repos?
# [] rfe - enableMCP is only for VSCode usecase

# Why do we have ,my.dynatrace.enablements -> service in tenant. 
# WHy does it say that the OneAgent is running? -> Bug in dtwiz 

# FIX: When installing k8s via dtwiz the k3d-enablement-node-config-collector-4ggvm is in containerCreatint and cant go up due volume mount fail. Can we solve this via configuration?

#   Normal   Scheduled    11m                   default-scheduler  Successfully assigned dynatrace/k3d-enablement-node-config-collector-4ggvm to k3d-enablement-server-0                                                                                      │
#   Warning  FailedMount  8m59s (x9 over 11m)   kubelet            MountVolume.SetUp failed for volume "node-path-5" : hostPath type check failed: /sys/kernel/security/apparmor is not a directory                                                           │
#   Warning  FailedMount  4m55s (x11 over 11m)  kubelet            MountVolume.SetUp failed for volume "node-path-6" : hostPath type check failed: /usr/lib/systemd/system is not a directory                                                                 │
#   Warning  FailedMount  51s (x13 over 11m)    kubelet            MountVolume.SetUp failed for volume "node-path-1" : hostPath type check failed: /boot is not a directory                                                                                   │                                                                                                                                                                                 


#variablesNeeded DT_ENVIRONMENT:true DT_OPERATOR_TOKEN:true DT_INGEST_TOKEN:false || exit 1

setUpTerminal

# The dtwiz CLI is NOT pre-installed on purpose - installing it is Section 01
# of the lab (the learner runs the official install one-liner, or the
# LAB_SOLUTION does it for automated testing). We only prepare the terminal
# and the MkDocs training guide.

finalizePostCreation

printInfoSection "DTWiz 101 is ready. Open the training guide and start with Section 01 - Install dtwiz."
