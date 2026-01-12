#!/bin/bash

# Terminal initialization script for franken-claude
# Creates a new git worktree for each terminal session

WORKTREE_COUNTER_FILE="/tmp/worktree-counter"
WORKTREE_BASE="/worktrees"
WORKSPACE="/workspace"

# Atomically increment counter and get the new value
get_next_worktree_number() {
    (
        flock -x 200
        CURRENT=$(cat "$WORKTREE_COUNTER_FILE" 2>/dev/null || echo "0")
        NEXT=$((CURRENT + 1))
        echo "$NEXT" > "$WORKTREE_COUNTER_FILE"
        echo "$NEXT"
    ) 200>"${WORKTREE_COUNTER_FILE}.lock"
}

# Check if workspace is a git repo
if [ ! -d "$WORKSPACE/.git" ]; then
    echo "Warning: /workspace is not a git repository"
    echo "Worktree creation skipped. Working in /workspace directly."
    cd "$WORKSPACE"
    exec bash
fi

# Get next worktree number
WORKTREE_NUM=$(get_next_worktree_number)
WORKTREE_NAME="franken-${WORKTREE_NUM}"
WORKTREE_PATH="${WORKTREE_BASE}/${WORKTREE_NAME}"

echo "=========================================="
echo "  Terminal #${WORKTREE_NUM}"
echo "=========================================="
echo ""

# Create worktree
cd "$WORKSPACE"

# Get current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

# Create a new branch for this worktree based on current HEAD
WORKTREE_BRANCH="${WORKTREE_NAME}"

echo "Creating worktree: ${WORKTREE_PATH}"
echo "Branch: ${WORKTREE_BRANCH} (from ${CURRENT_BRANCH})"
echo ""

if git worktree add -b "$WORKTREE_BRANCH" "$WORKTREE_PATH" HEAD 2>/dev/null; then
    cd "$WORKTREE_PATH"
    echo "Ready! Working in: ${WORKTREE_PATH}"
else
    # Branch might already exist, try without -b
    if git worktree add "$WORKTREE_PATH" "$WORKTREE_BRANCH" 2>/dev/null; then
        cd "$WORKTREE_PATH"
        echo "Ready! Working in: ${WORKTREE_PATH}"
    else
        echo "Warning: Could not create worktree. Working in /workspace directly."
        cd "$WORKSPACE"
    fi
fi

echo ""
echo "=========================================="
echo ""

# Start interactive bash
exec bash
