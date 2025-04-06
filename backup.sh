#!/bin/bash
# Backup minecraft world and ensure at least 7 backup copies are kept

# Get today's date
today=$(date +%d-%m-%y)

# Backup directory (assumed to be mounted via fstab)
backup_dir="/mnt/rstore/Backup/MC/Lascaux"

# Send commands to Minecraft screen session
screen -S Caves -X stuff '/say Backing up world, saving data...\n'
screen -S Caves -X stuff 'save-off\n'
screen -S Caves -X stuff 'save-all\n'
sleep 10

# Perform the backup using rsync
rsync -r --mkpath ~/fabric/Lascaux "$backup_dir/Lascaux$today"

# Re-enable saving on the server
screen -S Caves -X stuff 'save-on\n'
screen -S Caves -X stuff '/say Backup complete. Saving re-enabled.\n'

# Count current backups
backup_count=$(find "$backup_dir" -name "Lascaux*" -type d | wc -l)
echo "Current number of backups: $backup_count"

# Minimum number of backups to keep
MIN_BACKUPS=7

# Only delete backups older than 7 days if we have more than MIN_BACKUPS
if [ "$backup_count" -gt "$MIN_BACKUPS" ]; then
    echo "Enough backups exist, removing those older than 7 days..."
    find "$backup_dir" -name "Lascaux*" -mtime +7 -exec rm -rf {} +
    if [ $? -eq 0 ]; then
        echo "Old backups removed successfully"
    else
        echo "Warning: Some old backups could not be deleted"
    fi
else
    echo "Not enough backups ($backup_count < $MIN_BACKUPS), skipping deletion of old backups"
fi