---
description: Regenerate and sync project documentation to AI Intent First
---

# /sync-docs - Sync Project Documentation

Update existing documentation and create any missing standard docs for the connected AI Intent First project.

## When to Use

Run this after:
- Adding new features or screens
- Changing business rules or workflows
- Introducing new domain terminology
- Any significant codebase changes that affect functional behavior

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

### 2. List Existing Docs

Call the MCP tool to list current documentation:

```
mcp__aintentfirst__list_project_docs with projectId
```

Note which standard docs exist:
- `TERMINOLOGY.md`
- `SCREENS.md`
- `USER_FLOWS.md`
- `BUSINESS_RULES.md`

### 3. Analyze Codebase

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

### 4. Update Existing Docs

For each standard doc that already exists:

1. Get the current content:
   ```
   mcp__aintentfirst__get_project_doc with projectId and docId
   ```

2. Compare with freshly analyzed content

3. If there are meaningful changes, update:
   ```
   mcp__aintentfirst__update_project_doc with:
     - projectId
     - docId
     - name: <same name>
     - content: <updated markdown content>
   ```

Show progress:
```
Checking TERMINOLOGY.md... updated
Checking SCREENS.md... no changes
Checking USER_FLOWS.md... updated
Checking BUSINESS_RULES.md... no changes
```

### 5. Create Missing Docs

For each standard doc type that doesn't exist:

Ask the user:

> `TERMINOLOGY.md` doesn't exist yet. Create it?
> - **Yes** - Generate and upload
> - **No** - Skip

If "Yes", create the doc:

```
mcp__aintentfirst__create_project_doc with:
  - projectId
  - name: "TERMINOLOGY.md"
  - content: <generated markdown content>
```

Repeat for each missing doc type.

### 6. Summary

Display a summary of changes:

```
Documentation sync complete for: <project-name>

Updated:
  - TERMINOLOGY.md (added 3 new terms)
  - USER_FLOWS.md (added checkout flow)

Created:
  - BUSINESS_RULES.md

Unchanged:
  - SCREENS.md

The LLM will use these updated docs when asking clarifying questions on new tickets.
```

## Doc Content Guidelines

### TERMINOLOGY.md

Format each term as:

```markdown
## Term Name

**Definition**: What this means in the context of this project.

**Usage**: Where/how this term is used in the application.
```

Focus on:
- Domain-specific nouns (entities, concepts)
- Status names and what they mean
- Role names and their permissions
- Any jargon unique to this project

### SCREENS.md

Format each screen as:

```markdown
## Screen Name

**Route**: `/path/to/screen`

**Purpose**: What users accomplish on this screen.

**Key Elements**:
- Element 1 - what it does
- Element 2 - what it does
```

### USER_FLOWS.md

Format each flow as:

```markdown
## Flow Name

**Goal**: What the user wants to accomplish.

**Steps**:
1. User does X on [Screen Name]
2. System responds with Y
3. User proceeds to [Next Screen]
4. ...

**Outcomes**:
- Success: What happens when flow completes
- Failure: What happens if something goes wrong
```

### BUSINESS_RULES.md

Format each rule as:

```markdown
## Rule Name

**Rule**: Clear statement of the constraint.

**Reason**: Why this rule exists.

**Enforcement**: Where/how this is enforced in the app.
```

## Notes

- This command requires `/init` to be run first
- Only standard doc types are auto-synced; custom docs are preserved
- The LLM uses these docs to ask better clarifying questions
- Run this before creating tickets about new features you've built
