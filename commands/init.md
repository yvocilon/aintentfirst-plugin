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

Check if this repo is already connected to a project. First get the current directory:

```bash
pwd
```

Take the output (e.g., `/Users/yvocilon/Repos/note-taker`) and replace all `/` with `%2F` to get the encoded path.

Then check for existing config:

```bash
cat ~/.claude/projects/<ENCODED_PATH>/.aintentfirst.json 2>/dev/null
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

Create the config directory using the encoded path from step 3:

```bash
mkdir -p ~/.claude/projects/<ENCODED_PATH>
```

Then write the JSON file with this structure:

```json
{
  "projectId": "<selected-project-uuid>",
  "projectName": "<selected-project-name>",
  "connectedAt": "<ISO-8601-timestamp>"
}
```

Save to: `~/.claude/projects/<ENCODED_PATH>/.aintentfirst.json`

### 7. Check for Existing Project Docs

Call the MCP tool to list existing documentation:

```
mcp__aintentfirst__list_project_docs with projectId
```

If docs already exist, skip to step 11 (Confirm).

### 8. Offer to Generate Docs

If no docs exist, ask the user:

> **No project documentation found.**
>
> I can analyze this codebase and generate functional documentation to help the LLM ask better clarifying questions on tickets.
>
> This will create:
> - `TERMINOLOGY.md` - Project-specific terms and concepts
> - `SCREENS.md` - UI screens and pages
> - `USER_FLOWS.md` - Key user journeys
> - `BUSINESS_RULES.md` - Domain constraints and rules
>
> **Generate documentation now?**
> - **Yes** - Analyze codebase and upload docs
> - **No** - Skip for now (you can run `/sync-docs` later)

If "No", skip to step 11 (Confirm).

### 9. Analyze Codebase

Use the Explore agent to analyze the codebase for functional aspects:

1. **Terminology**: Look for domain-specific terms in code comments, variable names, type definitions, and documentation files. Focus on business concepts, not technical terms.

2. **Screens**: Find React components that represent pages/screens. Look in routes, pages, or views directories. Note the purpose of each screen.

3. **User Flows**: Trace how users accomplish key tasks. Look at route structures, form submissions, and state transitions.

4. **Business Rules**: Find validation logic, permission checks, status transitions, and constraints in the code.

Focus on **functional aspects visible to stakeholders**, not technical implementation details. Skip:
- Tech stack details
- API endpoint implementations
- Database schema specifics
- Code patterns and architecture

### 10. Upload Documentation

For each doc type that has meaningful content, create a project document:

```
mcp__aintentfirst__create_project_doc with:
  - projectId: <selected-project-uuid>
  - name: "TERMINOLOGY.md" (or SCREENS.md, USER_FLOWS.md, BUSINESS_RULES.md)
  - content: <generated markdown content>
```

Show progress as each doc is uploaded:

```
Uploading TERMINOLOGY.md... ✓
Uploading SCREENS.md... ✓
Uploading USER_FLOWS.md... ✓
Uploading BUSINESS_RULES.md... ✓
```

### 11. Confirm

Display confirmation:

```
Connected to AI Intent First project: <project-name>

You can now use:
  /pick-ticket   - Pick up a todo ticket and create a worktree
  /resume-ticket - Resume work on the current ticket
  /sync-docs     - Update project documentation
```

If docs were generated, also show:

```
Project documentation uploaded:
  - TERMINOLOGY.md
  - SCREENS.md
  - USER_FLOWS.md
  - BUSINESS_RULES.md

The LLM will use these docs when asking clarifying questions on new tickets.
```

## Notes

- The config is stored per-repo in `~/.claude/projects/<encoded-path>/`
- The MCP scope is `local` so it only applies to this project
- Re-running `/init` allows changing the connected project
- Use `/sync-docs` to update documentation after making changes to the codebase
