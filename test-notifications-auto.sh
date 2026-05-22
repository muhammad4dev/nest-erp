#!/bin/bash

# Automated Notification Test - Attempts to extract token from browser first
# This script tries to connect to the frontend and extract auth data

set -e

echo "=========================================="
echo "Automated Notification Test"
echo "=========================================="
echo ""

# Check if frontend is running
echo "Checking if frontend is running..."
if ! curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo "❌ Frontend not running on http://localhost:5173"
    echo ""
    echo "Start frontend first:"
    echo "  cd frontend && pnpm run dev"
    exit 1
fi

echo "✅ Frontend is running"
echo ""

# Check if backend is running
echo "Checking if backend is running..."
if ! curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "⚠️  Backend health check failed (may still be starting)"
fi

echo ""
echo "=========================================="
echo "Manual Token Collection"
echo "=========================================="
echo ""
echo "To run the automated test, we need your auth token."
echo ""
echo "Option 1: Get token from browser"
echo "  1. Open http://localhost:5173 in your browser"
echo "  2. Press F12 (DevTools)"
echo "  3. Go to Console tab"
echo "  4. Paste: localStorage.getItem('token')"
echo "  5. Copy the full JWT string (including quotes)"
echo ""
echo "Option 2: Get token from localStorage file"
echo "  - Token is stored in browser's localStorage"
echo "  - Usually found in IndexedDB or localStorage exports"
echo ""

# Try to read from common browser storage locations
FOUND_TOKEN=""

# Check if we can extract from a browser profile (unlikely but worth trying)
if [ -d "$HOME/.config/google-chrome/Default/Local Storage" ]; then
    echo "Checking Chrome Local Storage..."
fi

if [ -z "$FOUND_TOKEN" ]; then
    echo "❌ Could not auto-detect token from browser storage"
    echo ""
    echo "Please provide your token manually:"
    echo ""
    read -p "Enter your JWT token: " TOKEN
    read -p "Enter your Tenant ID: " TENANT_ID
else
    echo "✅ Found token in browser storage"
    TENANT_ID=$(grep -o '"tenantId":"[^"]*"' 2>/dev/null | head -1 | cut -d'"' -f4)
fi

if [ -z "$TOKEN" ] || [ -z "$TENANT_ID" ]; then
    echo "❌ Token and Tenant ID are required"
    exit 1
fi

echo ""
echo "Running notification tests..."
echo ""

# Run the main test script
/home/m/Projects/nest-erp/test-notifications.sh "$TOKEN" "$TENANT_ID"
