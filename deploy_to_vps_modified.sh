#!/bin/bash

# Config
VPS_USER="root"
VPS_IP="159.89.172.251"
VPS_DEST="/www/wwwroot/soforv2.deepseahost.com"
ZIP_FILE="app.zip"
IGNORE_FILE=".zip_ignore"
SSH_KEY="$HOME/.ssh/id_rsa" # Change if different

TRACKING_FILE=".modify_tracking/modified.json"

# Check file
if [ ! -f "$TRACKING_FILE" ]; then
    echo "❌ $TRACKING_FILE not found"
    exit 1
fi

# Create temp file list
TMP_LIST=$(mktemp)
jq -r '.[]' "$TRACKING_FILE" > "$TMP_LIST"

echo "📦 Uploading modified files via rsync..."
rsync -avz --files-from="$TMP_LIST" ./ -e "ssh -i $SSH_KEY" "$VPS_USER@$VPS_IP:$VPS_DEST"

rm "$TMP_LIST"
echo "✅ Done: Modified files uploaded using rsync"

# Clear the modified.json file with an empty array
echo "[]" > "$TRACKING_FILE"
echo "✅ Cleared modified.json after upload."



# === SSH into VPS, extract and run ===
echo "📡 Connecting to VPS and setting up project..."

ssh -i "$SSH_KEY" "$VPS_USER@$VPS_IP" bash <<EOF
set -e
echo "📂 Step 4: Changing directory to $VPS_DEST..."
cd "$VPS_DEST"

# Inside ssh block on VPS
echo "🚀 Running project update scripts..."
if [ -f deploy_setup_commands.sh ]; then
    chmod +x deploy_setup_commands.sh
    ./deploy_setup_commands.sh && echo "✅ deploy_setup_commands.sh executed successfully." || echo "❌ deploy_setup_commands.sh ran but returned error."
else
    echo "⚠️ deploy_setup_commands.sh not found, skipping custom setup."
fi
