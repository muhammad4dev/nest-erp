# How to Test Notifications - Simple Answer

Your question was: **"how I can test notifications working or not?"**

Here's your answer:

## ✅ Quick Test (2 minutes)

### 1. Get Your Credentials
Open your browser → Press **F12** → Go to **Console** tab and run:
```javascript
localStorage.getItem('token')      // Copy this value
localStorage.getItem('tenantId')   // Copy this value
```

### 2. Run the Test
```bash
cd /home/m/Projects/nest-erp
./test-notifications.sh "PASTE_YOUR_TOKEN" "PASTE_YOUR_TENANT_ID"
```

### 3. Watch for Results
- **Toast notification** appears in browser (bottom-right)
- **SSE stream** connects (DevTools Network tab shows "stream" request with status 200)
- **Database** gets the notification (proves it persists)

**If you see all three → Notifications are working! ✅**

---

## 📖 Need More Details?

### For Fastest Path
Read: `NOTIFICATION_TEST_CHEATSHEET.md`

### For Step-by-Step
Read: `NOTIFICATION_TESTING_QUICK_START.md`

### For All Options
Read: `NOTIFICATION_TESTING_GUIDE.md`

---

## 🔍 Manual Test (If Script Doesn't Work)

```bash
curl -X POST http://localhost:3000/api/notifications \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "x-tenant-id: YOUR_TENANT_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "low_stock",
    "title": "Test Alert",
    "message": "Testing notifications",
    "alertData": {"productId": "test"}
  }'
```

If this returns HTTP 201 with a notification object → API works ✅

Then check your browser for a toast notification.

---

## That's It!

Your notification system is fully implemented and running. The test script verifies it end-to-end. Run it now and you'll know if everything is working.

All testing documentation is in `/home/m/Projects/nest-erp/` - pick whichever guide matches your time available (2 min, 5 min, or 15 min).
