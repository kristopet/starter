#!/bin/bash

# Simple webhook dev setup
echo "🚀 Starting Next.js + ngrok for webhook development..."

# Load NGROK_DOMAIN from .env.local
if [ -f .env.local ]; then
    export $(grep NGROK_DOMAIN .env.local | xargs)
fi

if [ -z "$NGROK_DOMAIN" ]; then
    echo "❌ NGROK_DOMAIN not found in .env.local"
    exit 1
fi

# Start Next.js in background
echo "🚀 Starting Next.js dev server..."
pnpm run dev &
NEXTJS_PID=$!

# Wait for Next.js to start
sleep 5

echo ""
echo "📡 Starting ngrok tunnel..."
echo "🔗 Webhook URL: https://$NGROK_DOMAIN/api/clerk/webhooks"
echo "🔗 Local dev: http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop both services"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    kill $NEXTJS_PID 2>/dev/null
    pkill -f "ngrok.*3000" 2>/dev/null
    exit 0
}

# Set trap for cleanup
trap cleanup INT TERM

# Start ngrok (this will keep the terminal open)
ngrok http 3000 --domain=$NGROK_DOMAIN