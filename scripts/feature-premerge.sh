#!/bin/bash
# Pre-merge validation for feature worktrees

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

FEATURE_BRANCH=$1

if [ -z "$FEATURE_BRANCH" ]; then
    echo "Usage: pnpm run feature:premerge <branch-name>"
    echo "Example: pnpm run feature:premerge feature/ai-chat"
    exit 1
fi

echo -e "${YELLOW}🔍 Pre-merge validation for $FEATURE_BRANCH${NC}\n"

# Check if we're in main project
if [[ $(pwd) != */starter ]]; then
    echo -e "${RED}❌ Must run from main project directory${NC}"
    exit 1
fi

# 1. Check for uncommitted changes
echo "1. Checking for uncommitted changes in worktree..."
WORKTREE_PATH=$(git worktree list | grep "$FEATURE_BRANCH" | cut -d' ' -f1)
if [ -z "$WORKTREE_PATH" ]; then
    echo -e "${RED}❌ Worktree not found for $FEATURE_BRANCH${NC}"
    exit 1
fi

cd "$WORKTREE_PATH"
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}❌ Uncommitted changes in worktree:${NC}"
    git status --short
    exit 1
fi
echo -e "${GREEN}✓ Worktree is clean${NC}\n"

# 2. Check package.json changes
echo "2. Reviewing package.json changes..."
cd -
git diff main...$FEATURE_BRANCH -- package.json > /tmp/package-diff.txt
if [ -s /tmp/package-diff.txt ]; then
    echo -e "${YELLOW}📦 Package changes detected:${NC}"
    grep "^+" /tmp/package-diff.txt | grep -v "^+++" | grep '"' || true
    echo ""
fi

# 3. Check for database schema changes
echo "3. Checking for database schema changes..."
if git diff main...$FEATURE_BRANCH --name-only | grep -q "db/schema"; then
    echo -e "${YELLOW}🗄️  Database schema changes detected${NC}"
    echo "  Remember to run 'npx drizzle-kit push' after merging"
    echo ""
fi

# 4. Check for new environment variables
echo "4. Checking for new environment variables..."
git diff main...$FEATURE_BRANCH -- "*.ts" "*.tsx" | grep -E "process\.env\." | grep -v "^-" | sort -u > /tmp/env-check.txt || true
if [ -s /tmp/env-check.txt ]; then
    echo -e "${YELLOW}🔐 Possible new environment variables:${NC}"
    cat /tmp/env-check.txt
    echo ""
fi

# 5. Run basic checks
echo "5. Running basic checks..."
cd "$WORKTREE_PATH"

# Type check
echo -n "  Type checking... "
if pnpm run types > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "  Run 'pnpm run types' in worktree to see errors"
fi

# Lint check
echo -n "  Linting... "
if pnpm run lint > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "  Run 'pnpm run lint' in worktree to see errors"
fi

echo -e "\n${GREEN}✅ Pre-merge validation complete!${NC}"
echo -e "\nNext steps:"
echo "  1. cd $(pwd)"
echo "  2. git merge $FEATURE_BRANCH"
echo "  3. pnpm install (if package.json changed)"
echo "  4. npx drizzle-kit push (if schema changed)"