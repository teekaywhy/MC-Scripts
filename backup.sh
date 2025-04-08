#!/bin/bash
# Backup Minecraft world and ensure at least 7 backup copies are kept

# Get today's date
today=$(date +%d-%m-%y_%H-%M)

# Backup directory
backup_dir="/mnt/rstore/Backup/MC/Lascaux"

# Function to send a command to the Minecraft server via tmux
send_cmd() {
    tmux send-keys -t Caves "$1" C-m
}

# Send commands to Minecraft tmux session
send_cmd "/say Backing up world, saving data..."
send_cmd "save-off"
send_cmd "save-all"
sleep 10

# Perform the backup using rsync
rsync -a ~/fabric/Lascaux "$backup_dir/Lascbkup$today"

# Re-enable saving on the server
send_cmd "save-on"
send_cmd "/say Backup complete. Saving re-enabled."

# Count current backups
backup_count=$(find "$backup_dir" -name "Lascbkup*" -type d | wc -l)
echo "Current number of backups: $backup_count"

# Minimum number of backups to keep
MIN_BACKUPS=7

# Remove old backups if more than MIN_BACKUPS exist
if [ "$backup_count" -gt "$MIN_BACKUPS" ]; then
    echo "Enough backups exist, removing those older than 7 days..."
    find "$backup_dir" -name "Lascbkup*" -mtime +7 -exec rm -rf {} +
    if [ $? -eq 0 ]; then
        echo "Old backups removed successfully"
    else
        echo "Warning: Some old backups could not be deleted"
    fi
else
    echo "Not enough backups ($backup_count < $MIN_BACKUPS), skipping deletion of old backups"
fi
