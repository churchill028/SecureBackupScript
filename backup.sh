#!/bin/bash

# Set the backup directory
mount_point="/mnt/to_backup"
backup_path="/mnt/from_backup"
email_address="your_email@gmail.com"

# CHECK IF DRIVE IS AVALIBE
if grep -qs "$mount_point" /proc/mounts; then
    logger "[INFO] Drive is mounted at $mount_point"
else
    logger "[ERROR] Drive is not mounted at $mount_point"

    # Send email notification
    message="The drive at $mount_point is not available."
    echo "$message" | mail -s "Drive Unavailable" "$email_address"

    # Exit the script with an error code
    exit 1
fi

# Delete old files
find /mnt/to_backup/ -maxdepth 1 -type d -name "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]" -exec bash -c 'backup_date=$(basename {}); if [ "$(date -d "$backup_date" +%s)" -lt "$(date -d "-9 months" +%s)" ]; then rm -r {} ; fi' \;


# Get free space
# Calculate backup size in bytes
backup_size=$(du -sb "$backup_path" | awk '{print $1}')

# Convert backup size to gigabytes
backup_size_gb=$(awk "BEGIN {printf \"%.2f\n\", ${backup_size} / 1024 / 1024 / 1024}")

# Get available space on the mount point in gigabytes
available_space=$(df -BG "$mount_point" | awk 'NR==2{print $4}' | tr -d 'G')

if (( $(awk "BEGIN {print ${backup_size_gb} <= ${available_space}}") )); then
    logger "[INFO] Backup size: ${backup_size_gb} GB"
    logger "[INFO] Available space on ${mount_point}: ${available_space} GB"
    logger "[INFO] There is enough space for the backup."
else
    logger "[ERROR] Backup size: ${backup_size_gb} GB"
    logger "[ERROR] Available space on ${mount_point}: ${available_space} GB"
    logger "[ERROR] Insufficient space for the backup."

    # Send email notification
    message="There is insufficient space on ${mount_point} for the backup."
    echo "$message" | mail -s "Insufficient Backup Space" "$email_address"

    # Exit the script with an error code
    exit 1
fi

# Create backup folders based on the current date
full_backup_folder="/mnt/backup/$(date +'%Y-%m-01')"
incremental_backup_folder="/mnt/backup/$(date +'%Y-%m-%d')"

# Find the matching folders and sort them in descending order
matching_folders=$(find "$mount_point" -maxdepth 1 -type d -name "????-??-??" | sort -r)

# Iterate over the matching folders
for folder in $matching_folders; do
  # Get the folder name without the path
  folder_name=$(basename "$folder")

  # Check if the folder name matches the pattern
  if [[ "$folder_name" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    # Found the last matching folder, do whatever you want here
    logger "[INFO] Last matching folder: $folder_name"
    break
  fi
done

# Create monthly full backup if it doesn't exist yet
if [[ -d "$full_backup_folder" ]]; then
    mkdir -p "$incremental_backup_folder"
    # Create daily incremental backup
    rsync -avz --delete --link-dest="/mnt/backup/$folder_name" "/mnt/share" "$incremental_backup_folder/"
    logger "[INFO] Incremental backup created successfully."
else
    mkdir -p "$full_backup_folder"
    # Full backup, folder name always in the format YYYY-MM-01
    rsync -avz --delete "/mnt/share" "$full_backup_folder/"
    logger "[INFO] Fullbackup backup created successfully."
fi
