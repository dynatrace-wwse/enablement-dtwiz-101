#!/bin/bash
# DTWiz 101 startup — serve the MkDocs training guide.
# Called from post-create.sh (first creation) and post-start.sh (every resume).
# The dtwiz CLI itself is NOT installed here: installing it is Section 01 of
# the lab (the learner runs the official one-liner, or the LAB_SOLUTION does,
# for automated testing). This script only makes sure the guide is up.
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

ensureMkdocs
