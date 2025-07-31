#!/bin/bash

# Load NGROK_DOMAIN from .env.local
if [ -f .env.local ]; then
    export $(grep NGROK_DOMAIN .env.local | xargs)
fi

if [ -z "$NGROK_DOMAIN" ]; then
    echo "❌ NGROK_DOMAIN not found in .env.local"
    exit 1
fi

# Find Next.js dev server port
echo "🔍 Looking for Next.js dev server..."

# Find all Next.js processes in the current directory
NEXTJS_PROCESSES=$(ps aux | grep "next dev" | grep -v grep | grep "$(pwd)")

if [ -z "$NEXTJS_PROCESSES" ]; then
    echo "❌ No Next.js dev server found in current directory!"
    echo "💡 Make sure 'pnpm run dev' is running in another terminal"
    exit 1
fi

# Try to detect the port by checking which ports respond to HTTP
PORT=""
for test_port in 3000 3001 3002 3003 3004 3005 3006 3007 3008 3009; do
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$test_port" --max-time 1 | grep -q "200\|404\|301\|302"; then
        # Verify it's actually Next.js by checking for _next
        if curl -s "http://localhost:$test_port" --max-time 1 | grep -q "_next\|Next.js"; then
            PORT=$test_port
            echo "✅ Found Next.js on port $PORT"
            break
        fi
    fi
done

if [ -z "$PORT" ]; then
    # Fallback: try to extract from PID using different lsof approach
    NEXTJS_PID=$(echo "$NEXTJS_PROCESSES" | head -1 | awk '{print $2}')
    PORT=$(sudo lsof -Pan -p $NEXTJS_PID -i 2>/dev/null | grep LISTEN | head -1 | sed -n 's/.*:\([0-9]*\) (LISTEN).*/\1/p')
    
    if [ -n "$PORT" ]; then
        echo "✅ Found Next.js on port $PORT (PID: $NEXTJS_PID)"
    fi
fi

if [ -n "$PORT" ]; then
    echo "🔗 Starting ngrok tunnel: https://$NGROK_DOMAIN -> localhost:$PORT"
    echo "🌐 Webhook URL: https://$NGROK_DOMAIN/api/clerk/webhooks"
    echo ""
    ngrok http $PORT --domain=$NGROK_DOMAIN
else
    echo "❌ Could not detect Next.js port automatically"
    echo ""
    echo "Please specify the port manually:"
    echo "  ngrok http [PORT] --domain=$NGROK_DOMAIN"
    echo ""
    echo "Common ports: 3000, 3001, 3002, 3003, 3004"
    exit 1
fi