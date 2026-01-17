---
description: Pick a todo ticket, create a worktree, and start working in plan mode
---

# /pick-ticket - Pick Up a Todo Ticket

Fetch a todo ticket from AI Intent First, create a git worktree, and enter plan mode to start implementing.

## Steps

### 1. Load Project Configuration

Get the project mapping for the current repository. First, get the current directory and encode it:

```bash
pwd
```

Take the output (e.g., `/Users/yvocilon/Repos/note-taker`) and replace all `/` with `%2F` to get the encoded path (e.g., `%2FUsers%2Fyvocilon%2FRepos%2Fnote-taker`).

Then read the config file:

```bash
cat ~/.claude/projects/<ENCODED_PATH>/.aintentfirst.json
```

The file contains `projectId`, `projectName`, and `connectedAt`.

If the file doesn't exist, tell the user:

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

### 6. Change to Worktree Directory

Change your working directory to the worktree:

```bash
cd <worktree-path>
```

This ensures all subsequent git operations happen in the correct branch.

### 7. Display Task Summary

Show the ticket details you already retrieved in step 4:

```
✓ Worktree ready: <worktree-path>
✓ Branch: ticket/<short-id>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ticket: <short-id>
Title: <ticket title>

Task: <summarize the main task in 2-3 sentences>

Key Requirements:
- <bullet points from description/clarification>

Constraints:
- <any important constraints from the clarification thread>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 8. Enter Plan Mode

You now have full context for the ticket. Immediately enter plan mode using the EnterPlanMode tool to design the implementation approach.

In plan mode:
1. Explore the codebase to understand relevant areas
2. Identify which files need to be created or modified
3. Design the implementation approach
4. Write a clear plan for user approval

Do NOT wait for user instructions - you have everything you need. Enter plan mode and start planning immediately.

## Notes

- Only call `get_ticket` after user approval - that's what locks the ticket
- The worktree is created in `../<repo-name>-worktrees/ticket-<short-id>/`
- All file paths should use the worktree path, not the main repo
- After plan approval, implement the feature in the worktree
