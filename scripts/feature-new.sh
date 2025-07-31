#!/bin/bash
set -e

FEATURE_NAME=$1
if [ -z "$FEATURE_NAME" ]; then
    echo "Usage: npm run feature:new <feature-name>"
    echo "Example: npm run feature:new ai-chat"
    exit 1
fi

# Create worktree
WORKTREE_PATH="../starter-$FEATURE_NAME"
BRANCH_NAME="feature/$FEATURE_NAME"

echo "🌳 Creating worktree for feature: $FEATURE_NAME"
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"

# Setup the worktree
cd "$WORKTREE_PATH"

# Link environment variables
ln -sf ../starter/.env.local .env.local

# Create development port config
PORT=$((3000 + $(git worktree list | wc -l)))
echo "PORT=$PORT" > .env.development.local

# Create Claude settings
mkdir -p .claude
sed "s/{{FEATURE_NAME}}/$FEATURE_NAME/g" ../starter/scripts/claude-feature-template.json > .claude/settings.json

# Create local memory structure (not linked)
mkdir -p .claude/memory
echo "# $FEATURE_NAME Insights" > ".claude/memory/insights-$FEATURE_NAME.md"
echo "" >> ".claude/memory/insights-$FEATURE_NAME.md"
echo "## $(date '+%Y-%m-%d')" >> ".claude/memory/insights-$FEATURE_NAME.md"
echo "- Feature started" >> ".claude/memory/insights-$FEATURE_NAME.md"
echo "🧠 Created feature-specific memory file"

# Create local docs structure (not linked)
mkdir -p docs/$FEATURE_NAME
echo "# $FEATURE_NAME Documentation" > "docs/$FEATURE_NAME/README.md"
echo "📚 Created feature-specific docs folder"

# Initial sync from main
echo ""
echo "🔄 Syncing from main project..."
bash ../starter/scripts/feature-sync.sh pull

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install

echo "
✅ Feature worktree created successfully!

📁 Location: $WORKTREE_PATH
🌿 Branch: $BRANCH_NAME
🚪 Dev Port: $PORT

🎯 Next steps:
   1. cd $WORKTREE_PATH
   2. Open in Cursor/VS Code
   3. npm run dev
"