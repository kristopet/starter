# Worktree Development Workflow

## Quick Reference

### Where to Run Commands

| Command | Run From | Purpose |
|---------|----------|---------|
| `pnpm run feature:new <name>` | Main only | Create new worktree |
| `pnpm run feature:list` | Anywhere | List all worktrees |
| `pnpm run feature:link-memory` | Main only | Re-link shared resources |
| `pnpm run dev` | Anywhere | Start dev server |
| `pnpm add <package>` | Worktree | Add feature dependencies |
| `npx drizzle-kit push` | Anywhere | Apply DB schema |
| `git merge feature/<name>` | Main only | Merge feature |

### Database Migration Strategy

**Best Practice: Schema-First Development**

1. **Define Schema in Worktree First**
   ```bash
   # In worktree
   # Edit db/schema files
   npx drizzle-kit generate  # Generate migration
   npx drizzle-kit push      # Test on shared DB
   ```

2. **Document Breaking Changes**
   ```bash
   # Create migration notes
   echo "Added ai_conversations table" > migrations/README.md
   ```

3. **Merge Schema Before Code**
   ```bash
   # In main
   git merge feature/ai-chat -- db/schema
   npx drizzle-kit push  # Apply to ensure compatibility
   # Then merge rest
   git merge feature/ai-chat
   ```

### Package Management Rules

**DO:**
- Add feature-specific packages in worktree
- Document why each package is needed
- Review package.json diff before merging

**DON'T:**
- Update core packages (Next.js, React) in worktree
- Add conflicting versions of existing packages
- Install without documenting purpose

### Testing Strategy

1. **Worktree Testing**
   ```bash
   # Test feature in isolation
   pnpm run test:unit
   pnpm run dev  # Manual testing on feature port
   ```

2. **Integration Testing**
   ```bash
   # Run both main and worktree
   # Terminal 1: cd starter && pnpm run dev
   # Terminal 2: cd starter-ai-chat && pnpm run dev
   # Test interaction between services
   ```

3. **Pre-Merge Checklist**
   - [ ] All tests pass in worktree
   - [ ] No console errors
   - [ ] Package.json changes reviewed
   - [ ] Schema migrations documented
   - [ ] Integration tested with main

### Common Pitfalls & Solutions

| Problem | Solution |
|---------|----------|
| "Which directory am I in?" | Run `pnpm run status` |
| "Database out of sync" | Always `drizzle-kit push` after schema changes |
| "Package conflicts on merge" | Review & resolve in worktree first |
| "Forgot what changed" | Use `git diff main...HEAD` in worktree |
| "Port conflicts" | Check .env.development.local for port |

### Emergency Procedures

**Worktree is broken:**
```bash
cd ../starter
git worktree remove ../starter-<feature> --force
git branch -D feature/<name>
# Start fresh
pnpm run feature:new <name>
```

**Need to sync with main:**
```bash
# In worktree
git fetch origin
git rebase origin/main
# Fix conflicts if any
```

**Accidentally installed in wrong directory:**
```bash
# Check git status first
git status
# If clean, just remove node_modules
rm -rf node_modules
pnpm install
```