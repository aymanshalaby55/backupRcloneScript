#!/bin/bash

CONFIG_FILE="$HOME/.config/rclone/rclone.conf"
LOG_FILE="/var/backup.log"
BACKUP_DIR="/var/Backup"


#Functions
compress_files(){
    mkdir -p "$BACKUP_DIR" #create if not exist (fixed typo: mdkir -> mkdir)
    local basename=$(basename "$1")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output="$BACKUP_DIR/${basename}_${timestamp}"
    local source="$1"
    
    # Check if source exists
    if [ ! -e "$source" ]; then
        echo "Error: Source '$source' does not exist"
        return 1
    fi

    tar -czf "${output}.tar.gz" -C "$(dirname "$source")" "$(basename "$source")"
    
    if [ $? -eq 0 ]; then
        echo "File ${output}.tar.gz Compressed Successfully"
        echo "$output.tar.gz"  # Return the compressed file path
    else
        echo "Error: Compression failed"
        return 1
    fi
}

perform_backup() {
    local source_path="$1"
    
    if [ -z "$source_path" ]; then
        echo "Error: No source path provided"
        exit 1
    fi
    
    echo "Starting backup of $source_path..."
    rclone copy "$source_path" gdrive:Backups --progress > "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        echo "Backup successful: $(date)" >> "$LOG_FILE"
        echo "Backup completed successfully"
        
        # Upload log file to Google Drive
        rclone copy "$LOG_FILE" gdrive:Backups
    else
        echo "Backup Failed: $(date)" >> "$LOG_FILE"
        echo "Backup failed - check $LOG_FILE for details"
        
        # Upload log file to Google Drive even on failure
        rclone copy "$LOG_FILE" gdrive:Backups
        exit 1
    fi
}

# Run the backup
check_rclone_auth


compress_files $1
perform_backup $BACKUP_DIR  # Add your actual path here


# clean up backup folder
rm -r $BACKUP_DIR