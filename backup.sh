#!/bin/bash
# Backup Minecraft world and ensure at least 7 backup copies are kept

# Get today's date
today=$(date +%d-%m-%y_%H-%M)

# Backup directory and log file
backup_dir="/mnt/rstore/Backup/MC/Lascaux"
log_file="$backup_dir/backup_log.txt"

# Function to send a command to the Minecraft server via tmux
send_cmd() {
    tmux send-keys -t Caves "$1" C-m
}

# Log message with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$log_file"
    echo "$1"
}

# Send commands to Minecraft tmux session
send_cmd "/say Backing up world, saving data..."
send_cmd "save-off"
send_cmd "save-all"
sleep 10

# Calculate source directory size
source_size=$(du -sh ~/fabric/Lascaux | cut -f1)
log "Source directory size: $source_size"

# Perform the backup using rsync with progress and timing
start_time=$(date +%s)
rsync -a --stats ~/fabric/Lascaux "$backup_dir/Lascbkup$today" > /tmp/rsync_stats 2>&1
end_time=$(date +%s)

# Re-enable saving on the server
send_cmd "save-on"
send_cmd "/say Backup complete. Saving re-enabled."

# Calculate backup duration and speed
duration=$((end_time - start_time))
backup_size=$(du -sh "$backup_dir/Lascbkup$today" | cut -f1)

# Extract transfer stats from rsync and remove commas
bytes_transferred=$(grep "Total transferred file size" /tmp/rsync_stats | awk '{print $5}' | tr -d ',')
speed=$(grep "bytes/sec" /tmp/rsync_stats | awk '{print $2}' | tr -d ',')
rm /tmp/rsync_stats

# Log backup details
log "Backup completed: Lascbkup$today"
log "Backup size: $backup_size"
log "Bytes transferred: $bytes_transferred"
log "Duration: $duration seconds"
if [ $duration -gt 0 ]; then
    speed_mb=$(($bytes_transferred / $duration / 1048576))
    log "Average speed: $speed_mb MB/s"
else
    log "Average speed: N/A (duration was 0 seconds)"
fi
log "Rsync reported speed: $speed bytes/sec"

# Count current backups
backup_count=$(find "$backup_dir" -name "Lascbkup*" -type d | wc -l)
log "Current number of backups: $backup_count"

# Minimum number of backups to keep
MIN_BACKUPS=7

# Remove only one old backup if more than MIN_BACKUPS exist
if [ "$backup_count" -gt "$MIN_BACKUPS" ]; then
    log "More than $MIN_BACKUPS backups exist, removing oldest one..."
    # Find and delete only the oldest backup
    oldest_backup=$(find "$backup_dir" -name "Lascbkup*" -type d | sort | head -n 1)
    rm -rf "$oldest_backup"
    if [ $? -eq 0 ]; then
        log "Oldest backup ($oldest_backup) removed successfully"
    else
        log "Warning: Oldest backup could not be deleted"
    fi
else
    log "Not enough backups ($backup_count <= $MIN_BACKUPS), skipping deletion of old backups"
fi