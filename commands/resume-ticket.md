---
description: Resume work on a ticket by loading context from the current branch
---

# /resume-ticket - Resume Work on Current Ticket

Automatically load ticket context when working in a ticket worktree.

## When to Use

Run this when you start a new Claude session in a worktree created by `/pick-ticket`. It detects the ticket from your branch and loads all context.

## Steps

### 1. Get Current Branch Name

```bash
git branch --show-current
```

Expect format: `ticket/<short-id>` (e.g., `ticket/7ceb92bd`)

### 2. Extract Ticket ID

Parse the short ID from the branch name (everything after `ticket/`).

If the branch doesn't match the `ticket/*` pattern:

> This doesn't appear to be a ticket branch.
> Expected format: `ticket/<id>` (e.g., `ticket/7ceb92bd`)
>
> Use `/pick-ticket` to start working on a new ticket.

Then stop.

### 3. Find Project Configuration

First, find the main repo path (this works correctly in worktrees):

```bash
git rev-parse --path-format=absolute --git-common-dir
```

Take the output (e.g., `/Users/yvocilon/Repos/note-taker/.git`) and remove the `/.git` suffix to get the main repo path.

Then encode the path by replacing all `/` with `%2F` and read the config:

```bash
cat ~/.claude/projects/<ENCODED_MAIN_REPO_PATH>/.aintentfirst.json
```

The file contains `projectId`, `projectName`, and `connectedAt`.

If no config exists, tell the user to run `/init` in the main repository.

### 4. Find Full Ticket ID

The branch has a short ID (first 8 chars), but MCP needs the full UUID.

Call:

```
mcp__aintentfirst__list_tickets with projectId and status: "in_progress"
```

Find the ticket whose ID starts with the short ID from the branch.

If no match found:

> Could not find an in-progress ticket matching `<short-id>`.
>
> The ticket may have been completed or moved to a different status.

### 5. Fetch Full Ticket Details

Call:

```
mcp__aintentfirst__get_ticket with ticketId (the full UUID)
```

This returns:
- Full ticket description
- Clarification Q&A thread
- Project documentation

### 6. Display Task Summary

Show a clear summary:

```
Resuming ticket: <short-id>

Title: <ticket title>
Status: in_progress

Task: <summarize the main task in 2-3 sentences>

Key Requirements:
- <bullet points from description/clarification>

Constraints:
- <any important constraints from the clarification thread>
```

### 7. Enter Plan Mode

You now have full context for the ticket. Immediately enter plan mode using the EnterPlanMode tool to design the implementation approach.

In plan mode:
1. Explore the codebase to understand relevant areas
2. Identify which files need to be created or modified
3. Design the implementation approach
4. Write a clear plan for user approval

Do NOT wait for user instructions - you have everything you need. Enter plan mode and start planning immediately.

## Example Output

```
Resuming ticket: 7ceb92bd

Title: Add polling to project dashboard
Status: in_progress

Task: Add periodic polling to the project dashboard so changes made
via MCP (new tickets, status updates) appear without manual refresh.

Key Requirements:
- Poll for ticket list changes every few seconds
- Detect: new tickets, status moves, tag changes, title edits
- Dashboard only (not ticket detail pages)

Constraints:
- No conflict resolution needed for simultaneous edits
- Polling interval of a few seconds is acceptable

Entering plan mode to design the implementation...
```

## Notes

- Use this command when starting a new Claude session in a ticket worktree
- The short ID (8 chars) is matched against full UUIDs via `startsWith`
- Project config is found by looking at the main repo path, not the worktree
- After loading context, Claude automatically enters plan mode
