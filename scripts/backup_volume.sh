#!/bin/bash

# --- CONFIG ---
BACKUP_BASE="$HOME/backups"
VOLUMES_FILE="./volumes.list"
RETENTION_DAYS=7

# --- VALIDATIONS ---
if [[ ! -f "$VOLUMES_FILE" ]]; then
  echo "❌ ERROR: $VOLUMES_FILE not found. Run this script from your project root." >&2
  exit 1
fi

if ! docker info &>/dev/null; then
  echo "❌ ERROR: Docker is not running or not accessible." >&2
  exit 1
fi

# --- LOAD VOLUMES ---
mapfile -t VOLUMES < <(grep -v '^[[:space:]]*#' "$VOLUMES_FILE" | grep -v '^$')
if [[ ${#VOLUMES[@]} -eq 0 ]]; then
  echo "❌ ERROR: No volumes found in $VOLUMES_FILE" >&2
  exit 1
fi

# --- SETUP BACKUP DIR ---
DATE=$(date +%Y-%m-%d)
BACKUP_DIR="$BACKUP_BASE/$DATE"
mkdir -p "$BACKUP_DIR"

echo "📁 Creating backup in: $BACKUP_DIR"
echo "📦 Volumes to back up: ${VOLUMES[*]}"

# --- BACKUP EACH VOLUME (using docker volume inspect for safety) ---
for vol in "${VOLUMES[@]}"; do
  vol="${vol//[$'\r\n ']}"  # trim whitespace/newlines

  if [[ -z "$vol" ]]; then
    continue
  fi

  if ! docker volume inspect "$vol" &>/dev/null; then
    echo "⚠️  WARNING: Volume '$vol' does not exist. Skipping."
    continue
  fi

  MOUNT_POINT=$(docker volume inspect "$vol" --format '{{.Mountpoint}}')
  echo "📦 Backing up: $vol"
  sudo tar -czf "$BACKUP_DIR/${vol}.tar.gz" -C "$(dirname "$MOUNT_POINT")" "$(basename "$MOUNT_POINT")"
done

# --- CLEAN UP OLD BACKUPS ---
echo "🧹 Removing backups older than $RETENTION_DAYS days..."
find "$BACKUP_BASE" -maxdepth 1 -type d -name "20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]" -mtime +$RETENTION_DAYS -exec rm -rf {} + 2>/dev/null

echo "✅ Backup completed successfully!"