---
description: Pick a todo ticket, create a worktree, and open a new Claude instance
---

# /pick-ticket - Pick Up a Todo Ticket

Fetch a todo ticket from AI Intent First, create a git worktree, and open a new Claude instance.

## Steps

### 1. Load Project Configuration

Get the project mapping for the current repository:

```bash
CONFIG_FILE=~/.claude/projects/$(echo "$PWD" | sed 's/\//%2F/g')/.aintentfirst.json
cat "$CONFIG_FILE" 2>/dev/null
```

If no config exists, tell the user:

> This repository isn't connected to an AI Intent First project.
> Run `/init` first to set up the connection.

Then stop.

### 2. Fetch Todo Tickets

Call the MCP tool to list tickets:

```
mcp__aintentfirst__list_tickets with projectId and status: "todo"
```

If no tickets are in "todo" status, inform the user:

> No todo tickets available. All caught up!

Then stop.

### 3. Show Tickets for Approval

For the first ticket, display:
- Title
- Brief description (first 100 chars or so)

Ask the user:

> **Pick up this ticket?**
>
> - **Yes** - Lock ticket and create worktree
> - **Skip** - Show next ticket
> - **No** - Stop

If "Skip", show the next ticket. Continue until user picks one or says "No".

### 4. Lock the Ticket

Once approved, call:

```
mcp__aintentfirst__get_ticket with ticketId
```

This auto-moves the ticket to "in_progress", locking it from other Claude instances.

Display the full ticket details including any project documentation.

### 5. Create Worktree

Get the plugin directory and run the worktree script:

```bash
# Find the plugin scripts directory
PLUGIN_DIR="$(dirname "$(dirname "$0")")"  # Relative to command file

# Or use absolute path if installed
~/.claude/plugins/repos/aintentfirst/scripts/worktree-new.sh "<ticket-id>"
```

The script will:
- Create a branch named `ticket/<short-id>` (first 8 chars of UUID)
- Create a worktree at `../<repo-name>-worktrees/ticket-<short-id>/`
- Symlink `.env` from main repo
- Install dependencies (auto-detects pnpm/npm/yarn/bun)

Capture the `WORKTREE_PATH` from the script output.

### 6. Open New Terminal Tab

Run the open-worktree script:

```bash
~/.claude/plugins/repos/aintentfirst/scripts/open-worktree.sh "<worktree-path>"
```

This opens a new terminal tab (iTerm2 or Terminal.app) and runs:
```
cd <worktree-path> && claude /resume-ticket
```

### 7. Confirm to User

Display:

```
Worktree created and new Claude session started.

Ticket: <title>
Branch: ticket/<short-id>
Path: <worktree-path>

The new Claude instance is loading the ticket context now.
You can close this terminal or continue working here.
```

## Notes

- Only call `get_ticket` after user approval - that's what locks the ticket
- The new Claude instance will auto-run `/resume-ticket` to load context
- If the terminal script fails, provide manual instructions
