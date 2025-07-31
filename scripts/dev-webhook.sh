#!/bin/bash

# Simple webhook dev setup
echo "🚀 Starting Next.js + ngrok for webhook development..."

# Load NGROK_DOMAIN from .env.local
if [ -f .env.local ]; then
    source <(grep NGROK_DOMAIN .env.local)
fi

if [ -z "$NGROK_DOMAIN" ]; then
    echo "❌ NGROK_DOMAIN not found in .env.local"
    exit 1
fi

# Use GNU parallel or background processes
if command -v parallel &> /dev/null; then
    parallel --line-buffer ::: \
        "pnpm run dev" \
        "sleep 3 && ngrok http 3000 --domain=$NGROK_DOMAIN"
else
    # Fallback: simple background process
    pnpm run dev &
    sleep 3
    echo ""
    echo "📡 Starting ngrok on $NGROK_DOMAIN..."
    echo "🔗 Webhook URL: https://$NGROK_DOMAIN/api/clerk/webhooks"
    echo ""
    ngrok http 3000 --domain=$NGROK_DOMAIN
fi