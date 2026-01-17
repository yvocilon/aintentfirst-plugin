---
description: Connect current repo to an AI Intent First project and configure MCP access
---

# /init - Connect Repository to AI Intent First

Connect the current repository to an AI Intent First project and configure MCP access.

## Steps

### 1. Check MCP Configuration

Run this command to check if the MCP is already configured:

```bash
claude mcp get aintentfirst
```

- If it returns configuration, the MCP is set up - skip to step 3
- If it fails or returns nothing, proceed to step 2

### 2. Configure MCP Access

If MCP is not configured, ask the user for their API token:

> To connect to AI Intent First, I need your API token.
>
> Get one at: https://aintentfirst.com/settings/tokens
>
> Please paste your token:

Once you have the token, run:

```bash
claude mcp add --transport http \
  --header "Authorization: Bearer <TOKEN>" \
  aintentfirst https://aintentfirst.com/api/mcp -s local
```

Replace `<TOKEN>` with the user's token. This configures the MCP for the local project scope.

### 3. Check Existing Project Mapping

Check if this repo is already connected to a project:

```bash
cat ~/.claude/projects/$(echo "$PWD" | sed 's/\//%2F/g')/.aintentfirst.json 2>/dev/null
```

If a mapping exists, show the current connection and ask if they want to change it.

### 4. List Available Projects

Call the MCP tool to list projects:

```
mcp__aintentfirst__list_projects
```

Display the available projects to the user.

### 5. Select Project

Ask the user which project to connect to this repository.

If there's only one project, suggest it as the default.

### 6. Save Project Mapping

Create the config directory and save the mapping:

```bash
CONFIG_DIR=~/.claude/projects/$(echo "$PWD" | sed 's/\//%2F/g')
mkdir -p "$CONFIG_DIR"
```

Then write the JSON file with this structure:

```json
{
  "projectId": "<selected-project-uuid>",
  "projectName": "<selected-project-name>",
  "connectedAt": "<ISO-8601-timestamp>"
}
```

Save to: `$CONFIG_DIR/.aintentfirst.json`

### 7. Confirm

Display confirmation:

```
Connected to AI Intent First project: <project-name>

You can now use:
  /pick-ticket  - Pick up a todo ticket and create a worktree
  /resume-ticket - Resume work on the current ticket
```

## Notes

- The config is stored per-repo in `~/.claude/projects/<encoded-path>/`
- The MCP scope is `local` so it only applies to this project
- Re-running `/init` allows changing the connected project
