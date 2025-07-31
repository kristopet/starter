# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

💡 **Tip**: Use `#` to quickly add important discoveries to this file during development.

## Quick Start
- **Test webhooks**: `pnpm run dev:webhook`
- **New feature**: `pnpm run feature:new <name>`
- **Deploy**: Push to GitHub → Vercel auto-deploys

## Commands

### Development
- `pnpm run dev` - Start development server with Turbopack
- `pnpm run dev:webhook` - Start dev server + ngrok for webhook testing
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
3. **Local Testing**: Use `pnpm run dev:webhook` with your ngrok domain

### Feature Development Workflow
1. Create feature: `pnpm run feature:new ai-chat`
2. Work in isolated worktree: `cd ../starter-ai-chat`
3. Each feature gets its own port and git branch
4. Merge when ready: `git merge feature/ai-chat`