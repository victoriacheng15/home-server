#!/bin/bash

# --------------------------------------
# Detect the latest backup folder
# --------------------------------------
YELLOW='\033[1;33m'
RESET='\033[0m'
BACKUP_BASE="$HOME/backups"
BACKUP_DIR=$(ls -d "$BACKUP_BASE"/*/ | sort -V | tail -n 1)

if [ -z "$BACKUP_DIR" ]; then
    echo "No dated backup folders found in: $BACKUP_BASE"
    exit 1
fi

echo "Using latest backup folder: $BACKUP_DIR"

# Map backup filename → docker volume name
declare -A VOLUMES=(
    ["gitea_data.tar.gz"]="gitea_data"
    ["jenkins_data.tar.gz"]="jenkins_data"
    ["jupyter_data.tar.gz"]="jupyter_data"
    ["n8n_data.tar.gz"]="n8n_data"
    ["pg_data.tar.gz"]="postgres_data"
)

echo "Stopping Docker Compose services..."
docker compose down

# --------------------------------------
# Restore each volume
# --------------------------------------
for FILE in "${!VOLUMES[@]}"; do
    VOLUME_NAME="${VOLUMES[$FILE]}"
    BACKUP_FILE="$BACKUP_DIR$FILE"

    if [ ! -f "$BACKUP_FILE" ]; then
        echo "⚠️  Warning: Backup file not found: $BACKUP_FILE"
        continue
    fi

    echo "Restoring volume: $VOLUME_NAME from $FILE"

    echo "---------------------------------------"
    echo "Restoring $VOLUME_NAME from $BACKUP_FILE"
    echo "---------------------------------------"

    docker volume create "$VOLUME_NAME"

    docker run --rm \
      -v "$VOLUME_NAME":/restore-target \
      -v "$BACKUP_DIR":/backup \
      alpine sh -c "cd /restore-target && tar xzf /backup/$FILE >/dev/null 2>&1"

    echo -e "${YELLOW}[OK] Restored $VOLUME_NAME${RESET}"
done


# --------------------------------------
# Restart services
# --------------------------------------
echo "Starting Docker Compose services..."
docker compose up -d

echo "All volumes restored successfully!"
