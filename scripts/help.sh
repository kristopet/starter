#!/bin/bash
# Quick help for worktree workflow

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🚀 Kristo's Starter - Worktree Workflow${NC}"
echo ""

# Detect context
if [[ $(git rev-parse --git-dir 2>/dev/null) == *"worktrees"* ]]; then
    BRANCH=$(git branch --show-current)
    echo -e "${CYAN}📍 You're in a WORKTREE (${BRANCH})${NC}"
    echo ""
    echo -e "${YELLOW}Common Commands:${NC}"
    echo "  pnpm run dev          - Start dev server"
    echo "  pnpm run sync:pull    - Get latest docs/memories from main"
    echo "  pnpm run sync:push    - Share your discoveries with main"
    echo "  pnpm add <package>    - Add feature dependencies"
    echo ""
    echo -e "${YELLOW}When Done:${NC}"
    echo "  1. Commit all changes"
    echo "  2. pnpm run sync:push"
    echo "  3. cd ../starter"
    echo "  4. pnpm run feature:premerge $BRANCH"
    echo "  5. git merge $BRANCH"
else
    echo -e "${CYAN}📍 You're in MAIN PROJECT${NC}"
    echo ""
    echo -e "${YELLOW}Feature Commands:${NC}"
    echo "  pnpm run feature:new <name>    - Create new feature"
    echo "  pnpm run feature:list          - List all features"
    echo "  pnpm run feature:premerge <branch> - Validate before merge"
    echo ""
    echo -e "${YELLOW}Existing Features:${NC}"
    git worktree list | grep -v "$(pwd)" | while read -r line; do
        echo "  $line"
    done
fi

echo ""
echo -e "${GREEN}Quick Actions:${NC}"
echo "  pnpm run help         - Show this help"
echo "  pnpm run status       - Detailed status"
echo "  pnpm run sync         - Show sync status"
echo ""
echo -e "${BLUE}Need more? Check docs/WORKTREE_WORKFLOW.md${NC}"