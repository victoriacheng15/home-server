#!/bin/bash

# Colors
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
RESET='\033[0m'

BACKUP_BASE="$HOME/backups"
VOLUMES_FILE="./volumes.list"

# --- VALIDATION ---
if [[ ! -f "$VOLUMES_FILE" ]]; then
  echo -e "${RED}❌ ERROR: $VOLUMES_FILE not found. Run from project root.${RESET}" >&2
  exit 1
fi

# Load volume names (same as setup/backup)
mapfile -t VOLUME_NAMES < <(grep -v '^[[:space:]]*#' "$VOLUMES_FILE" | grep -v '^$')
if [[ ${#VOLUME_NAMES[@]} -eq 0 ]]; then
  echo -e "${RED}❌ ERROR: No volumes in $VOLUMES_FILE${RESET}" >&2
  exit 1
fi

# --- FIND LATEST BACKUP ---
BACKUP_DIR=$(ls -1dt "$BACKUP_BASE"/20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]/ 2>/dev/null | head -n1)

if [[ -z "$BACKUP_DIR" ]]; then
  echo -e "${RED}❌ No dated backup folders found in: $BACKUP_BASE${RESET}" >&2
  exit 1
fi

echo -e "${GREEN}📁 Using latest backup: $(basename "$BACKUP_DIR")${RESET}"

# --- STOP SERVICES SAFELY ---
echo "🛑 Stopping Docker Compose services..."
if ! docker compose down; then
  echo -e "${YELLOW}⚠️  Warning: Some services may not have stopped cleanly.${RESET}"
fi

# --- RESTORE EACH VOLUME ---
for vol in "${VOLUME_NAMES[@]}"; do
  vol="${vol//[$'\r\n ']}"
  [[ -z "$vol" ]] && continue

  BACKUP_FILE="$BACKUP_DIR/${vol}.tar.gz"

  if [[ ! -f "$BACKUP_FILE" ]]; then
    echo -e "${YELLOW}⚠️  Skipping $vol: backup file not found ($BACKUP_FILE)${RESET}"
    continue
  fi

  echo -e "${GREEN}📦 Restoring volume: $vol${RESET}"

  # Remove existing volume (safe: services are down!)
  if docker volume inspect "$vol" &>/dev/null; then
    docker volume rm -f "$vol"
  fi

  # Recreate + restore
  docker volume create "$vol" >/dev/null
  docker run --rm \
    -v "$vol":/restore-target \
    -v "$BACKUP_DIR":/backup \
    alpine sh -c "cd /restore-target && tar xzf /backup/$(basename "$BACKUP_FILE") --no-same-owner"

  echo -e "${GREEN}[OK] Restored $vol${RESET}"
done

# --- RESTART ---
echo "🚀 Starting Docker Compose services..."
if docker compose up -d; then
  echo -e "${GREEN}✅ All services restarted successfully!${RESET}"
else
  echo -e "${RED}❌ Failed to restart services. Check 'docker compose logs'.${RESET}"
  exit 1
fi