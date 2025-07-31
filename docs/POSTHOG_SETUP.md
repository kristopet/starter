# PostHog Setup for AI SaaS

## 1. Install PostHog

```bash
pnpm add posthog-js
```

## 2. Create Provider

```typescript
// app/providers/posthog-provider.tsx
'use client'

import posthog from 'posthog-js'
import { PostHogProvider } from 'posthog-js/react'
import { useEffect } from 'react'
import { useAuth } from '@clerk/nextjs'

if (typeof window !== 'undefined') {
  posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
    api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST || 'https://app.posthog.com',
    capture_pageview: false, // We'll do this manually
    capture_pageleave: true,
  })
}

export function PHProvider({ children }: { children: React.ReactNode }) {
  const { userId } = useAuth()
  
  useEffect(() => {
    if (userId) {
      posthog.identify(userId)
    } else {
      posthog.reset()
    }
  }, [userId])

  return <PostHogProvider client={posthog}>{children}</PostHogProvider>
}
```

## 3. Add to Layout

```typescript
// app/layout.tsx
import { PHProvider } from './providers/posthog-provider'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <PHProvider>
          {children}
        </PHProvider>
      </body>
    </html>
  )
}
```

## 4. Track AI Events

```typescript
// In your AI chat component
import { usePostHog } from 'posthog-js/react'

function AIChat() {
  const posthog = usePostHog()
  
  const handleSend = async (message: string) => {
    posthog?.capture('ai_message_sent', {
      message_length: message.length,
      has_attachment: false,
    })
    
    const start = Date.now()
    const response = await generateAIResponse(message)
    
    posthog?.capture('ai_response_received', {
      duration_ms: Date.now() - start,
      token_count: response.tokens,
      model: 'gpt-4',
    })
  }
}
```

## 5. Key Events to Track

### User Journey
- `user_signed_up`
- `user_completed_onboarding`
- `subscription_started`
- `subscription_upgraded`

### AI Usage
- `ai_chat_started`
- `ai_message_sent`
- `ai_response_received`
- `ai_error_occurred`
- `token_limit_reached`

### Feature Discovery
- `feature_discovered`
- `feature_used_first_time`
- `advanced_feature_accessed`

## 6. Environment Variables

```env
NEXT_PUBLIC_POSTHOG_KEY=phc_xxxxxxxxxxxxx
NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com
```

## Why PostHog for AI SaaS?

1. **Custom Events**: Track exactly what matters for AI products
2. **Funnels**: See where users drop off in AI interactions
3. **Retention**: Track if users come back after first AI experience
4. **Feature Flags**: A/B test different AI models or prompts
5. **Session Recording**: Watch how users interact with AI features