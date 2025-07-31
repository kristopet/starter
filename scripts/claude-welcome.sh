#!/bin/bash
# Claude Code session welcome

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          🚀 Kristo's Starter - Claude Code             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Show context
BRANCH=$(git branch --show-current)
if [[ $(git rev-parse --git-dir 2>/dev/null) == *"worktrees"* ]]; then
    echo -e "${CYAN}📍 WORKTREE: $(basename $(pwd)) (${BRANCH})${NC}"
    PORT=$(grep PORT .env.development.local 2>/dev/null | cut -d= -f2 || echo "3000")
    echo -e "🚪 Dev Port: ${PORT}"
    echo ""
    echo -e "${YELLOW}Quick Commands:${NC}"
    echo "  pnpm run dev          - Start dev server"
    echo "  pnpm run sync:pull    - Get updates from main"
    echo "  pnpm run sync:push    - Share discoveries"
else
    echo -e "${CYAN}📍 MAIN PROJECT (${BRANCH})${NC}"
    echo ""
    echo -e "${YELLOW}Quick Commands:${NC}"
    echo "  pnpm run feature:new  - Create feature"
    echo "  pnpm run feature:list - List features"
fi

echo ""
echo -e "${GREEN}Always: pnpm run help${NC} for full command list"
echo ""

# Show any pending sync
if [[ $(git rev-parse --git-dir 2>/dev/null) == *"worktrees"* ]]; then
    FEATURE=$(basename $(pwd) | sed 's/starter-//')
    if [ -f "../starter/.claude/memory/insights-main.md" ]; then
        MAIN_DATE=$(stat -f %m "../starter/.claude/memory/insights-main.md" 2>/dev/null || stat -c %Y "../starter/.claude/memory/insights-main.md" 2>/dev/null)
        CURRENT_DATE=$(date +%s)
        DIFF=$(( ($CURRENT_DATE - $MAIN_DATE) / 86400 ))
        if [ $DIFF -gt 1 ]; then
            echo -e "${YELLOW}💡 Main insights updated $DIFF days ago. Run: pnpm run sync:pull${NC}"
        fi
    fi
fi

# Show git status summary
CHANGES=$(git status --porcelain | wc -l)
if [ $CHANGES -gt 0 ]; then
    echo -e "${YELLOW}📝 You have $CHANGES uncommitted changes${NC}"
fi

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"