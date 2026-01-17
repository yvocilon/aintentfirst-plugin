#!/bin/bash
set -euo pipefail

# Open a new terminal tab and start Claude with /resume-ticket
# Supports iTerm2 and Terminal.app on macOS

usage() {
    echo "Usage: $0 <worktree-path>"
    echo ""
    echo "Opens a new terminal tab at the worktree path and runs 'claude /resume-ticket'"
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
            write text "cd '$WORKTREE_PATH' && claude /resume-ticket"
        end tell
    end tell
end tell
EOF
        echo "Opened new iTerm2 tab at: $WORKTREE_PATH"
    else
        # Fall back to Terminal.app
        osascript <<EOF
tell application "Terminal"
    activate
    do script "cd '$WORKTREE_PATH' && claude /resume-ticket"
end tell
EOF
        echo "Opened new Terminal.app window at: $WORKTREE_PATH"
    fi
else
    # Linux/other - just print instructions
    echo ""
    echo "Open a new terminal and run:"
    echo "  cd $WORKTREE_PATH && claude /resume-ticket"
fi
