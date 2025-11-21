#!/bin/bash

# --- CONFIG ---
BACKUP_BASE="$HOME/backups"      # Change to your backup location
VOLUMES=(
  "gitea_data"
  "jenkins_data"
  "postgres_data"
  "n8n_data"
  "jupyter_data"
)
RETENTION_DAYS=7

# --- SETUP ---
DATE=$(date +%Y-%m-%d)
BACKUP_DIR="$BACKUP_BASE/$DATE"
mkdir -p "$BACKUP_DIR"

echo "📁 Creating backup in: $BACKUP_DIR"

# --- BACKUP EACH VOLUME ---
for vol in "${VOLUMES[@]}"; do
  echo "📦 Backing up volume: $vol"
  sudo tar -czf "$BACKUP_DIR/${vol}.tar.gz" -C /var/lib/docker/volumes "$vol"
done

# --- CLEAN UP OLD BACKUP FOLDERS ---
echo "🧹 Removing backups older than $RETENTION_DAYS days..."
find "$BACKUP_BASE" -maxdepth 1 -type d -name "20*" -mtime +$RETENTION_DAYS -exec rm -rf {} + 2>/dev/null

echo "✅ Backup completed successfully!"