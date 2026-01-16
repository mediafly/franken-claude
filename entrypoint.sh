#!/bin/bash
set -e

# Entrypoint for frank-claude container
# Starts ttyd web terminal that spawns shells with worktree initialization

WORKTREE_COUNTER_FILE="/tmp/worktree-counter"
echo "0" > "$WORKTREE_COUNTER_FILE"

# Initialize Claude settings if this is first run
if [ ! -f "/root/.claude/settings.local.json" ]; then
    mkdir -p /root/.claude
    cp /opt/claude-settings-default.json /root/.claude/settings.local.json
    echo "Initialized default Claude settings"
fi

echo "=========================================="
echo "  frank-claude container starting"
echo "=========================================="
echo ""
echo "AWS Profile: ${AWS_PROFILE:-not set}"
echo "AWS Region: ${AWS_REGION:-not set}"
echo "Workspace: /workspace"
echo ""
echo "Starting nginx on port 7681..."
echo "Starting ttyd on port 7682..."
echo ""

# Start nginx in background
nginx

# Start ttyd on port 7682 (proxied by nginx)
# Each new terminal connection will create a new worktree
exec ttyd \
    --port 7682 \
    --writable \
    /terminal-init.sh
