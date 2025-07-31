#!/bin/bash
# Link project memories across worktrees for shared learning

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔗 Linking project memories across worktrees...${NC}"

# Get the main project path
MAIN_PROJECT=$(pwd)
MAIN_MEMORY_PATH="$MAIN_PROJECT/.claude/memory"

# Create memory directory in main project if it doesn't exist
if [ ! -d "$MAIN_MEMORY_PATH" ]; then
    echo -e "${YELLOW}📁 Creating memory directory in main project...${NC}"
    mkdir -p "$MAIN_MEMORY_PATH"
fi

# Find all worktrees
WORKTREES=$(git worktree list --porcelain | grep "worktree" | cut -d' ' -f2 | grep -v "^$MAIN_PROJECT$")

if [ -z "$WORKTREES" ]; then
    echo -e "${YELLOW}No worktrees found. Run this after creating worktrees.${NC}"
    exit 0
fi

# Link memory for each worktree
for worktree in $WORKTREES; do
    if [ -d "$worktree" ]; then
        echo -e "\n${GREEN}Processing: $worktree${NC}"
        
        # Create .claude directory if it doesn't exist
        mkdir -p "$worktree/.claude"
        
        # Remove existing memory directory/link if it exists
        if [ -e "$worktree/.claude/memory" ]; then
            echo "  Removing existing memory directory..."
            rm -rf "$worktree/.claude/memory"
        fi
        
        # Create symlink to main project's memory
        ln -s "$MAIN_MEMORY_PATH" "$worktree/.claude/memory"
        echo -e "  ✅ Linked memory to main project"
        
        # Link docs folder if it exists in main project
        if [ -d "$MAIN_PROJECT/docs" ]; then
            # Remove existing docs directory/link if it exists
            if [ -e "$worktree/docs" ]; then
                echo "  Removing existing docs directory..."
                rm -rf "$worktree/docs"
            fi
            
            # Create symlink to main project's docs
            ln -s "$MAIN_PROJECT/docs" "$worktree/docs"
            echo -e "  ✅ Linked docs to main project"
        fi
    fi
done

echo -e "\n${GREEN}✨ Memory linking complete!${NC}"
echo -e "\nAll worktrees now share project memories with main branch."
echo -e "New discoveries in any worktree will be available everywhere."