#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
BACKUP_BASE="$HOME/backups"
VOLUMES_FILE="./volumes.list"
RETENTION_DAYS=7

info()  { echo "[backup] $*"; }
error() { echo "[backup] ERROR: $*" >&2; exit 1; }

# --- VALIDATIONS ---
if [[ ! -f "$VOLUMES_FILE" ]]; then
  error "$VOLUMES_FILE not found. Run this script from your project root."
fi

if ! docker info &>/dev/null; then
  error "Docker is not running or not accessible."
fi

# --- LOAD VOLUMES ---
mapfile -t VOLUMES < <(grep -v '^[[:space:]]*#' "$VOLUMES_FILE" | grep -v '^$')
if [[ ${#VOLUMES[@]} -eq 0 ]]; then
  error "No volumes found in $VOLUMES_FILE"
fi

# --- SETUP BACKUP DIR ---
DATE=$(date +%Y-%m-%d)
BACKUP_DIR="$BACKUP_BASE/$DATE"
mkdir -p "$BACKUP_DIR"

info "Creating backup in: $BACKUP_DIR"
info "Volumes to back up: ${VOLUMES[*]}"

# --- BACKUP EACH VOLUME (using docker volume inspect for safety) ---
for vol in "${VOLUMES[@]}"; do
  vol="${vol//[$'\r\n ']}"  # trim whitespace/newlines

  if [[ -z "$vol" ]]; then
    continue
  fi

  if ! docker volume inspect "$vol" &>/dev/null; then
    info "WARNING: Volume '$vol' does not exist. Skipping."
    continue
  fi

  MOUNT_POINT=$(docker volume inspect "$vol" --format '{{.Mountpoint}}')
  info "Backing up: $vol"
  sudo tar -czf "$BACKUP_DIR/${vol}.tar.gz" -C "$(dirname "$MOUNT_POINT")" "$(basename "$MOUNT_POINT")"
done

# --- CLEAN UP OLD BACKUPS ---
info "Removing backups older than $RETENTION_DAYS days..."
find "$BACKUP_BASE" -maxdepth 1 -type d -name "20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]" -mtime +$RETENTION_DAYS -exec rm -rf {} + 2>/dev/null || true

info "Backup completed successfully!"