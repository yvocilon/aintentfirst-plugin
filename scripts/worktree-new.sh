#!/bin/bash
set -euo pipefail

# Portable worktree creation script
# Works with any git repository - auto-detects package manager and project structure

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    echo "Usage: $0 <ticket-id-or-branch-name> [base-branch]"
    echo ""
    echo "Creates a new git worktree for parallel development."
    echo ""
    echo "Arguments:"
    echo "  ticket-id-or-branch-name   Ticket ID (UUID) or branch name"
    echo "  base-branch                Base branch (default: main)"
    echo ""
    echo "Examples:"
    echo "  $0 abc12345-6789-...       # Full UUID from AI Intent First"
    echo "  $0 abc12345                # Short ID"
    echo "  $0 feature/dark-mode       # Custom branch name"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

TICKET_OR_BRANCH="$1"
BASE_BRANCH="${2:-main}"

# Detect repo root (works from anywhere in the repo)
MAIN_REPO="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
}

REPO_NAME="$(basename "$MAIN_REPO")"
WORKTREES_DIR="$(dirname "$MAIN_REPO")/${REPO_NAME}-worktrees"

# Determine branch name and worktree directory
# If it looks like a UUID (has dashes and hex chars), treat as ticket ID
if [[ "$TICKET_OR_BRANCH" =~ ^[a-f0-9-]{8,} ]]; then
    # Use first 8 chars for short name
    SHORT_ID="${TICKET_OR_BRANCH:0:8}"
    BRANCH_NAME="ticket/${SHORT_ID}"
    WORKTREE_NAME="ticket-${SHORT_ID}"
else
    BRANCH_NAME="$TICKET_OR_BRANCH"
    WORKTREE_NAME=$(echo "$TICKET_OR_BRANCH" | tr '/' '-')
fi

WORKTREE_PATH="${WORKTREES_DIR}/${WORKTREE_NAME}"

echo -e "${BLUE}=== Creating Worktree ===${NC}"
echo "Repository: $REPO_NAME"
echo "Branch: $BRANCH_NAME"
echo "Path:   $WORKTREE_PATH"
echo "Base:   $BASE_BRANCH"
echo ""

# Create worktrees directory
mkdir -p "$WORKTREES_DIR"

# Work from main repo
cd "$MAIN_REPO"

# Fetch latest
echo -e "${YELLOW}Fetching latest from origin...${NC}"
git fetch origin

# Create worktree (with new branch or existing)
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo -e "${YELLOW}Branch '$BRANCH_NAME' exists, using it${NC}"
    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
else
    echo -e "${GREEN}Creating branch '$BRANCH_NAME' from 'origin/$BASE_BRANCH'${NC}"
    git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "origin/$BASE_BRANCH"
fi

cd "$WORKTREE_PATH"

# Symlink .env if it exists in main repo
if [ ! -e ".env" ] && [ -e "${MAIN_REPO}/.env" ]; then
    echo -e "${YELLOW}Symlinking .env...${NC}"
    ln -s "${MAIN_REPO}/.env" .env
fi

# Auto-detect package manager and install dependencies
install_deps() {
    if [ -f "pnpm-lock.yaml" ]; then
        echo -e "${YELLOW}Installing dependencies with pnpm...${NC}"
        pnpm install --prefer-offline
    elif [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
        echo -e "${YELLOW}Installing dependencies with bun...${NC}"
        bun install
    elif [ -f "yarn.lock" ]; then
        echo -e "${YELLOW}Installing dependencies with yarn...${NC}"
        yarn install --prefer-offline
    elif [ -f "package-lock.json" ]; then
        echo -e "${YELLOW}Installing dependencies with npm...${NC}"
        npm ci
    elif [ -f "package.json" ]; then
        echo -e "${YELLOW}Installing dependencies with npm (no lockfile)...${NC}"
        npm install
    else
        echo -e "${YELLOW}No package.json found, skipping dependency install${NC}"
    fi
}

install_deps

# Run type generation if it's a React Router project
if [ -f "package.json" ] && grep -q "react-router" package.json 2>/dev/null; then
    echo -e "${YELLOW}Generating types...${NC}"
    if [ -f "pnpm-lock.yaml" ]; then
        pnpm exec react-router typegen 2>/dev/null || true
    elif [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
        bunx react-router typegen 2>/dev/null || true
    else
        npx react-router typegen 2>/dev/null || true
    fi
fi

echo ""
echo -e "${GREEN}=== Worktree Ready ===${NC}"
echo ""
echo -e "Path: ${BLUE}$WORKTREE_PATH${NC}"

# Output the path for scripts to capture
echo ""
echo "WORKTREE_PATH=$WORKTREE_PATH"
