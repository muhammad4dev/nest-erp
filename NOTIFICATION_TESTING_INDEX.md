# Notification Testing Resources - Master Index

## 🎯 Where to Start

### If You Have 2 Minutes ⚡

→ Read: `NOTIFICATION_TEST_CHEATSHEET.md`
→ Run: `./test-notifications.sh <token> <tenant-id>`

### If You Have 5 Minutes 📋

→ Read: `NOTIFICATION_TESTING_QUICK_START.md`
→ Follow the step-by-step guide

### If You Have 15 Minutes 🔬

→ Read: `NOTIFICATION_TESTING_GUIDE.md`
→ Run all test scenarios

### If You Need Full Reference 📚

→ Read: `START_HERE_NOTIFICATION_TESTING.md`
→ Read: `NOTIFICATION_TESTING_README.md`

---

## 📂 All Testing Files

### Quick Reference (START HERE)

- **`START_HERE_NOTIFICATION_TESTING.md`** — Overview + checklist (2 min read)
- **`NOTIFICATION_TEST_CHEATSHEET.md`** — Copy & paste commands (super fast)

### Testing Guides

- **`NOTIFICATION_TESTING_QUICK_START.md`** — Quick reference with troubleshooting
- **`NOTIFICATION_TESTING_GUIDE.md`** — 10 detailed test scenarios
- **`NOTIFICATION_TESTING_README.md`** — Complete system reference

### Executable Scripts

- **`test-notifications.sh`** — Main test script
  ```bash
  ./test-notifications.sh <YOUR_JWT_TOKEN> <YOUR_TENANT_ID>
  ```
- **`test-notifications-auto.sh`** — Helper for guided setup
  ```bash
  ./test-notifications-auto.sh
  ```

---

## 🚀 Quick Start (Copy & Paste)

```bash
# Step 1: Get your token (in browser console F12)
localStorage.getItem('token')

# Step 2: Get your tenant ID (in browser console F12)
localStorage.getItem('tenantId')

# Step 3: Run test
cd /home/m/Projects/nest-erp
./test-notifications.sh "YOUR_TOKEN_HERE" "YOUR_TENANT_ID_HERE"

# Step 4: Watch browser for toast notification + check DevTools for stream
```

---

## 📊 What Each File Does

| File                                  | Purpose              | Time        | Link             |
| ------------------------------------- | -------------------- | ----------- | ---------------- |
| `START_HERE_NOTIFICATION_TESTING.md`  | Overview + checklist | 2 min       | Start here       |
| `NOTIFICATION_TEST_CHEATSHEET.md`     | Quick reference      | 2 min       | Copy & paste     |
| `NOTIFICATION_TESTING_QUICK_START.md` | Step-by-step guide   | 5 min       | Easy walkthrough |
| `NOTIFICATION_TESTING_GUIDE.md`       | 10 test scenarios    | 15 min      | Comprehensive    |
| `NOTIFICATION_TESTING_README.md`      | Full system docs     | Reference   | For deep dives   |
| `test-notifications.sh`               | Executable test      | Runs in 30s | Main test        |
| `test-notifications-auto.sh`          | Setup helper         | Runs in 1m  | For guided setup |

---

## ✅ System Status

- ✅ Backend running on http://localhost:3000
- ✅ Frontend running on http://localhost:5173
- ✅ Database migration executed
- ✅ 12 backend files created
- ✅ 3 frontend files updated
- ✅ TypeScript: 0 errors (backend)
- ✅ TypeScript: 0 errors (frontend)
- ✅ Ready to test now

---

## 🎯 Testing Checklist

After running tests, verify:

- [ ] `./test-notifications.sh` completes without errors
- [ ] Toast notification appears in browser
- [ ] DevTools shows `stream` request with status 200
- [ ] Database contains notification: `SELECT COUNT(*) FROM notifications;`

---

## 🔍 Troubleshooting

| Issue              | Check                                                                 |
| ------------------ | --------------------------------------------------------------------- |
| Script fails       | Read: `NOTIFICATION_TESTING_QUICK_START.md` → Troubleshooting section |
| No toast           | Check: Browser console (F12) for JavaScript errors                    |
| SSE not connecting | Check: DevTools Network tab → Look for "stream" request               |
| Backend error      | Check: Restart backend: `cd backend && pnpm run start:dev`            |
| Database issues    | Check: `psql -U postgres -d nest_erp -c "SELECT 1;"`                  |

---

## 📁 Backend Implementation Files (Created)

```
/backend/src/modules/notifications/
├── entities/
│   ├── notification.entity.ts
│   └── notification-preference.entity.ts
├── dto/
│   ├── notification.dto.ts
│   ├── notification-preference.dto.ts
│   └── paginated-response.dto.ts
├── repositories/
│   ├── notification.repository.ts
│   └── notification-preference.repository.ts
├── services/
│   ├── notification-events.service.ts
│   ├── notification.service.ts
│   └── stock-alert.service.ts
├── controllers/
│   └── notification.controller.ts
└── notifications.module.ts
```

---

## 🌐 API Endpoints

```
POST   /api/notifications                    Create notification
GET    /api/notifications                    List notifications
PATCH  /api/notifications/:id                Mark as read
GET    /api/notifications/preferences        Get preferences
POST   /api/notifications/preferences        Set preferences
GET    /api/notifications/stream             SSE real-time stream
```

---

## 🎓 How to Test (Different Ways)

### Way 1: Automated Script (Easiest)

```bash
./test-notifications.sh <token> <tenant-id>
```

✅ Fastest, covers all endpoints

### Way 2: Manual cURL

```bash
curl -X POST http://localhost:3000/api/notifications \
  -H "Authorization: Bearer <token>" \
  -H "x-tenant-id: <tenant-id>" \
  -H "Content-Type: application/json" \
  -d '{"type":"low_stock","title":"Test","message":"Test","alertData":{}}'
```

✅ Manual, shows exactly what's sent

### Way 3: Browser SSE Monitor

1. Open DevTools → Network tab
2. Create notification via API
3. Watch SSE stream for event broadcast
   ✅ Visual verification of real-time

### Way 4: Database Query

```bash
psql -U postgres -d nest_erp
SELECT * FROM notifications ORDER BY created_at DESC LIMIT 5;
```

✅ Verify persistence

---

## 🚀 Next Steps

1. **Pick a starting point above** ↑
2. **Read the guide** (2-5 minutes)
3. **Run the test** (30 seconds)
4. **Verify results** (1 minute)
5. **You're done!** ✅

---

## 📞 Help Resources

- **Quick help** → `NOTIFICATION_TEST_CHEATSHEET.md`
- **Troubleshooting** → `NOTIFICATION_TESTING_QUICK_START.md` (Troubleshooting section)
- **Deep dive** → `NOTIFICATION_TESTING_GUIDE.md`
- **Full reference** → `NOTIFICATION_TESTING_README.md`

---

## ✨ Success Looks Like This

```
✅ Test script output shows "✅ Test notification created (HTTP 201)"
✅ Browser shows toast notification "🧪 Test Alert"
✅ DevTools Network tab shows "stream" request with Status 200
✅ Notification Center badge increments
✅ Database query returns notification record

RESULT: Notification system is fully functional! 🎉
```

---

## 🎯 Key Takeaways

1. **Everything is implemented** — 12 backend + 3 frontend files
2. **Servers are running** — Ready to test immediately
3. **Database is ready** — Migration already executed
4. **Testing is easy** — Run one script, watch browser
5. **You're ready** — Start with the quick guides above

---

## 📝 Quick Command Reference

```bash
# Get token
localStorage.getItem('token')  # In browser F12 console

# Get tenant ID
localStorage.getItem('tenantId')  # In browser F12 console

# Run test
./test-notifications.sh <token> <tenant-id>

# Check database
psql -U postgres -d nest_erp -c "SELECT COUNT(*) FROM notifications;"

# Restart backend
cd backend && pnpm run start:dev

# Restart frontend
cd frontend && pnpm run dev

# View logs
tail -f /path/to/backend/logs
```

---

**Ready to test? Start with `NOTIFICATION_TEST_CHEATSHEET.md` → It's the fastest!** ⚡
