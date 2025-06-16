#!/bin/bash

# FTP server credentials and details
FTP_HOST=""
FTP_USER=""
FTP_PASS=""
FTP_TARGET_DIR="/public_html"  # Change this to the target directory on the FTP server

# File to upload
FILE_TO_UPLOAD="vendor.zip"

# Upload using curl
curl -T "$FILE_TO_UPLOAD" "ftp://$FTP_HOST$FTP_TARGET_DIR/" --user "$FTP_USER:$FTP_PASS"

# Check if the upload was successful
if [ $? -eq 0 ]; then
  echo "Upload successful."
else
  echo "Upload failed."
fi
