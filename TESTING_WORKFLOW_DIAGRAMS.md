# Testing Workflow Diagram

## What Gets Tested

```
┌─────────────────────────────────────────────────────────────────┐
│                    NOTIFICATION TEST FLOW                       │
└─────────────────────────────────────────────────────────────────┘

You (Terminal)
    │
    ├─→ Run: ./test-notifications.sh <token> <tenant-id>
    │
    ↓
Test Script (test-notifications.sh)
    │
    ├─→ Test 1: Check API Connectivity
    │       └─→ GET http://localhost:3000/api/notifications
    │           Expected: HTTP 200 ✅
    │
    ├─→ Test 2: Check Preferences Endpoint
    │       └─→ GET http://localhost:3000/api/notifications/preferences
    │           Expected: HTTP 200 ✅
    │
    ├─→ Test 3: Create Test Notification
    │       └─→ POST http://localhost:3000/api/notifications
    │           Expected: HTTP 201 with notification object ✅
    │
    └─→ Test 4: List Notifications
            └─→ GET http://localhost:3000/api/notifications?limit=10
                Expected: HTTP 200 with paginated list ✅
    │
    ↓
Backend (NestJS on :3000)
    │
    ├─→ NotificationController receives POST request
    │
    ├─→ NotificationService creates notification
    │
    ├─→ Saves to database (PostgreSQL)
    │
    ├─→ Emits event to NotificationEventsService
    │
    └─→ Event streams via SSE endpoint /notifications/stream
    │
    ↓
Frontend (React/Vite on :5173)
    │
    ├─→ NotificationManager receives SSE event
    │
    ├─→ Shows toast notification
    │
    ├─→ Updates Notification Center
    │
    └─→ Updates Zustand store
    │
    ↓
You (Browser)
    │
    └─→ See toast notification ✅
        See SSE stream connected ✅
        See notification in center ✅

```

---

## Quick Test Path

```
START
  │
  ├─→ Get token from browser: localStorage.getItem('token')
  │
  ├─→ Get tenant ID from browser: localStorage.getItem('tenantId')
  │
  ├─→ Run: ./test-notifications.sh <token> <tenant-id>
  │
  ├─→ Watch for:
  │   ├─→ Script output: ✅ Tests pass
  │   ├─→ Browser: Toast notification appears
  │   └─→ DevTools: SSE stream shows (Network → stream request)
  │
  └─→ SUCCESS! System is working! ✅
```

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                      YOUR APPLICATION                         │
└──────────────────────────────────────────────────────────────┘

┌─────────────────────┐
│   FRONTEND          │
│  (React/Vite)       │
│  :5173              │
├─────────────────────┤
│ NotificationManager │
│  - SSE connection   │
│  - Toast display    │
│  - Zustand store    │
│  - useNotifications │
└─────────────────────┘
         │
         │ (1) REST GET /api/notifications
         │ (2) SSE GET /api/notifications/stream
         ↓
┌─────────────────────────────────────────┐
│   BACKEND                               │
│   (NestJS)                              │
│   :3000                                 │
├─────────────────────────────────────────┤
│ NotificationController                  │
│  - POST /notifications                  │
│  - GET /notifications                   │
│  - PATCH /notifications/:id             │
│  - GET /notifications/stream (SSE)      │
├─────────────────────────────────────────┤
│ NotificationService                     │
│  - Create notification                  │
│  - List notifications                   │
│  - Mark as read                         │
├─────────────────────────────────────────┤
│ NotificationEventsService               │
│  - RxJS Subject for SSE events          │
│  - Broadcasts to connected clients      │
├─────────────────────────────────────────┤
│ StockAlertService                       │
│  - Evaluates low-stock conditions       │
│  - Creates notifications on trigger     │
└─────────────────────────────────────────┘
         │
         │ SQL queries
         ↓
┌─────────────────────────────────────────┐
│   DATABASE                              │
│   (PostgreSQL)                          │
├─────────────────────────────────────────┤
│ notifications table                     │
│ notification_preferences table          │
└─────────────────────────────────────────┘
```

---

## Testing Success Checklist

```
┌─────────────────────────────────────────┐
│     SUCCESS CRITERIA (All Must ✅)      │
├─────────────────────────────────────────┤
│                                         │
│ ✅ Test script runs without errors      │
│    Output shows:                        │
│    - ✅ API is accessible               │
│    - ✅ Preferences endpoint works      │
│    - ✅ Test notification created      │
│    - ✅ Notifications fetched           │
│                                         │
│ ✅ Toast notification appears in        │
│    browser (bottom-right corner)        │
│                                         │
│ ✅ DevTools shows:                      │
│    - Network tab → "stream" request     │
│    - Status: 200                        │
│    - Type: eventsource                  │
│    - Shows: pending (never complete)    │
│                                         │
│ ✅ Notification Center:                 │
│    - Badge increments OR                │
│    - Notification shows when opened     │
│                                         │
│ ✅ Database contains notification:      │
│    SELECT COUNT(*) FROM notifications;  │
│    → Returns: 1 (or higher)             │
│                                         │
│         RESULT: ALL ✅ = WORKING! 🎉   │
│                                         │
└─────────────────────────────────────────┘
```

---

## File Organization

```
/home/m/Projects/nest-erp/
│
├── 📄 START_HERE_NOTIFICATION_TESTING.md      ← Read first
├── 📄 NOTIFICATION_TESTING_INDEX.md           ← All resources
├── 📄 NOTIFICATION_TEST_CHEATSHEET.md         ← Copy/paste commands
├── 📄 NOTIFICATION_TESTING_QUICK_START.md     ← 5-min guide
├── 📄 NOTIFICATION_TESTING_GUIDE.md           ← Detailed tests
├── 📄 NOTIFICATION_TESTING_README.md          ← Full reference
├── 📄 TESTING_SETUP_VERIFICATION.txt         ← Verification status
│
├── 🔧 test-notifications.sh                   ← Main test script
├── 🔧 test-notifications-auto.sh              ← Auto setup
│
└── backend/
    └── src/modules/notifications/            ← 12 implementation files
        ├── entities/
        ├── dto/
        ├── repositories/
        ├── services/
        ├── controllers/
        └── notifications.module.ts
```

---

## Quick Command Reference

```bash
# Get Auth Credentials
────────────────────
localStorage.getItem('token')     # Browser F12 console
localStorage.getItem('tenantId')  # Browser F12 console


# Run Tests
──────────
./test-notifications.sh <token> <tenant-id>      # Main test
./test-notifications-auto.sh                     # Auto setup


# Verify Database
─────────────────
psql -U postgres -d nest_erp
SELECT COUNT(*) FROM notifications;              # Count notifications
SELECT * FROM notifications LIMIT 5;             # View recent


# Monitor Servers
──────────────
curl http://localhost:3000/health                # Backend health
curl http://localhost:5173                       # Frontend check


# Troubleshoot
──────────────
cd backend && pnpm run start:dev                 # Restart backend
cd frontend && pnpm run dev                      # Restart frontend
```

---

## Decision Tree: Which Guide to Read?

```
START: "How do I test notifications?"
│
├─→ "I have 2 minutes"
│   └─→ Read: NOTIFICATION_TEST_CHEATSHEET.md
│       Run: ./test-notifications.sh <token> <tenant-id>
│
├─→ "I have 5 minutes"
│   └─→ Read: NOTIFICATION_TESTING_QUICK_START.md
│       Follow step-by-step
│
├─→ "I have 15 minutes"
│   └─→ Read: NOTIFICATION_TESTING_GUIDE.md
│       Run all 10 scenarios
│
├─→ "I need everything"
│   └─→ Read: NOTIFICATION_TESTING_README.md
│       Then explore other guides
│
└─→ "I need a summary"
    └─→ Read: START_HERE_NOTIFICATION_TESTING.md
        Then pick your path above
```

---

## Real-Time Data Flow

```
Timeline of What Happens When You Create a Notification:

T=0ms   You run: ./test-notifications.sh <token> <tenant-id>
│
T=10ms  Script sends: POST /api/notifications
│
T=20ms  Backend receives request
│       ├─→ Validates auth (JWT token)
│       ├─→ Resolves tenant context
│       └─→ Routes to NotificationController
│
T=30ms  NotificationController.create()
│       ├─→ Validates input DTO
│       ├─→ Calls NotificationService.createNotification()
│       └─→ Service saves to database
│
T=40ms  Database INSERT succeeds
│
T=45ms  NotificationEventsService.emit()
│       └─→ Broadcasts to all SSE clients
│
T=50ms  Frontend SSE stream receives event
│       ├─→ NotificationManager.onMessage()
│       ├─→ Shows toast notification
│       └─→ Updates Zustand store
│
T=100ms  You see toast in browser ✅
│
T=200ms  Database query confirms persistence ✅
│
SUCCESS: Full round-trip completed!
```

---

## System State Summary

```
┌──────────────────────────────────┐
│      CURRENT SYSTEM STATE        │
├──────────────────────────────────┤
│                                  │
│ Backend:      🟢 Running         │
│ Frontend:     🟢 Running         │
│ Database:     🟢 Connected       │
│ TypeScript:   🟢 0 Errors        │
│ Migration:    🟢 Executed        │
│ Ready:        🟢 YES             │
│                                  │
│ → You can start testing now! ✅  │
│                                  │
└──────────────────────────────────┘
```

---

**Next Step: Pick a guide from the "Decision Tree" above and start testing!** 🚀
