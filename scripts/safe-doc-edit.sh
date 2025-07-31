#!/bin/bash
# Safe documentation editing across worktrees

FILE=$1
if [ -z "$FILE" ]; then
    echo "Usage: ./safe-doc-edit.sh <file-path>"
    exit 1
fi

# Detect if we're in a worktree
if [[ $(git rev-parse --git-dir) == *"worktrees"* ]]; then
    BRANCH=$(git branch --show-current)
    echo "📝 Editing shared doc from worktree: $BRANCH"
    echo "⚠️  Changes will be visible in main project immediately"
    echo ""
    echo "Best practice: Add a section header with your feature name"
    echo "Example: ## AI Chat Integration Notes"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Edit the file
${EDITOR:-vim} "$FILE"

# Show what changed
echo ""
echo "📊 Changes made:"
git diff --no-index /dev/null "$FILE" 2>/dev/null || echo "(New file created)"