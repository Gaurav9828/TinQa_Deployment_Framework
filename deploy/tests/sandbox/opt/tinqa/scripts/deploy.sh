#!/bin/bash

PI_HOST="raspberrypi.local"
PI_USER="pi"
REMOTE_DIR="~/TinQa_Weather_Sync_System"

echo "🚀 Syncing code to $PI_HOST..."
# Syncing the app directory and root files while excluding the local venv
rsync -avz --exclude 'venv' --exclude '__pycache__' \
./ $PI_USER@$PI_HOST:$REMOTE_DIR

echo "🔄 Restarting TinQa Service..."
ssh -t $PI_USER@$PI_HOST "sudo systemctl daemon-reload && sudo systemctl restart tinqa.service"

echo "✅ Deployment Complete!"