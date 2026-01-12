#!/bin/bash
set -e

# Entrypoint for franken-claude container
# Starts ttyd web terminal that spawns shells with worktree initialization

WORKTREE_COUNTER_FILE="/tmp/worktree-counter"
echo "0" > "$WORKTREE_COUNTER_FILE"

echo "=========================================="
echo "  franken-claude container starting"
echo "=========================================="
echo ""
echo "AWS Profile: ${AWS_PROFILE:-not set}"
echo "AWS Region: ${AWS_REGION:-not set}"
echo "Workspace: /workspace"
echo ""
echo "Starting web terminal on port 7681..."
echo ""

# Start ttyd with the terminal init script
# Each new terminal connection will create a new worktree
exec ttyd \
    --port 7681 \
    --writable \
    /terminal-init.sh
