#!/bin/bash
# Backup minecraft world and delete backups older than 7 days

# Get today's date
today=$(date +%d-%m-%y)

# Backup directory
backup_dir=/mnt/rstore/Backup/MC/Lascaux

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

# Find and delete backups older than 7 days
find "$backup_dir" -name "Lascaux*" -mtime +7 -exec rm -rf {} +