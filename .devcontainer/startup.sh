#!/bin/bash
# DTWiz 101 startup.
# IMPORTANT: unlike most labs, this training does NOT auto-start the Kubernetes
# cluster or deploy the app. Installing Kubernetes is Section 01 of the lab - the
# learner conjures the cluster themselves (or the LAB_SOLUTION does, for nightly
# automated testing). We only set up the terminal and the MkDocs training guide.
export SECONDS=0
source .devcontainer/util/source_framework.sh

ensureMkdocs(){
  if ! command -v mkdocs >/dev/null 2>&1; then
    installRunme
    printInfo "Installing MkDocs"
    pip install --break-system-packages -r docs/requirements/requirements-mkdocs.txt
  fi

  fetchMkdocsBase

  if curl -fsS http://127.0.0.1:8000 >/dev/null 2>&1; then
    printInfoSection "MkDocs already running"
    return 0
  fi

  exposeMkdocs
}

setUpTerminal
ensureMkdocs
finalizePostCreation

printInfoSection "DTWiz 101 is ready. Open the training guide and start with Section 01 - Install Kubernetes."
