# Notification Testing - Visual Quick Reference

## 🎯 The Fastest Test (Copy & Paste)

### Step 1: Get Your Token

```javascript
// Open browser → F12 → Console → Paste this:
localStorage.getItem("token");
// Right-click result and select Copy value
// You now have: eyJhbGciOiJIUzI1NiIs...
```

### Step 2: Get Your Tenant ID

```javascript
// In same console, paste this:
localStorage.getItem("tenantId");
// Copy the value
// You now have: tenant-abc-123
```

### Step 3: Run Test

```bash
cd /home/m/Projects/nest-erp
./test-notifications.sh "eyJhbGciOiJIUzI1NiIs..." "tenant-abc-123"
```

### Step 4: Watch Browser (Keep it Open)

While the script runs:

- 👀 Look bottom-right corner → **Should see toast notification**
- 👀 Look at Notification Center icon → **Should see badge increment**
- 👀 Open DevTools (F12) → Network tab → Search for "stream"
  - **Should see request with Status: 200 and Type: eventsource**

---

## 🧪 Alternative: Manual Curl Test

If script doesn't work, try this manually:

```bash
# Set these variables
TOKEN="your-token-here"
TENANT_ID="your-tenant-id-here"

# Test 1: Create notification
curl -X POST http://localhost:3000/api/notifications \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-tenant-id: $TENANT_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "type":"low_stock",
    "title":"🧪 Test Alert",
    "message":"This is a test notification",
    "alertData":{"productId":"test"}
  }'

# Should return HTTP 201 with notification object
```

Then immediately look at browser → should see toast

---

## 📊 Expected Results

### ✅ All Working

```
Test Script Output:
✅ API is accessible (HTTP 200)
✅ Preferences endpoint works (HTTP 200)
✅ Test notification created (HTTP 201)
✅ Notifications fetched successfully

Browser:
✅ Toast appears with title "🧪 Test Alert"
✅ Notification Center badge shows (if visible)

DevTools:
✅ Network tab shows "stream" request
✅ Status: 200
✅ Type: eventsource
✅ Shows: pending (long-lived)
```

### ❌ Might See Errors

```
If you see: "x-tenant-id header is required"
→ Restart backend: cd backend && pnpm run start:dev

If you see: "Token expired"
→ Reload frontend page, re-login

If you see: "404 not found"
→ Check backend is running: curl http://localhost:3000/health

If no toast appears in browser:
→ Check DevTools console for errors
→ Verify SSE stream is connected (see "stream" in Network tab)
```

---

## 🔄 Full Validation Workflow

```
Start here
    ↓
Get token + tenant-id
    ↓
Run: ./test-notifications.sh <token> <tenant-id>
    ↓
Script shows ✅ API accessible?
    ├─ YES → Continue
    └─ NO → Check TOKEN and TENANT_ID
    ↓
Script shows ✅ Notification created?
    ├─ YES → Continue
    └─ NO → Check backend logs: cd backend && tail -f npm-debug.log
    ↓
Check browser for toast?
    ├─ YES → SSE is working! ✅
    └─ NO → Check DevTools console for errors
    ↓
Check DevTools Network → stream request?
    ├─ YES → Status 200? → Everything working! ✅
    └─ NO → Restart frontend: cd frontend && pnpm run dev
    ↓
Check database:
    psql -U postgres -d nest_erp
    SELECT * FROM notifications ORDER BY created_at DESC LIMIT 1;
    ├─ YES → Notification in DB! ✅ Full system works!
    └─ NO → Check backend logs
```

---

## 📁 Files You'll Use

| File                                  | Purpose            | When                            |
| ------------------------------------- | ------------------ | ------------------------------- |
| `test-notifications.sh`               | Main test script   | When you have token + tenant-id |
| `test-notifications-auto.sh`          | Setup helper       | If you want guided setup        |
| `NOTIFICATION_TESTING_README.md`      | Full documentation | For reference/troubleshooting   |
| `NOTIFICATION_TESTING_QUICK_START.md` | Quick reference    | For fast lookup                 |
| `NOTIFICATION_TESTING_GUIDE.md`       | Detailed scenarios | For advanced testing            |

---

## ⚡ Super Quick Reference

```bash
# Everything you need in one place:

# Step 1: Terminal
cd /home/m/Projects/nest-erp

# Step 2: Browser Console (Ctrl+Shift+J or F12)
localStorage.getItem('token')    # Copy result
localStorage.getItem('tenantId') # Copy result

# Step 3: Terminal
./test-notifications.sh "PASTE_TOKEN_HERE" "PASTE_TENANT_ID_HERE"

# Step 4: Watch browser for:
# - Toast notification
# - Notification Center update
# - DevTools stream request (status 200)

# Step 5: Verify database
psql -U postgres -d nest_erp
SELECT COUNT(*) FROM notifications;
```

---

## 🎓 Understanding the Flow

```
You (Browser)
    ↓
(1) Create notification (via test script)
    ↓
Backend (http://localhost:3000)
    ↓
(2) Notification saved to database
(3) Event broadcasted to SSE stream
    ↓
Frontend (http://localhost:5173)
    ↓
(4) SSE stream receives event
(5) Toast notification appears
(6) Notification Center updates
    ↓
You see result in browser! ✅
```

---

## 🔗 Important URLs

| Component           | URL                                              | Expected Response                  |
| ------------------- | ------------------------------------------------ | ---------------------------------- |
| Frontend            | http://localhost:5173                            | React app loads                    |
| Backend             | http://localhost:3000/health                     | `{"status":"ok"}`                  |
| Get Notifications   | `http://localhost:3000/api/notifications`        | JSON array of notifications        |
| SSE Stream          | `http://localhost:3000/api/notifications/stream` | 200 OK, eventsource, stays pending |
| Create Notification | `http://localhost:3000/api/notifications`        | POST → 201 Created                 |

---

## 💬 Troubleshooting One-Liners

```bash
# Check backend running
curl -s http://localhost:3000/health | jq .

# Check frontend running
curl -s http://localhost:5173 | head -20

# Check database connected
psql -U postgres -d nest_erp -c "SELECT 1"

# Check notification tables exist
psql -U postgres -d nest_erp -c "\dt notifications"

# See recent notifications
psql -U postgres -d nest_erp -c "SELECT id, type, title, created_at FROM notifications ORDER BY created_at DESC LIMIT 5;"

# Restart backend
cd /home/m/Projects/nest-erp/backend && pnpm run start:dev

# Restart frontend
cd /home/m/Projects/nest-erp/frontend && pnpm run dev
```

---

## ✨ Success = You See This

1. ✅ Test script completes without errors
2. ✅ Toast notification appears in browser corner (duration ~5 sec)
3. ✅ Notification Center shows the alert
4. ✅ DevTools Network tab shows `stream` with status 200
5. ✅ Database contains the notification record

**If you see all 5 → Notification system is fully working!**

---

## 📞 Quick Help

- **Can't find token?** → Browser F12 → Console → `localStorage.getItem('token')`
- **Script won't run?** → Check: `chmod +x test-notifications.sh`
- **Backend not responding?** → Terminal: `cd backend && pnpm run start:dev`
- **Frontend not loading?** → Terminal: `cd frontend && pnpm run dev`
- **Need to see all options?** → Read: `NOTIFICATION_TESTING_QUICK_START.md`

---

That's it! You're ready. Go test. 🚀
