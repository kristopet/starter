#!/bin/bash
# Intelligent sync for worktree development

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detect context
CURRENT_DIR=$(pwd)
IS_WORKTREE=false
if [[ $(git rev-parse --git-dir 2>/dev/null) == *"worktrees"* ]]; then
    IS_WORKTREE=true
    FEATURE_NAME=$(basename "$CURRENT_DIR" | sed 's/starter-//')
    MAIN_DIR="../starter"
else
    MAIN_DIR="."
fi

# Function to sync memories
sync_memories() {
    echo -e "${BLUE}🧠 Syncing memories...${NC}"
    
    if [ "$IS_WORKTREE" = true ]; then
        # Pull latest memories from main
        mkdir -p .claude/memory
        if [ -f "$MAIN_DIR/.claude/memory/insights.md" ]; then
            cp "$MAIN_DIR/.claude/memory/insights.md" .claude/memory/insights-main.md
            echo "  ✓ Pulled main insights"
        fi
        
        # Push feature memories to main
        if [ -f ".claude/memory/insights-$FEATURE_NAME.md" ]; then
            cp ".claude/memory/insights-$FEATURE_NAME.md" "$MAIN_DIR/.claude/memory/"
            echo "  ✓ Pushed $FEATURE_NAME insights to main"
        fi
    else
        # In main, collect all feature insights
        for insight in .claude/memory/insights-*.md; do
            if [ -f "$insight" ]; then
                feature=$(basename "$insight" .md | sed 's/insights-//')
                echo "  ✓ Found insights from $feature"
            fi
        done
    fi
}

# Function to sync docs
sync_docs() {
    echo -e "${BLUE}📚 Syncing documentation...${NC}"
    
    if [ "$IS_WORKTREE" = true ]; then
        # Create feature doc space
        mkdir -p "docs/$FEATURE_NAME"
        
        # Sync only non-feature-specific docs
        rsync -a --exclude="*/" "$MAIN_DIR/docs/"*.md docs/ 2>/dev/null || true
        echo "  ✓ Synced shared docs from main"
        
        # Push feature docs to main
        if [ -d "docs/$FEATURE_NAME" ] && [ "$(ls -A docs/$FEATURE_NAME)" ]; then
            mkdir -p "$MAIN_DIR/docs/$FEATURE_NAME"
            rsync -a "docs/$FEATURE_NAME/" "$MAIN_DIR/docs/$FEATURE_NAME/"
            echo "  ✓ Pushed $FEATURE_NAME docs to main"
        fi
    fi
}

# Function to show status
show_status() {
    echo -e "${BLUE}📊 Sync Status${NC}"
    echo ""
    
    if [ "$IS_WORKTREE" = true ]; then
        echo "Feature: $FEATURE_NAME"
        echo "Location: Worktree"
        
        # Check what's out of sync
        if [ -f ".claude/memory/insights-$FEATURE_NAME.md" ]; then
            mod_time=$(stat -f %m ".claude/memory/insights-$FEATURE_NAME.md" 2>/dev/null || stat -c %Y ".claude/memory/insights-$FEATURE_NAME.md")
            echo "✓ Feature insights: Last updated $(date -r $mod_time '+%Y-%m-%d %H:%M')"
        else
            echo "○ No feature insights yet"
        fi
    else
        echo "Location: Main project"
        echo "Worktree insights available:"
        ls .claude/memory/insights-*.md 2>/dev/null | sed 's/.*insights-/  - /' | sed 's/.md//' || echo "  None"
    fi
}

# Main execution
case "${1:-status}" in
    pull)
        if [ "$IS_WORKTREE" = true ]; then
            sync_memories
            sync_docs
            echo -e "\n${GREEN}✓ Pulled latest from main${NC}"
        else
            echo -e "${YELLOW}Pull only works from worktrees${NC}"
        fi
        ;;
    push)
        if [ "$IS_WORKTREE" = true ]; then
            sync_memories
            sync_docs
            echo -e "\n${GREEN}✓ Pushed changes to main${NC}"
        else
            echo -e "${YELLOW}Push only works from worktrees${NC}"
        fi
        ;;
    status)
        show_status
        ;;
    *)
        echo "Usage: pnpm run sync [pull|push|status]"
        echo ""
        echo "Commands:"
        echo "  pull   - Pull latest docs/memories from main"
        echo "  push   - Push feature docs/memories to main"
        echo "  status - Show sync status"
        ;;
esac