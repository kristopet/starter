#!/bin/bash
# Show current worktree context and available commands

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Detect if we're in main or a worktree
CURRENT_DIR=$(pwd)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)

if [[ "$GIT_DIR" == *".git/worktrees"* ]]; then
    # We're in a worktree
    BRANCH=$(git branch --show-current)
    echo -e "${BLUE}📍 Current Location: WORKTREE${NC}"
    echo -e "🌿 Branch: ${GREEN}$BRANCH${NC}"
    echo -e "📁 Path: $CURRENT_DIR"
    echo -e "\n${YELLOW}Available Commands:${NC}"
    echo "  pnpm run dev              - Start dev server (port from .env.development.local)"
    echo "  pnpm run test             - Run tests for this feature"
    echo "  pnpm add <package>        - Add dependencies for this feature"
    echo -e "\n${YELLOW}When Ready to Merge:${NC}"
    echo "  1. Commit all changes in worktree"
    echo "  2. cd ../starter"
    echo "  3. git merge $BRANCH"
else
    # We're in main
    echo -e "${BLUE}📍 Current Location: MAIN PROJECT${NC}"
    echo -e "🌿 Branch: ${GREEN}$(git branch --show-current)${NC}"
    echo -e "📁 Path: $CURRENT_DIR"
    echo -e "\n${YELLOW}Available Commands:${NC}"
    echo "  pnpm run feature:new <name>     - Create new feature worktree"
    echo "  pnpm run feature:list           - List all worktrees"
    echo "  pnpm run feature:link-memory    - Re-link shared resources"
    echo "  pnpm run dev                    - Start main dev server (port 3000)"
    echo -e "\n${YELLOW}Worktrees:${NC}"
    git worktree list | grep -v "$(pwd)" | while read -r line; do
        echo "  - $line"
    done
fi

echo -e "\n${GREEN}Database Commands (run from anywhere):${NC}"
echo "  npx drizzle-kit push     - Apply schema to database"
echo "  npx drizzle-kit studio   - Open database GUI"