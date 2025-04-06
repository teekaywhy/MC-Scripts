#!/bin/bash
# Backup minecraft world and delete backups older than 7 days with SMB authentication

# SMB credentials and mount details
SMB_USER="asdf"
SMB_PASS="Conquest&Walk_Tooth_159"
SMB_SERVER="192.168.1.3"
SMB_SHARE="rstore"
MOUNT_POINT="/mnt/rstore"

# Get today's date
today=$(date +%d-%m-%y)

# Backup directory
backup_dir="$MOUNT_POINT/Backup/MC/Lascaux"

# Mount the SMB share
echo "Mounting SMB share..."
if ! mountpoint -q "$MOUNT_POINT"; then
    sudo mkdir -p "$MOUNT_POINT"
    sudo mount -t cifs "//$SMB_SERVER/$SMB_SHARE" "$MOUNT_POINT" -o username="$SMB_USER",password="$SMB_PASS",vers=3.0
    if [ $? -ne 0 ]; then
        echo "Failed to mount SMB share. Exiting."
        exit 1
    fi
fi

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

# Unmount the SMB share
echo "Unmounting SMB share..."
sudo umount "$MOUNT_POINT"
if [ $? -ne 0 ]; then
    echo "Warning: Failed to unmount SMB share"
else
    echo "SMB share unmounted successfully"
fi