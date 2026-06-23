#!/bin/sh
set -e

################################################################################
# Copyright (c) 2026 Appoena. All rights reserved.
#
# This script is the confidential and proprietary property of Appoena.
#
# Unauthorized use, copying, modification, reserve engineering, or distribution
# of this software, in whole or in part, via any medium, is strictly prohibited.
#
# This software is provided under license and may be used only in accordance
# with the terms of such license.
################################################################################

################################################################################
# Solaris semiauto-install.sh script for Appoena Solaris Agent.
#
# This script prepares the filesystem, deploys the agent, and installs the SMF manifest.
# It expects to be run on a Solaris host with sufficient privileges.
#
# IMPORTANT: This installer requires the solaris-agent.zip to be present in /tmp/appoena
# Installer Version: 1.0.0
################################################################################

# Verify we are running under sh
if test -n "${BASH_VERSION:-}"; then
  echo "[install][WARN] Running under bash — consider using the bash version of this script."
fi

BASE_DIR="/etc/appoena"
AGENT_SUBDIR="solaris"
AGENT_DIR="$BASE_DIR/$AGENT_SUBDIR"
SCRIPTS_DIR="$AGENT_DIR/scripts"
RUN_DIR="$AGENT_DIR/run"

TEMP_DIR="/tmp/appoena"

MANIFEST_NAME="solaris_agent.xml"
MANIFEST_DIR="/var/svc/manifest/appoena"
SERVICE_FMRI="svc:/appoena/solaris_agent:default"

AGENT_JAR="agent.jar"
TARBALL_NAME="solaris-agent.zip"

log()  { printf "[install] %s\n" "$*"; }
warn() { printf "[install][WARN] %s\n" "$*" >&2; }
err()  { printf "[install][ERROR] %s\n" "$*" >&2; }

################################################################################
# Root check
################################################################################

require_root() {
  if [ "$(id -u)" != "0" ]; then
    err "This script must be run as root."
    exit 1
  fi
}

################################################################################
# Filesystem preparation
################################################################################

prepare_fs() {
  log "Preparing filesystem..."
  mkdir -p "$AGENT_DIR"
  mkdir -p "$SCRIPTS_DIR"
  mkdir -p "$RUN_DIR"
  mkdir -p "$MANIFEST_DIR"
  log "Filesystem ready."
}

################################################################################
# Dependency check
################################################################################

install_unzip() {
  if command -v unzip >/dev/null 2>&1; then
    return
  fi

  log "unzip not found. Attempting installation..."

  if command -v pkg >/dev/null 2>&1; then
    if ! pkg install unzip; then
      err "Failed installing unzip."
      exit 1
    fi
  else
    err "pkg not available. Install unzip manually."
    exit 1
  fi
}

################################################################################
# Verify zip is present
################################################################################

verify_zip() {
  if [ ! -f "$TEMP_DIR/$TARBALL_NAME" ]; then
    err "$TARBALL_NAME not found in $TEMP_DIR"
    err "Please copy $TARBALL_NAME to $TEMP_DIR and re-run."
    exit 1
  fi
}

################################################################################
# Extract
################################################################################

extract_tarball() {
  log "Extracting bundle..."
  if ! unzip "$TEMP_DIR/$TARBALL_NAME" -d "$TEMP_DIR"; then
    err "Extraction failed."
    exit 1
  fi
}

################################################################################
# Deploy
################################################################################

deploy_assets() {
  log "Deploying files..."

  # agent.jar
  if [ -f "$TEMP_DIR/$AGENT_JAR" ]; then
    cp "$TEMP_DIR/$AGENT_JAR" "$AGENT_DIR/$AGENT_JAR"
    chmod +x "$AGENT_DIR/$AGENT_JAR"
  else
    err "agent.jar not found in archive"
    exit 1
  fi

  # run.sh
  if [ -f "$TEMP_DIR/run.sh" ]; then
    cp "$TEMP_DIR/run.sh" "$AGENT_DIR/run.sh"
    chmod +x "$AGENT_DIR/run.sh"
  else
    err "run.sh not found in archive"
    exit 1
  fi

  # scripts/
  if [ -d "$TEMP_DIR/scripts" ]; then
    cp -rp "$TEMP_DIR/scripts/." "$SCRIPTS_DIR/"
    chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null || true
  else
    err "scripts/ folder not found in archive"
    exit 1
  fi

  # conf.example.yaml — only if conf.yaml doesn't exist yet
  if [ ! -f "$AGENT_DIR/conf.yaml" ]; then
    if [ -f "$TEMP_DIR/conf.example.yaml" ]; then
      cp "$TEMP_DIR/conf.example.yaml" "$AGENT_DIR/conf.yaml"
      log "Default conf.yaml deployed — configure before starting the service"
    else
      warn "conf.example.yaml not found — configure $AGENT_DIR/conf.yaml manually"
    fi
  else
    log "Existing conf.yaml preserved"
  fi

  # SMF manifest
  if [ -f "$TEMP_DIR/$MANIFEST_NAME" ]; then
    cp "$TEMP_DIR/$MANIFEST_NAME" "$MANIFEST_DIR/$MANIFEST_NAME"
  else
    err "SMF manifest not found in archive"
    exit 1
  fi

  # PATH setup
  log "Configuring PATH..."
  if [ -d "/etc/profile.d" ]; then
    printf "export PATH=\$PATH:%s\n" "$SCRIPTS_DIR" > /etc/profile.d/appoena-solaris.sh
    chmod +x /etc/profile.d/appoena-solaris.sh
  else
    grep "$SCRIPTS_DIR" /etc/profile >/dev/null 2>&1 || \
      printf "export PATH=\$PATH:%s\n" "$SCRIPTS_DIR" >> /etc/profile
  fi

  # SMF import
  if command -v svccfg >/dev/null 2>&1; then
    log "Importing SMF manifest..."
    svccfg import "$MANIFEST_DIR/$MANIFEST_NAME"
  else
    warn "svccfg not available"
  fi
}

################################################################################
# Cleanup
################################################################################

clean() {
  log "Cleaning temporary files..."
  rm -rf "$TEMP_DIR"
}

################################################################################
# Main
################################################################################

main() {
  log "Starting Appoena Solaris Agent installation"
  require_root
  install_unzip
  verify_zip
  prepare_fs
  extract_tarball
  deploy_assets
  clean

  log "Installation complete."
  log "--------------------------------------------------------"
  log "NEXT STEPS:"
  log "1. Configure $AGENT_DIR/conf.yaml"
  log "2. Enable service:"
  log "   svcadm enable $SERVICE_FMRI"
  log "3. Check logs via logs.sh"
  log "--------------------------------------------------------"
}

main "$@"