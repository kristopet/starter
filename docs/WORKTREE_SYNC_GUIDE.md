# Worktree Sync Strategy

## What Should Be Shared (Symlinked)

### ✅ Read-Only Resources
- `.env.local` - Secrets (rarely change)
- `docs/` - Reference documentation
- `public/assets/` - Shared images/fonts (if needed)

### ⚠️ Carefully Shared (Current Setup)
- `.claude/memory/` - Project learnings
  - Risk: Conflicting writes from multiple worktrees
  - Mitigation: Write feature-specific memories with prefixes

## What Should NOT Be Shared

### ❌ Never Share
- `node_modules/` - Package isolation
- `.next/` - Build outputs
- `package.json` - Feature-specific deps
- DB migrations - Until ready to merge

## Safe 2-Way Patterns

### Pattern 1: Read from Main, Write to Worktree
```bash
# Copy when needed, don't link
cp ../starter/docs/template.md docs/new-feature.md
# Edit locally, merge back when ready
```

### Pattern 2: Namespaced Shared Resources
```bash
# In memory files, use prefixes
echo "[AI_CHAT] GPT-4 context limits" >> .claude/memory/learnings.md
echo "[AUTH_V2] JWT rotation strategy" >> .claude/memory/learnings.md
```

### Pattern 3: Event-Based Sync (Advanced)
```bash
# Watch for changes and sync selectively
fswatch -o docs/ | while read f; do
  echo "Docs changed, consider syncing"
done
```

## Recommended Changes

1. **Unlink docs if you need feature-specific documentation**
   ```bash
   rm docs  # Remove symlink
   mkdir docs
   cp ../starter/docs/*.md docs/  # Copy what you need
   ```

2. **Keep memory linked but namespace entries**
   ```bash
   # Always prefix memory entries
   echo "[${FEATURE_NAME}] Discovery here" >> .claude/memory/insights.md
   ```

3. **Create feature-specific folders**
   ```bash
   mkdir docs/ai-chat-specific/
   # These won't conflict with main
   ```