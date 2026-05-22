#!/bin/bash

# Notification System Testing Script
# Usage: ./test-notifications.sh <TOKEN> <TENANT_ID>

set -e

TOKEN=${1:-""}
TENANT_ID=${2:-""}

if [ -z "$TOKEN" ] || [ -z "$TENANT_ID" ]; then
    echo "Usage: ./test-notifications.sh <JWT_TOKEN> <TENANT_ID>"
    echo ""
    echo "How to get your token:"
    echo "  1. Open browser console (F12)"
    echo "  2. Run: localStorage.getItem('token')"
    echo "  3. Copy the value (without quotes)"
    echo ""
    echo "How to get your tenant ID:"
    echo "  1. Check x-tenant-id header in any API request (Network tab)"
    echo "  2. Or run: localStorage.getItem('tenantId')"
    echo ""
    exit 1
fi

API_URL="http://localhost:3000/api"
HEADERS="-H 'Authorization: Bearer $TOKEN' -H 'x-tenant-id: $TENANT_ID' -H 'Content-Type: application/json'"

echo "=========================================="
echo "Notification System Test Script"
echo "=========================================="
echo ""

# Test 1: Check if API is accessible
echo "Test 1: Check API Connectivity..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/notifications?limit=1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-tenant-id: $TENANT_ID")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" == "200" ]; then
    echo "✅ API is accessible (HTTP 200)"
    echo "   Response: $BODY"
else
    echo "❌ API returned HTTP $HTTP_CODE"
    echo "   Response: $BODY"
    echo "   Check your TOKEN and TENANT_ID"
    exit 1
fi

echo ""

# Test 2: Check notification preferences endpoint
echo "Test 2: Check Notification Preferences Endpoint..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/notifications/preferences" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-tenant-id: $TENANT_ID")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" == "200" ]; then
    echo "✅ Preferences endpoint works (HTTP 200)"
else
    echo "⚠️  Preferences endpoint returned HTTP $HTTP_CODE"
fi

echo ""

# Test 3: Create a test notification
echo "Test 3: Create Test Notification..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/notifications" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-tenant-id: $TENANT_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "low_stock",
    "title": "🧪 Test Low Stock Alert",
    "message": "This is a test notification to verify the system is working",
    "alertData": {
      "productId": "test-product-123",
      "productName": "Test Product",
      "currentStock": 5,
      "minThreshold": 10
    }
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" == "201" ] || [ "$HTTP_CODE" == "200" ]; then
    echo "✅ Test notification created (HTTP $HTTP_CODE)"
    NOTIF_ID=$(echo "$BODY" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "   Notification ID: $NOTIF_ID"
    echo ""
    echo "   💡 Check your browser now!"
    echo "   - Look for a toast notification in the bottom right"
    echo "   - Check notification center badge (should increment)"
    echo "   - Check DevTools Network tab for 'stream' request (should be active)"
else
    echo "❌ Failed to create notification (HTTP $HTTP_CODE)"
    echo "   Response: $BODY"
fi

echo ""

# Test 4: List all notifications
echo "Test 4: List All Notifications..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/notifications?limit=10&offset=0" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-tenant-id: $TENANT_ID")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" == "200" ]; then
    echo "✅ Notifications fetched successfully"
    # Extract count
    COUNT=$(echo "$BODY" | grep -o '"total":[0-9]*' | cut -d':' -f2)
    echo "   Total notifications: $COUNT"
    echo ""
    echo "   Response preview:"
    echo "$BODY" | head -c 500
    echo "..."
else
    echo "❌ Failed to fetch notifications (HTTP $HTTP_CODE)"
fi

echo ""
echo "=========================================="
echo "Tests Complete!"
echo "=========================================="
echo ""
echo "Next Steps:"
echo "1. Open DevTools (F12) → Network tab"
echo "2. Look for 'stream' request:"
echo "   - Status should be 200"
echo "   - Type should be 'eventsource'"
echo "   - Should stay 'pending' (long-lived connection)"
echo ""
echo "3. Check Frontend UI:"
echo "   - Toast should have appeared"
echo "   - Notification Center should show the test alert"
echo ""
echo "4. Verify in Database:"
echo "   psql -U postgres -d nest_erp"
echo "   SELECT * FROM notifications ORDER BY created_at DESC LIMIT 1;"
echo ""
