#!/bin/bash
#loading functions to script
export SECONDS=0
source .devcontainer/util/source_framework.sh

# Validate the Dynatrace credentials declared in devcontainer.json (secrets).
# Codespaces silently omits unset secrets, so without this the container can
# half-create and later dtwiz steps fail with no clear cause. Fail loudly
# instead. The validator logs missing vars by name only (never the values).
variablesNeeded DT_ENVIRONMENT:true DT_OPERATOR_TOKEN:true DT_INGEST_TOKEN:false || exit 1

setUpTerminal

# The dtwiz CLI is NOT pre-installed on purpose - installing it is Section 01
# of the lab (the learner runs the official install one-liner, or the
# LAB_SOLUTION does it for automated testing). We only prepare the terminal
# and the MkDocs training guide.
bash .devcontainer/startup.sh

finalizePostCreation

printInfoSection "DTWiz 101 is ready. Open the training guide and start with Section 01 - Install dtwiz."
