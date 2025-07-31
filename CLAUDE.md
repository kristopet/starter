# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

💡 **Tip**: Use `#` to quickly add important discoveries to this file during development.

## Quick Start
- **Local development**: Terminal 1: `pnpm run dev` | Terminal 2: `pnpm run webhook`
- **New feature**: `pnpm run feature:new <name>`  
- **Deploy**: Push to GitHub → Vercel auto-deploys

## Commands

### Development
- `pnpm run dev` - Start development server with Turbopack
- `pnpm run webhook` - Start ngrok tunnel for webhook testing
- `pnpm run dev:webhook` - Start dev server + ngrok in single terminal (alternative)
- `pnpm run build` - Build for production
- `pnpm run start` - Start production server
- `pnpm run feature:new <name>` - Create new feature worktree
- `pnpm run feature:list` - List all feature worktrees
- `pnpm run feature:clean` - Clean up deleted worktrees

### Code Quality
- `pnpm run lint` - Run ESLint
- `pnpm run lint:fix` - Run ESLint with auto-fix
- `pnpm run types` - Run TypeScript type checking
- `pnpm run format:write` - Format code with Prettier
- `pnpm run clean` - Run both lint:fix and format:write

### Database
- `npx drizzle-kit push` - Push schema changes to database
- `npx drizzle-kit generate` - Generate migration files
- `npx drizzle-kit migrate` - Run migrations
- `npx drizzle-kit studio` - Open Drizzle Studio for database management
- `npx bun db/seed` - Seed database with initial data
- `npx supabase start` - Start local Supabase instance
- `npx supabase stop` - Stop local Supabase instance

### Testing
- `pnpm run test` - Run all tests (unit + e2e)
- `pnpm run test:unit` - Run Jest unit tests
- `pnpm run test:unit -- path/to/test` - Run specific unit test
- `pnpm run test:e2e` - Run Playwright e2e tests
- `pnpm run test:e2e -- --ui` - Run Playwright tests with UI mode

### Shadcn UI Components
- `npx shadcn@latest add [component-name]` - Install new Shadcn UI components
- `npx shadcn@latest diff [component-name]` - Check for component updates

## Architecture

This is a Next.js 15 SaaS template using the App Router with clear separation between authenticated and unauthenticated routes.

### Route Structure
- `/app/(unauthenticated)` - Public routes
  - `(marketing)` - Landing pages, pricing, features
  - `(auth)` - Login and signup flows
- `/app/(authenticated)` - Protected routes requiring Clerk auth
  - `dashboard` - Main application with account, billing, support sections
- `/app/api` - API routes including Stripe webhook handler

### Key Patterns
- **Server Actions** in `/actions` for data mutations (customers, Stripe operations)
- **Database Schema** in `/db/schema` using Drizzle ORM with PostgreSQL
- **UI Components** in `/components/ui` from Shadcn UI library
- **Authentication** handled by Clerk middleware with protected route groups
- **Payments** integrated via Stripe with webhook handling

### Data Flow
1. Authentication state managed by Clerk (`@clerk/nextjs`)
2. Customer data stored in PostgreSQL via Drizzle ORM
3. Stripe integration for subscription management
4. Server actions handle all data mutations with proper auth checks

### Tech Stack
- **Framework**: Next.js 15 with Turbopack
- **Styling**: Tailwind CSS v4
- **Database**: PostgreSQL via Supabase
- **ORM**: Drizzle ORM
- **Authentication**: Clerk
- **Payments**: Stripe
- **UI Components**: Shadcn UI (built on Radix UI)
- **Testing**: Jest (unit) + Playwright (e2e)

### Environment Variables Required
- `DATABASE_URL` - PostgreSQL connection string
- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` - Clerk public key
- `CLERK_SECRET_KEY` - Clerk secret key
- `CLERK_WEBHOOK_SECRET` - Clerk webhook signing secret
- `STRIPE_SECRET_KEY` - Stripe secret key
- `STRIPE_WEBHOOK_SECRET` - Stripe webhook endpoint secret
- `NGROK_DOMAIN` - Your ngrok static domain for local webhook testing

### Webhook Setup
1. **Clerk**: Automatically creates customer records on user signup via `/api/clerk/webhooks`
2. **Stripe**: Handles subscription lifecycle via `/api/stripe/webhooks`
3. **Local Testing**: Terminal 1: `pnpm run dev` | Terminal 2: `pnpm run webhook`

#### Production Deployment Checklist
⚠️ **IMPORTANT**: When deploying to production, webhooks must be reconfigured:

**Clerk Production Webhook:**
1. Go to [Clerk Dashboard](https://dashboard.clerk.com) → Webhooks → Add Endpoint
2. Set endpoint URL: `https://your-vercel-url.vercel.app/api/clerk/webhooks`
3. Select events: `user.created`
4. Copy the new signing secret (different from local!)
5. Update Vercel env var: `CLERK_WEBHOOK_SECRET=whsec_...` (production secret)
6. Redeploy to apply changes

**Stripe Production Webhook:**
1. Go to [Stripe Dashboard](https://dashboard.stripe.com) → Webhooks → Add endpoint
2. Set endpoint URL: `https://your-vercel-url.vercel.app/api/stripe/webhooks`
3. Select relevant events for subscription lifecycle
4. Copy signing secret and update `STRIPE_WEBHOOK_SECRET` in Vercel
5. Redeploy to apply changes

💡 **Common Issue**: If users can sign up but customer records aren't created, the Clerk webhook isn't reaching your production app. Check webhook endpoint URL and signing secret.

### Database Connection Troubleshooting

**"Tenant or user not found" Error:**
This error typically means incorrect database credentials or connection string format.

**For Supabase Transaction Pooler:**
1. Go to Supabase Dashboard → Click "Connect"
2. Select "Connection pooling" → "Transaction" tab
3. Copy the exact connection string (port 6543)
4. Ensure it includes your actual password (not `[YOUR-PASSWORD]`)
5. Check that the region matches your project (e.g., `eu-north-1`)

**Common issues:**
- ❌ Wrong region in connection string (project may have moved)
- ❌ Missing or incorrect password
- ❌ Using direct connection instead of pooler connection
- ❌ SSL configuration conflicts (keep `prepare: false` only)

### Feature Development Workflow
1. Create feature: `pnpm run feature:new ai-chat`
2. Work in isolated worktree: `cd ../starter-ai-chat`
3. Each feature gets its own port and git branch
4. Merge when ready: `git merge feature/ai-chat`

#### Worktree Best Practices
- Worktrees are created as siblings (../starter-feature-name), not subfolders
- Only `.env.local` is symlinked - maintains proper isolation
- Each worktree gets its own `.claude/settings.json` with feature context
- Don't over-link configs - copy and adjust paths when needed
- MCP configs (.mcp.json) should be copied, not linked (due to absolute paths)

### Database Timing Issues
- Dashboard layout creates customer record on-demand if webhook hasn't fired yet
- This prevents "Tenant or user not found" errors during signup flow
- Common with async webhooks - the app now handles this gracefully

## Testing Memories
- When testing production env always remember to ask from user if the Clerk webhook has been set for production site
- Supabase free tier pauses databases after inactivity - check dashboard if "Tenant or user not found" errors occur
- Production webhooks need different signing secrets than local development

## Worktree Sync Workflow

### When to Sync

**Pull from Main** (`pnpm run sync:pull`)
- Starting work for the day
- When you need latest shared docs
- If main has important updates

**Push to Main** (`pnpm run sync:push`)
- Found something important
- End of work session
- Before merging feature
- Documented key decisions

### Example Daily Workflow
```bash
# Morning
cd ../starter-ai-chat
pnpm run sync:pull     # Get overnight updates

# During work
echo "- GPT-4 needs 8k context" >> .claude/memory/insights-ai-chat.md
echo "## Streaming Setup" >> docs/ai-chat/streaming.md

# Before lunch/end of day
pnpm run sync:push     # Share discoveries

# Before merge
pnpm run sync:push     # Final sync
cd ../starter
pnpm run feature:premerge feature/ai-chat
```

## Feature Development
- Use pnpm run feature:new <name> to create isolated feature worktrees
- Worktrees go in sibling directories (../starter-feature-name)
- Each worktree runs on its own port (main: 3000, features: 3001+)

## Database Issues
- "Tenant or user not found" often means Supabase is paused (free tier)
- Dashboard layout now creates customer records if webhook hasn't fired yet
- Always use pooler connection (port 6543) for Vercel deployments

## Webhook Setup
- Production webhooks need separate configuration from local
- Each environment needs its own webhook signing secret
- Check Clerk webhook logs if customer records aren't created

## Best Practices
- Only link .env.local to worktrees, copy other configs as needed
- Don't link .mcp.json (has absolute paths)
- Keep .claude folders separate for each worktree