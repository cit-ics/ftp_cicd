#!/bin/bash

# FTP server credentials and details
FTP_HOST="162.214.66.206"
FTP_USER="myreportxbd"
FTP_PASS="EMnZe9[Lv36]XSxCY&{4Xe(ZL"
FTP_TARGET_DIR="/public_html"

# JSON file containing the list of modified files
MODIFIED_FILE="./.modify_tracking/modified.json"

# Ensure the JSON file exists
if [ ! -f "$MODIFIED_FILE" ]; then
  echo "Modified file list not found at $MODIFIED_FILE"
  exit 1
fi

# Read the JSON array and loop through each file
FILES=$(jq -r '.[]' "$MODIFIED_FILE")

for FILE in $FILES; do
  # Strip leading slash to make it a relative path
  RELATIVE_FILE="${FILE#/}"
  
  # Check if file exists
  if [ -f "$RELATIVE_FILE" ]; then
    echo "Uploading: $RELATIVE_FILE"
    curl -T "$RELATIVE_FILE" "ftp://$FTP_HOST$FTP_TARGET_DIR/$RELATIVE_FILE" --user "$FTP_USER:$FTP_PASS"
    
    if [ $? -eq 0 ]; then
      echo "✔ Upload successful: $RELATIVE_FILE"
    else
      echo "✖ Upload failed: $RELATIVE_FILE"
    fi
  else
    echo "⚠ File not found: $RELATIVE_FILE"
  fi
done

# Clear the modified.json file with an empty array
echo "[]" > "$MODIFIED_FILE"
echo "✅ Cleared modified.json after upload."
