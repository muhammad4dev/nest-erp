# How to Test Notifications - Quick Start

Your notification system is **fully implemented and running**. Here's how to test it:

## 🚀 Fastest Test (2 minutes)

### Step 1: Get Your Auth Token

```javascript
// In browser console (F12):
localStorage.getItem("token");
// Copy the entire token value (it's a long JWT string)
```

### Step 2: Get Your Tenant ID

```javascript
// In browser console (F12):
localStorage.getItem("tenantId");
// Or check any API request in Network tab for x-tenant-id header
```

### Step 3: Run the Test Script

```bash
cd /home/m/Projects/nest-erp
./test-notifications.sh <YOUR_TOKEN> <YOUR_TENANT_ID>
```

Example:

```bash
./test-notifications.sh "eyJhbGciOiJIUzI1NiIs..." "tenant-123"
```

### Step 4: Watch Your Browser

- **Toast notification** should appear in bottom-right corner
- **Notification Center** badge should increment
- **DevTools Network tab** should show an active `stream` request with status 200

✅ **If you see all three → System is working!**

---

## 📊 What Was Implemented

### Backend (12 Files)

- ✅ `NotificationEntity` — Stores notifications in database
- ✅ `NotificationPreferenceEntity` — User-specific alert thresholds
- ✅ `NotificationRepository` — Database queries (tenant-aware)
- ✅ `NotificationPreferenceRepository` — Preference CRUD
- ✅ `NotificationService` — Business logic (create, list, mark read)
- ✅ `StockAlertService` — Evaluates low-stock conditions
- ✅ `NotificationEventsService` — RxJS stream for real-time SSE
- ✅ `NotificationController` — REST API + SSE endpoint
- ✅ `NotificationsModule` — NestJS wiring

### Frontend (3 Updates)

- ✅ `useNotifications()` — Query to fetch notifications
- ✅ `useMarkNotificationAsRead()` — Mark notification as read
- ✅ `NotificationManager` — SSE connection + real-time updates

### Database

- ✅ Migration `1768100000000-add-notifications.ts` — Already ran successfully

### Integration

- ✅ `InventoryService` — Emits stock-change events
- ✅ `TenantMiddleware` — Supports SSE query-param auth
- ✅ `AppModule` — Imports notifications module

---

## 🧪 What Each Test Checks

| Test                | Command                                | Expected Result                   |
| ------------------- | -------------------------------------- | --------------------------------- |
| API Connectivity    | `GET /api/notifications`               | HTTP 200 with notifications array |
| Create Notification | `POST /api/notifications`              | HTTP 201 with notification object |
| List Notifications  | `GET /api/notifications?limit=10`      | HTTP 200 with paginated list      |
| Mark as Read        | `PATCH /api/notifications/:id`         | HTTP 204 No Content               |
| SSE Stream          | Connect to `/api/notifications/stream` | HTTP 200 long-lived connection    |

---

## 🔍 Manual Verification (If Script Doesn't Work)

### Check 1: Is Backend Running?

```bash
# Backend should be on port 3000
curl http://localhost:3000/api/notifications \
  -H "Authorization: Bearer <your-token>" \
  -H "x-tenant-id: <your-tenant-id>"
```

Should get HTTP 200 response.

### Check 2: Is Frontend Running?

```bash
# Frontend should be on port 5173
curl http://localhost:5173
```

Should return HTML (no 404).

### Check 3: Is SSE Streaming?

1. Open DevTools (F12)
2. Go to **Network** tab
3. Look for `stream` request
4. **Status** should be **200**
5. **Type** should be **eventsource**
6. Should show **pending** (never complete)

### Check 4: Is Database Connected?

```bash
psql -U postgres -d nest_erp
SELECT COUNT(*) FROM notifications;
```

Should return a number (even if 0).

---

## 📝 Detailed Testing Guide

See `NOTIFICATION_TESTING_GUIDE.md` for:

- 10 comprehensive test scenarios
- How to trigger notifications via stock changes
- Troubleshooting steps
- Database verification queries
- Complete CRUD operation tests

---

## ❓ Common Issues & Fixes

### Issue: "x-tenant-id header is required"

**Cause**: Tenant middleware not reading query params  
**Fix**:

1. Check backend logs for errors
2. Restart backend: `cd backend && pnpm run start:dev`
3. Verify `tenant.middleware.ts` has fallback logic

### Issue: SSE Stream Not Connecting

**Cause**: Token expired or auth header missing  
**Fix**:

1. Get fresh token: `localStorage.getItem('token')` in browser
2. Reload frontend
3. Check browser console for auth errors

### Issue: Notification Created But Not Showing in UI

**Cause**: SSE not connected or frontend not listening  
**Fix**:

1. Open DevTools Network tab
2. Verify `stream` request is there and pending
3. Check console for "SSE stream connected" message
4. If missing, restart frontend dev server

### Issue: Stock Change Not Creating Notification

**Cause**: Preference not set or threshold not matched  
**Fix**:

1. Create preference first:
   ```bash
   curl -X POST http://localhost:3000/api/notifications/preferences \
     -H "Authorization: Bearer <token>" \
     -H "x-tenant-id: <tenant-id>" \
     -H "Content-Type: application/json" \
     -d '{"notificationType":"low_stock","isEnabled":true,"threshold":{"minStockLevel":20}}'
   ```
2. Then reduce stock to below 20
3. Check database: `SELECT * FROM notifications ORDER BY created_at DESC LIMIT 1;`

---

## 🎯 Success Criteria

System is working when:

1. ✅ Test script runs without errors
2. ✅ Toast notification appears in browser
3. ✅ Notification Center badge increments
4. ✅ SSE stream shows as pending in DevTools
5. ✅ Notification persists in database
6. ✅ Marking as read updates database and UI

---

## 📞 Next Steps

**If basic test works:**

- Try creating a low-stock scenario (adjust inventory stock)
- Verify notifications appear in real-time

**If you want to add more notification types:**

- Create more stock-alert rules in `StockAlertService`
- Add aging-receivables or sales-order-status notifications

**If you need persistent storage:**

- All notifications are already persisted in PostgreSQL
- Query: `SELECT * FROM notifications WHERE tenant_id = '<id>'`
