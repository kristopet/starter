#!/bin/bash
echo "🚀 Starting development server..."
npm run dev &

echo "⏳ Waiting for server to start..."
sleep 5

echo "🌐 Starting ngrok tunnel..."
ngrok http 3000