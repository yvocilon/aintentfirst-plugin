# AI Intent First Plugin for Claude Code

A Claude Code plugin that integrates with [AI Intent First](https://aintentfirst.com) - a ticket clarification system where stakeholders write tickets, an LLM asks clarifying questions, and developers implement approved tickets.

## Installation

```bash
claude plugin install github:yvocilon/aintentfirst-plugin
```

## Commands

### `/init`

Connect the current repository to an AI Intent First project.

1. Configures the MCP server (prompts for API token if needed)
2. Lists available projects
3. Saves the project mapping for this repository
4. **Offers to generate project documentation** (if none exists)

When generating docs, Claude analyzes your codebase and creates:
- `TERMINOLOGY.md` - Project-specific terms and concepts
- `SCREENS.md` - UI screens and pages
- `USER_FLOWS.md` - Key user journeys
- `BUSINESS_RULES.md` - Domain constraints and rules

These docs help the LLM ask better clarifying questions when stakeholders create tickets.

```bash
# In your project directory
claude
> /init
```

### `/pick-ticket`

Pick up a todo ticket and start working on it.

1. Lists available "todo" tickets
2. Lets you approve/skip tickets
3. Creates a git worktree for isolated development
4. Opens a new terminal tab with Claude ready to implement

```bash
claude
> /pick-ticket
```

### `/resume-ticket`

Resume work on a ticket (auto-runs in new worktrees).

1. Detects ticket from branch name (`ticket/<id>`)
2. Fetches full ticket context from AI Intent First
3. Displays task summary and starts implementing

```bash
# In a ticket worktree
claude
> /resume-ticket
```

### `/sync-docs`

Update project documentation after making codebase changes.

1. Checks existing docs in AI Intent First
2. Re-analyzes the codebase for changes
3. Updates existing docs with new content
4. Offers to create any missing standard docs

Run this after adding new features, screens, or business rules.

```bash
claude
> /sync-docs
```

## How It Works

### Project Mapping

The plugin stores per-repo configuration at:
```
~/.claude/projects/<encoded-path>/.aintentfirst.json
```

This maps repositories to AI Intent First projects without adding files to your repo.

### Worktrees

When you pick a ticket, the plugin creates a git worktree:
- Branch: `ticket/<short-id>` (first 8 chars of ticket UUID)
- Location: `../<repo-name>-worktrees/ticket-<short-id>/`
- Automatically symlinks `.env` from main repo
- Installs dependencies (auto-detects pnpm/npm/yarn/bun)

### Terminal Integration

On macOS, `/pick-ticket` opens a new terminal tab (iTerm2 or Terminal.app) with Claude auto-running `/resume-ticket` to load context immediately.

## Requirements

- Claude Code CLI
- Git (for worktrees)
- An AI Intent First account and API token

## Getting an API Token

1. Go to https://aintentfirst.com/settings/tokens
2. Create a new token
3. Run `/init` and paste the token when prompted

## Workflow

1. Run `/init` once per repository to connect it to your AI Intent First project
2. Generate initial docs when prompted (or run `/sync-docs` later)
3. Run `/pick-ticket` to grab a ticket and start working
4. New Claude instance automatically loads ticket context
5. Implement the feature
6. Commit, push, and create PR
7. Use `complete_ticket` MCP tool to mark done
8. Run `/sync-docs` if you added new features, screens, or terminology

## License

MIT
