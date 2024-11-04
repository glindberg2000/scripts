#!/bin/bash

# Variables
CONTAINER_NAME="my_postgres"
BACKUP_DIR="/media/ext_storage/postgres/$CONTAINER_NAME"
RETENTION_DAYS=7

# Find and delete backups older than retention period
find $BACKUP_DIR -type f -mtime +$RETENTION_DAYS -name "*.sql" -exec rm {} \;

echo "Old backups deleted from $BACKUP_DIR"