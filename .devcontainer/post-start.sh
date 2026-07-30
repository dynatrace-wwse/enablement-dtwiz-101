#!/bin/bash
##############################################################
##  Runs every time the container starts (after post-create).
##  No MkDocs here: training content is delivered by the
##  Enablement App (imported docs) — the in-container guide
##  is not installed or served for bootcamp sessions.
##############################################################
source .devcontainer/util/source_framework.sh

printInfoSection "Your dev.container finished starting up"
