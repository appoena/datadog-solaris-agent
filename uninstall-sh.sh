#!/bin/sh
set -e

################################################################################
# Copyright (c) 2026 Appoena. All rights reserved.
#
# This script is the confidential and proprietary property of Appoena.
#
# Unauthorized use, copying, modification, reverse engineering, or distribution
# of this software, in whole or in part, via any medium, is strictly prohibited.
#
# This software is provided under license and may be used only in accordance
# with the terms of such license.
################################################################################

################################################################################
# Solaris uninstall-sh.sh script for Appoena Solaris Agent.
#
# This script disables the SMF service, removes all agent files and directories.
# IMPORTANT: This uninstaller will not preserve any configurations.
#
# Installer Version: 1.0.0
################################################################################

if test -n "${BASH_VERSION:-}"; then
  echo "[uninstall][WARN] Running under bash — consider using uninstall.sh instead."
fi

BASE_DIR="/etc/appoena"
TEMP_DIR="/tmp/appoena"
MANIFEST_DIR="/var/svc/manifest/appoena"
SERVICE_FMRI="svc:/appoena/solaris_agent:default"

log()  { printf "[uninstall] %s\n" "$*"; }
warn() { printf "[uninstall][WARN] %s\n" "$*" >&2; }
err()  { printf "[uninstall][ERROR] %s\n" "$*" >&2; }

################################################################################
# Root check
################################################################################

require_root() {
  if [ "$(id -u)" != "0" ]; then
    err "This script must run as root."
    exit 1
  fi
}

################################################################################
# Disable SMF service
################################################################################

disable_smf_service() {
  if svcs "$SERVICE_FMRI" >/dev/null 2>&1; then
    log "Disabling SMF service..."
    svcadm disable -s "$SERVICE_FMRI" || warn "Could not disable service — may already be stopped"
    svccfg delete -f "$SERVICE_FMRI" || warn "Could not delete service — may already be removed"
  else
    warn "SMF service not found, skipping disable"
  fi
}

################################################################################
# Delete directories and files
################################################################################

delete_directories() {
  rm -rf "$BASE_DIR"
  log "Deleted $BASE_DIR"

  rm -rf "$MANIFEST_DIR"
  log "Deleted $MANIFEST_DIR"

  rm -rf "$TEMP_DIR"
  log "Deleted $TEMP_DIR"

  if [ -f "/etc/profile.d/appoena-solaris.sh" ]; then
    rm -f "/etc/profile.d/appoena-solaris.sh"
    log "Deleted /etc/profile.d/appoena-solaris.sh"
  fi

  # Clean up PATH in /etc/profile — Solaris sed has no -i, use temp file
  if grep -q "appoena/solaris/scripts" /etc/profile 2>/dev/null; then
    tmp=$(mktemp /tmp/profile.XXXXXX)
    grep -v "appoena/solaris/scripts" /etc/profile > "$tmp"
    cp "$tmp" /etc/profile
    rm -f "$tmp"
    log "Removed PATH modification from /etc/profile"
  fi
}

##################################################