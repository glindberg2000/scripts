   #!/bin/bash

   # Variables
   CONTAINER_NAME="my_postgres"
   BACKUP_DIR="/media/ext_storage/postgres/$CONTAINER_NAME"
   TIMESTAMP=$(date +"%Y%m%d%H%M%S")
   BACKUP_FILE="/tmp/all_databases_backup_$TIMESTAMP.sql"

   # Create backup directory if it doesn't exist
   mkdir -p $BACKUP_DIR

   # Run pg_dumpall inside the container to back up all databases
   docker exec $CONTAINER_NAME pg_dumpall -U omi_user -f $BACKUP_FILE

   # Copy the backup to the host
   docker cp $CONTAINER_NAME:$BACKUP_FILE $BACKUP_DIR

   # Clean up the backup file inside the container
   docker exec $CONTAINER_NAME rm $BACKUP_FILE

   echo "Backup completed: $BACKUP_DIR/all_databases_backup_$TIMESTAMP.sql"