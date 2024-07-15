#!/bin/bash

# Set the directory you want to work with
TARGET_DIR="/datadrive/msg-backups"

# Change into the target directory
cd "$TARGET_DIR"

# Count the number of files in the directory
TOTAL_FILES=$(ls -1q * | wc -l)

# Number of files you want to keep
FILES_TO_KEEP=4

# Calculate the number of files to delete
let FILES_TO_DELETE=TOTAL_FILES-FILES_TO_KEEP

# Check if there are files to delete
if [ "$FILES_TO_DELETE" -le 0 ]; then
    echo "No files to delete, keeping the last $FILES_TO_KEEP files."
    exit 0
fi

# Delete all but the last N files (the most recent ones)
ls -t | tail -n +$((FILES_TO_KEEP+1)) | xargs -d '\n' rm --

# Echo completion
echo "Deleted all but the last $FILES_TO_KEEP files."
