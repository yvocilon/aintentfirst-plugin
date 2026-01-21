#!/bin/bash
set -euo pipefail

# Open a new terminal tab and start Claude in Docker sandbox with automated workflow
# Supports iTerm2 and Terminal.app on macOS

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
PROMPT_FILE="$PLUGIN_DIR/prompts/auto-implement.txt"

usage() {
    echo "Usage: $0 <worktree-path>"
    echo ""
    echo "Opens a new terminal tab at the worktree path and runs Docker sandbox with automated prompt"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

WORKTREE_PATH="$1"

# Verify the path exists
if [ ! -d "$WORKTREE_PATH" ]; then
    echo "Error: Worktree path does not exist: $WORKTREE_PATH"
    exit 1
fi

# Verify TICKET.md exists
if [ ! -f "$WORKTREE_PATH/TICKET.md" ]; then
    echo "Warning: TICKET.md not found in worktree. The automated prompt expects this file."
fi

# Build the Docker sandbox command with the automated prompt
# Using --permission-mode acceptEdits to allow file changes with confirmation
DOCKER_CMD="docker sandbox run claude --permission-mode acceptEdits -p \"\$(cat '$PROMPT_FILE')\""

# Detect terminal and open new tab
if [ "$(uname)" = "Darwin" ]; then
    # macOS - try iTerm2 first, fall back to Terminal.app
    if osascript -e 'tell application "System Events" to (name of processes) contains "iTerm2"' 2>/dev/null | grep -q "true"; then
        # iTerm2 is running
        osascript <<EOF
tell application "iTerm2"
    tell current window
        create tab with default profile
        tell current session
            write text "cd '$WORKTREE_PATH' && $DOCKER_CMD"
        end tell
    end tell
end tell
EOF
        echo "Opened new iTerm2 tab at: $WORKTREE_PATH"
        echo "Docker sandbox launching with automated workflow..."
    else
        # Fall back to Terminal.app
        osascript <<EOF
tell application "Terminal"
    activate
    do script "cd '$WORKTREE_PATH' && $DOCKER_CMD"
end tell
EOF
        echo "Opened new Terminal.app window at: $WORKTREE_PATH"
        echo "Docker sandbox launching with automated workflow..."
    fi
else
    # Linux/other - just print instructions
    echo ""
    echo "Open a new terminal and run:"
    echo "  cd $WORKTREE_PATH && $DOCKER_CMD"
fi
