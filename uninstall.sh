#!/bin/bash
set -euo pipefail

if [ "$(command -v bash)" != "/usr/bin/bash" ]; then
  echo "[ERROR] This script requires bash at /usr/bin/bash"
  exit 1
fi

################################################################################
# Copyright (c) 2026 Appoena. All rights reserved.
# ...
################################################################################

# Solaris uninstall.sh script for Appoena Solaris Agent
# This script deletes the agent and any other references or files.
# IMPORTANT: This uninstaller will not preserve any configurations.

BASE_DIR="/etc/appoena"
TEMP_DIR="/tmp/appoena"
MANIFEST_DIR="/var/svc/manifest/appoena"
SERVICE_FMRI="svc:/appoena/solaris_agent:default"

log() { printf "[uninstall] %s\n" "$*"; }
warn() { printf "[uninstall][WARN] %s\n" "$*" >&2; }
err() { printf "[uninstall][ERROR] %s\n" "$*" >&2; }

require_root() {
  if [ "$(id -u)" != "0" ]; then
    err "This script must run as root."
    exit 1
  fi
}

disable_smf_service() {
  if svcs "$SERVICE_FMRI" >/dev/null 2>&1; then
    log "Disabling SMF service..."
    svcadm disable -s "$SERVICE_FMRI" || warn "Could not disable service — may already be stopped"
    svccfg delete -f "$SERVICE_FMRI" || warn "Could not delete service — may already be removed"
  else
    warn "SMF service not found, skipping disable"
  fi
}

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

  # Clean up PATH in /etc/profile if added manually
  # Solaris sed does not support -i, use a temp file
  if grep -q "appoena/solaris/scripts" /etc/profile 2>/dev/null; then
    tmp=$(mktemp /tmp/profile.XXXXXX)
    grep -v "appoena/solaris/scripts" /etc/profile > "$tmp"
    cp "$tmp" /etc/profile
    rm -f "$tmp"
    log "Removed PATH modification from /etc/profile"
  fi
}

verify_removal() {
  svcadm restart svc:/system/manifest-import:default || warn "Could not restart manifest-import"

  if svcs "$SERVICE_FMRI" >/dev/null 2>&1; then
    err "SMF service still exists: $SERVICE_FMRI"
    exit 1
  else
    log "SMF service removed successfully"
  fi
}

main() {
  log "Starting Appoena Solaris Agent uninstallation"
  require_root
  disable_smf_service
  delete_directories
  verify_removal
  log "Uninstallation complete."
}

main "$@"