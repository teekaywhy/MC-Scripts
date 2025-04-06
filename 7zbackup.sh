#!/bin/bash
# Backup Minecraft world, compress with 7zip, and delete backups older than 10 days

# Get today's date
today=$(date +%d-%m-%y)

# Backup directory
backup_dir=/mnt/rstore/Backup/MC/Lascaux

# Temporary directory for compression
temp_dir=/tmp/mc_backup_$today

# Create a temporary directory
mkdir -p "$temp_dir"

# Notify players and initiate save
screen -S Caves -X stuff '/say Backing up world. Saving data...\n'   # Notify players
screen -S Caves -X stuff 'save-off\n'                                # Disable automatic saves
screen -S Caves -X stuff 'save-all\n'                                # Force save
sleep 10                                                             # Wait to ensure save completes

# Copy the Minecraft world into the temporary directory
rsync -r --mkpath ~/fabric/Lascaux "$temp_dir"

# Re-enable saving on the server
screen -S Caves -X stuff 'save-on\n'                                 # Re-enable automatic saves
screen -S Caves -X stuff '/say Backup complete. Saving re-enabled.\n'

# Compress the backup with 7zip
7z a -t7z "$backup_dir/Lascaux_$today.7z" "$temp_dir/Lascaux" >/dev/null

# Clean up the temporary directory
rm -rf "$temp_dir"

# Find and delete backups older than 10 days
find "$backup_dir" -name "Lascaux*.7z" -mtime +10 -delete