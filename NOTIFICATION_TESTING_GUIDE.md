# Notification System Testing Guide

## Quick Verification Checklist

### 1. Database Tables Created ✓

```bash
# Connect to PostgreSQL
psql -U postgres -d nest_erp

# In psql:
\dt notifications
\dt notification_preferences

# You should see both tables exist
```

The migration already ran successfully (exit code 0), so tables should exist.

---

## 2. Backend SSE Endpoint Verification

### Check TypeScript Compilation

```bash
cd backend
pnpm exec tsc -p tsconfig.build.json --noEmit
```

✓ Already passed - no errors

### Check NotificationsModule is Loaded

1. Look at backend terminal output during startup - should see:
   ```
   [Nest] ... NestFactory bootstrapped successfully
   ```
2. No errors about missing `NotificationsModule` or `NotificationService`

---

## 3. Browser SSE Connection Test

### Step A: Open Browser DevTools

1. **Open Frontend** at `http://localhost:5173`
2. Press **F12** to open DevTools
3. Go to **Network** tab

### Step B: Check SSE Stream Connection

1. Log in with your user account
2. Look in Network tab for a request named `stream`
3. Click on it - you should see:
   - **Method**: GET
   - **URL**: `/api/notifications/stream?token=...&tenantId=...`
   - **Status**: 200 (long-lived connection, stays pending)
   - **Type**: `eventsource`

### Step C: Monitor Console Messages

1. Go to **Console** tab in DevTools
2. Look for log messages like:
   ```
   Connecting to SSE stream...
   SSE stream connected!
   Received notification: {...}
   ```

If you see any red errors about "x-tenant-id header is required", the tenant middleware isn't recognizing the query param (but this was already fixed).

---

## 4. Test 1: Manual Notification Creation (Fastest)

### Via cURL

```bash
# Get your auth token and tenant ID first
# Then run:

curl -X POST http://localhost:3000/api/notifications \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>" \
  -H "x-tenant-id: <YOUR_TENANT_ID>" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "low_stock",
    "title": "Test Low Stock Alert",
    "message": "Product ABC has fallen below minimum threshold",
    "alertData": {
      "productId": "test-product-123",
      "currentStock": 5,
      "minThreshold": 10
    }
  }'
```

**Expected Response**:

```json
{
  "id": "...",
  "type": "low_stock",
  "title": "Test Low Stock Alert",
  "status": "new",
  "createdAt": "2026-05-10T..."
}
```

### What Should Happen in Frontend

1. **SSE stream receives** the new notification event
2. **Toast notification** appears in browser with the title/message
3. **Notification Center badge** (if shown) increments unread count
4. **Notification Center** shows the new notification when opened

---

## 5. Test 2: Trigger via Stock Change (Real Flow)

### Step A: Get a Product ID

```bash
curl -X GET http://localhost:3000/api/inventory/products \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>" \
  -H "x-tenant-id: <YOUR_TENANT_ID>"
```

Pick a product ID from the response.

### Step B: Get a Location ID

```bash
curl -X GET http://localhost:3000/api/inventory/locations \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>" \
  -H "x-tenant-id: <YOUR_TENANT_ID>"
```

Pick a location ID from the response.

### Step C: Set Low Stock Preference (Optional but Recommended)

```bash
curl -X POST http://localhost:3000/api/notifications/preferences \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>" \
  -H "x-tenant-id: <YOUR_TENANT_ID>" \
  -H "Content-Type: application/json" \
  -d '{
    "notificationType": "low_stock",
    "isEnabled": true,
    "threshold": {
      "minStockLevel": 20
    }
  }'
```

### Step D: Adjust Stock to Trigger Alert

```bash
# Reduce stock to below the threshold (e.g., below 20)
curl -X PATCH http://localhost:3000/api/inventory/stock/adjust \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>" \
  -H "x-tenant-id: <YOUR_TENANT_ID>" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": "<PRODUCT_ID>",
    "locationId": "<LOCATION_ID>",
    "quantity": -100,
    "reason": "Testing low stock alert"
  }'
```

### What Should Happen

1. Stock adjustment succeeds
2. **Backend** `StockAlertService` evaluates if stock < preference threshold
3. If triggered, **notification** is created in database
4. **SSE stream** broadcasts the notification
5. **Frontend** shows notification toast
6. **Notification Center** lists the notification

---

## 6. Test 3: Verify Notification CRUD Operations

### List Notifications

```bash
curl -X GET http://localhost:3000/api/notifications?limit=10&offset=0 \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>" \
  -H "x-tenant-id: <YOUR_TENANT_ID>"
```

**Expected Response**:

```json
{
  "items": [
    {
      "id": "...",
      "type": "low_stock",
      "title": "...",
      "message": "...",
      "status": "new",
      "createdAt": "..."
    }
  ],
  "total": 1,
  "limit": 10,
  "offset": 0
}
```

### Mark Notification as Read

```bash
curl -X PATCH http://localhost:3000/api/notifications/<NOTIFICATION_ID> \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>" \
  -H "x-tenant-id: <YOUR_TENANT_ID>"
```

**Expected Response**: 204 No Content (success)

### Verify in Database

```bash
psql -U postgres -d nest_erp

-- View all notifications for your user
SELECT id, type, title, status, created_at
FROM notifications
WHERE user_id = '<YOUR_USER_ID>'
ORDER BY created_at DESC
LIMIT 10;

-- You should see your test notifications with status='new' or 'read'
```

---

## 7. Test 4: Check Frontend Query Cache

### In Browser Console (after opening notification center):

```javascript
// Check React Query cache
const { cache } = window.__REACT_QUERY_DEVTOOLS__;
// Or use React Query DevTools panel if installed
```

You should see:

- Query key: `['notifications']`
- Data contains the notifications array from the API response

---

## 8. Troubleshooting

### Problem: "x-tenant-id header is required"

- **Check**: Browser Network tab → `stream` request → Response headers
- **Fix**: Tenant middleware is not reading query param fallback
  - Verify `/backend/src/common/middleware/tenant.middleware.ts` has the fallback logic
  - Restart backend: `pnpm run start:dev`

### Problem: SSE Stream Not Connecting

- **Check**: Network tab → `stream` request → Status should be 200, type `eventsource`
- **Check**: Console for auth errors (token might be expired)
- **Fix**:
  ```bash
  # Clear browser cache/cookies
  # Re-login
  # Refresh page
  ```

### Problem: Notification Created But Not Appearing in UI

- **Check 1**: Is SSE connected? (Network tab shows `stream` with status 200)
- **Check 2**: Did the notification actually get created? (Check database)
  ```bash
  SELECT * FROM notifications ORDER BY created_at DESC LIMIT 1;
  ```
- **Check 3**: Is the notification for your user?
  ```bash
  SELECT * FROM notifications
  WHERE user_id = '<YOUR_USER_ID>'
  ORDER BY created_at DESC LIMIT 1;
  ```

### Problem: Stock Change Not Triggering Notification

- **Check 1**: Is StockAlertService injected in InventoryService?
  - Look at `/backend/src/modules/inventory/inventory.service.ts`
  - Should have `constructor(..., private stockAlertService: StockAlertService)`
- **Check 2**: Is event emitted after stock mutation?
  - Look for `this.stockAlertService.evaluateStockAlerts()`
- **Check 3**: Did you set a notification preference?
  - POST to `/api/notifications/preferences` with your threshold
- **Check 4**: Is stock actually below threshold?
  - Check database: `SELECT * FROM inventory_stock WHERE product_id = '<ID>'`

---

## 9. Complete End-to-End Flow (Recommended Test)

1. ✅ **Migration Ran** (already done)
2. ✅ **Backend Running** (already running)
3. **Frontend Running** (check terminal - should be on http://localhost:5173)
4. **Open DevTools** (F12 → Network tab)
5. **Login** to frontend
6. **Watch Network tab** for `stream` request (should appear and stay pending)
7. **Run POST to create notification** (Test 1 above)
8. **Watch Browser**:
   - Console should log: "Received notification: ..."
   - Toast should appear
   - Notification Center should update
9. **Check Database**:
   ```bash
   psql -U postgres -d nest_erp
   SELECT * FROM notifications ORDER BY created_at DESC LIMIT 1;
   ```
10. ✅ **All Steps Passed** = Notification system is working!

---

## 10. Quick Command Reference

```bash
# Terminal 1: Backend (if not running)
cd backend
pnpm run start:dev

# Terminal 2: Frontend (if not running)
cd frontend
pnpm run dev

# Test Database
psql -U postgres -d nest_erp
\dt notifications
SELECT * FROM notifications ORDER BY created_at DESC LIMIT 5;

# Test via cURL (get your token first from frontend localStorage)
# Browser console: localStorage.getItem('auth_token')
curl -X GET http://localhost:3000/api/notifications \
  -H "Authorization: Bearer <TOKEN>" \
  -H "x-tenant-id: <TENANT_ID>"
```

---

## Summary

The notification system has three integration points to verify:

1. **REST API Works** → POST/GET `/api/notifications` returns 200 with data
2. **SSE Stream Works** → Network tab shows long-lived connection, messages arrive
3. **UI Updates** → Notification appears in toast & notification center when event arrives

Run **Test 1 (Manual)** first for fastest validation. If that works, the whole system is connected properly.
