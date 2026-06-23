#!/usr/bin/bash
set -e
set -u
set -o pipefail

if [ "$(command -v bash)" != "/usr/bin/bash" ]; then
  echo "[ERROR] This script requires bash at /usr/bin/bash"
  exit 1
fi

PATH=/usr/bin:/usr/sbin:/bin:/sbin
export PATH

################################################################################
# Appoena Solaris Agent Installer
################################################################################

BASE_DIR="/etc/appoena"
AGENT_SUBDIR="solaris"
AGENT_DIR="$BASE_DIR/$AGENT_SUBDIR"
SCRIPTS_DIR="$AGENT_DIR/scripts"
RUN_DIR="$AGENT_DIR/run"

REPO_OWNER="appoena"
REPO_NAME="datadog-solaris-agent"

VERSION=${1:-latest}

TEMP_DIR="/tmp/appoena"

MANIFEST_NAME="solaris_agent.xml"
MANIFEST_DIR="/var/svc/manifest/appoena"
SERVICE_FMRI="/appoena/solaris_agent:default"

AGENT_JAR="agent.jar"
TARBALL_NAME="solaris-agent.zip"

RELEASE_VERSION=""
DOWNLOAD_URL=""

################################################################################
# Logging
################################################################################

log() { printf "[install] %s\n" "$*"; }
warn() { printf "[install][WARN] %s\n" "$*" >&2; }
err() { printf "[install][ERROR] %s\n" "$*" >&2; }

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
# Semver validation
################################################################################

is_valid_semver() {

  v=$1

  [ "$v" = "latest" ] && return 0

  v=${v%%+*}
  v=${v%%-*}

  oldIFS=$IFS
  IFS=.
  set -- $v
  IFS=$oldIFS

  if [ $# -ne 3 ] && [ $# -ne 4 ]; then
    return 1
  fi

  for part in "$@"
  do
    case "$part" in
      ''|*[!0-9]*)
        return 1
        ;;
    esac
  done

  return 0
}

################################################################################
# Dependency checks
################################################################################

install_unzip() {

  if command -v unzip >/dev/null 2>&1; then
    return
  fi

  log "Installing unzip..."

  if command -v pkg >/dev/null 2>&1; then
    pkg install unzip || {
      err "Failed to install unzip"
      exit 1
    }
  else
    err "unzip is required"
    exit 1
  fi
}

################################################################################
# Filesystem prep
################################################################################

prepare_fs() {

  log "Preparing filesystem..."

  mkdir -p "$AGENT_DIR"
  mkdir -p "$SCRIPTS_DIR"
  mkdir -p "$RUN_DIR"
  mkdir -p "$MANIFEST_DIR"
  mkdir -p "$TEMP_DIR"
}

################################################################################
# Latest release detection (no jq)
################################################################################

fetch_latest_release() {

  log "Detecting latest GitHub release..."

  redirect=$(curl -Ls -o /dev/null -w "%{url_effective}" \
    "https://github.com/$REPO_OWNER/$REPO_NAME/releases/latest")

  RELEASE_VERSION=${redirect##*/}

  if [ -z "$RELEASE_VERSION" ]; then
    err "Could not determine latest release."
    exit 1
  fi
}

################################################################################
# Download
################################################################################

download_tarball() {

  log "Downloading $DOWNLOAD_URL"

  if ! curl -L "$DOWNLOAD_URL" -o "$TEMP_DIR/$TARBALL_NAME"; then
    err "Download failed."
    exit 1
  fi
}

################################################################################
# Extract
################################################################################

extract_tarball() {

  log "Extracting archive..."

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

  # run.sh (root level)
  if [ -f "$TEMP_DIR/run.sh" ]; then
    cp "$TEMP_DIR/run.sh" "$AGENT_DIR/run.sh"
    chmod +x "$AGENT_DIR/run.sh"
  else
    err "run.sh not found in archive"
    exit 1
  fi

  # scripts/ folder
  if [ -d "$TEMP_DIR/scripts" ]; then
    cp -rp "$TEMP_DIR/scripts/." "$SCRIPTS_DIR/"
    chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null || true
  else
    err "scripts/ folder not found in archive"
    exit 1
  fi

  # conf.example.yaml → only copy if conf.yaml doesn't exist yet
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
cat <<EOF >/etc/profile.d/appoena-solaris.sh
export PATH=\$PATH:$SCRIPTS_DIR
EOF
    chmod +x /etc/profile.d/appoena-solaris.sh
  else
    grep "$SCRIPTS_DIR" /etc/profile >/dev/null 2>&1 || \
      echo "export PATH=\$PATH:$SCRIPTS_DIR" >> /etc/profile
  fi

  # SMF import
  if command -v svccfg >/dev/null 2>&1; then
    log "Importing SMF manifest..."
    svccfg import "$MANIFEST_DIR/$MANIFEST_NAME"
  else
    warn "svccfg not available"
  fi
}

fix_permissions() {
  log "Setting permissions..."

  chmod -R 755 "$AGENT_DIR"
}

################################################################################
# Cleanup
################################################################################

cleanup() {

  log "Cleaning temporary files..."

  rm -rf "$TEMP_DIR"
}

################################################################################
# Main
################################################################################

main() {

  log "Starting Appoena Solaris Agent installation"

  require_root

  if ! is_valid_semver "$VERSION"; then
    err "Invalid version: $VERSION"
    exit 1
  fi

  install_unzip

  prepare_fs

  if [ "$VERSION" = "latest" ]; then
    fetch_latest_release
  else
    RELEASE_VERSION="$VERSION"
  fi

  DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$RELEASE_VERSION/$TARBALL_NAME"

  download_tarball
  extract_tarball
  deploy_assets
  fix_permissions
  cleanup

  log "Installation complete."

  log "--------------------------------------------------------"
  log "NEXT STEPS:"
  log "1. Configure $AGENT_DIR/conf.yaml"
  log "2. Start service:"
  log "   svcadm enable $SERVICE_FMRI"
  log "3. Check logs with sudo sh /etc/appoena/solaris/scripts/solaris-agent-logs.sh"
  log "--------------------------------------------------------"
}

main "$@"