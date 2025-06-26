#!/bin/bash

# make executable
# chmod +x deploy_to_vps.sh

# ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# ssh-copy-id root@159.89.172.251

# === Configurations ===
VPS_USER="root"
VPS_IP="159.89.172.251"
VPS_DEST="/www/wwwroot/soforv2.deepseahost.com"
ZIP_FILE="app.zip"
IGNORE_FILE=".zip_ignore"
SSH_KEY="$HOME/.ssh/id_rsa" # Change if different

# === Step 1: Create app.zip with .zip_ignore ===
echo "🔄 Step 1: Creating $ZIP_FILE (ignoring patterns from $IGNORE_FILE)..."

# Create a temporary file list for exclusion
EXCLUDES=()
if [ -f "$IGNORE_FILE" ]; then
    while read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" == \#* ]] && continue  # skip empty/comments
        EXCLUDES+=("-x" "$line")
    done < "$IGNORE_FILE"
fi

# Create the zip archive
zip -r "$ZIP_FILE" . "${EXCLUDES[@]}"
echo "✅ Zip file created: $ZIP_FILE"
echo

# === Step 2: Upload zip to VPS ===
echo "🔼 Step 2: Uploading $ZIP_FILE to $VPS_USER@$VPS_IP:$VPS_DEST..."
scp -i "$SSH_KEY" "$ZIP_FILE" "$VPS_USER@$VPS_IP:$VPS_DEST/"
echo "✅ Upload completed"
echo

# === Step 3–8: SSH into VPS, extract and run ===
echo "📡 Step 3: Connecting to VPS and setting up project..."

ssh -i "$SSH_KEY" "$VPS_USER@$VPS_IP" bash <<EOF
set -e
echo "📂 Step 4: Changing directory to $VPS_DEST..."
cd "$VPS_DEST"

echo "📦 Step 5: Unzipping $ZIP_FILE..."
unzip -o "$ZIP_FILE" -d .

# Inside ssh block on VPS
echo "🚀 Step 6: Running project setup scripts..."
if [ -f deploy_setup_commands.sh ]; then
    chmod +x deploy_setup_commands.sh
    ./deploy_setup_commands.sh && echo "✅ deploy_setup_commands.sh executed successfully." || echo "❌ deploy_setup_commands.sh ran but returned error."
else
    echo "⚠️ deploy_setup_commands.sh not found, skipping custom setup."
fi

echo "🧹 Step 7: Cleaning up..."
rm -f "$ZIP_FILE"

echo "🏁 Step 8: Done on VPS. Exiting..."
EOF

echo "✅ All steps completed!"
