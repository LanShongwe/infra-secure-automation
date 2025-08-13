#!/bin/bash
##==## Utility script to remove temporary files, logs, and old backups ##==##
set -e

BACKUP_DIR="/var/backups/ansible"
LOG_DIR="/var/log/ansible"

echo "Starting cleanup..."

# Removes backups older than 30 days
if [ -d "$BACKUP_DIR" ]; then
    find "$BACKUP_DIR" -type f -mtime +30 -exec rm -f {} \;
    echo "Old backups removed."
else
    echo "No backup directory found."
fi

# Removes logs older than 14 days
if [ -d "$LOG_DIR" ]; then
    find "$LOG_DIR" -type f -mtime +14 -exec rm -f {} \;
    echo "Old logs removed."
else
    echo "No log directory found."
fi

echo "Cleanup completed successfully."