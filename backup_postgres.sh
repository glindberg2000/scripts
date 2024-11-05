#!/bin/bash

# Variables
BASE_BACKUP_DIR="/media/ext_storage/backups"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
MAX_PARALLEL_JOBS=3

# Ensure the backup directory exists
mkdir -p "$BASE_BACKUP_DIR"

# Backup the SQLite database
SQLITE_BACKUP_FILE="${BASE_BACKUP_DIR}/n8n_database_backup_${TIMESTAMP}.sqlite"
cp /home/plato/.n8n/database.sqlite "$SQLITE_BACKUP_FILE"
echo "Backup of n8n SQLite database completed successfully."

# Function to backup a PostgreSQL database
backup_database() {
    local container_name=$1
    local db_user=$2
    local db_name=$3
    local backup_dir="${BASE_BACKUP_DIR}/${container_name}"
    local backup_file="${backup_dir}/${db_name}_backup_${TIMESTAMP}.sql"
    local log_file="${backup_dir}/${db_name}_backup_${TIMESTAMP}.log"

    # Ensure the container-specific backup directory exists
    mkdir -p "$backup_dir"

    {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting backup for database: $db_name in container: $container_name"
        
        # Check if container is running
        if ! docker container inspect "$container_name" >/dev/null 2>&1; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Container $container_name does not exist"
            return 1
        fi
        
        if [ "$(docker container inspect -f '{{.State.Running}}' "$container_name")" != "true" ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Container $container_name is not running"
            return 1
        fi

        # Perform the backup
        if docker exec -t "$container_name" pg_dump -U "$db_user" "$db_name" > "$backup_file" 2>>"$log_file"; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup for $db_name in container $container_name completed successfully"
            return 0
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup for $db_name in container $container_name failed. Check $log_file for details"
            return 1
        fi
    } >> "$log_file" 2>&1
}

# Array to store background process IDs and their corresponding names
declare -a pids
declare -a backup_names
declare -a failed_backups

# Backup databases in parallel using admin_user
backup_database "my_postgres" "admin_user" "omi_data" & pids+=($!); backup_names+=("my_postgres:omi_data")
#backup_database "memgpt-letta_db-1" "letta" "letta" & pids+=($!); backup_names+=("memgpt-letta_db-1:letta")
#backup_database "n8n" "postgres" "n8n" & pids+=($!); backup_names+=("n8n:n8n")  # Updated container name

# Wait for all backups to complete
failures=0
for i in "${!pids[@]}"; do
    wait ${pids[$i]}
    if [ $? -ne 0 ]; then
        ((failures++))
        failed_backups+=("${backup_names[$i]}")
    else
        echo "Backup completed successfully for ${backup_names[$i]}"
    fi
done

# Final status report
echo "All backup jobs completed. Failed backups: $failures"
if [ $failures -eq 0 ]; then
    echo "All backups completed successfully"
    exit 0
else
    echo "Some backups failed. Check the log files for details"
    echo "Failed backups: ${failed_backups[@]}"
    exit 1
fi