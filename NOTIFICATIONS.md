# Notification System Documentation

> **Canonical API reference:** [backend/docs/notifications-api.md](./backend/docs/notifications-api.md)  
> **Documentation hub:** [docs/README.md](./docs/README.md)

Welcome! This index covers the Nest ERP notification system.

## 📚 Documentation Files

### For End Users

**[User Guide: Notification Center & Preferences](./frontend/docs/notifications-user-admin-guide.md#for-users)**

Learn how to:

- Access and use the Notification Center
- Manage notification preferences and thresholds
- Mark notifications as read/archived
- Filter and organize alerts

**Reading Time:** ~10 minutes

---

### For Administrators

**[Admin Guide: Control Panel](./frontend/docs/notifications-user-admin-guide.md#for-admins)**

Master the admin Control Panel for:

- **Creating Message Templates** with variable substitution
- **Setting Up Trigger Rules** for automatic notifications
- **Sending Custom Notifications** to users/roles
- **Testing and Previewing** before deployment

**Reading Time:** ~20 minutes

---

### For Developers

**[API Reference & Developer Guide](./backend/docs/notifications-api.md)**

Complete technical documentation including:

- **Data Models** (Notification, Template, Rule, Preference entities)
- **API Endpoints** (user-facing and admin control panel)
- **Integration Guide** (adding new notification types)
- **SSE Implementation** (real-time streaming)
- **Code Examples** and testing patterns
- **Troubleshooting** and performance tips

**Reading Time:** ~25 minutes

---

## 🚀 Quick Start

### I'm a Regular User

1. See a notification? Click the bell icon (🔔) in the top navigation
2. Want to control what you receive? Click **Preferences** in the Notification Center
3. Adjust thresholds for low stock alerts and enable/disable as needed

### I'm an Admin

1. Navigate to **Settings → Notifications → Control Panel**
2. Start with **Message Templates** tab to create your first template
3. Move to **Trigger Rules** to set up automatic notifications
4. Use **Manual Send** to test and send one-off alerts

### I'm a Developer

1. Read the [API Reference](./backend/docs/notifications-api.md) for endpoint contracts
2. See [Adding a New Notification Type](./backend/docs/notifications-api.md#adding-a-new-notification-type) for integration patterns
3. Check [Troubleshooting](./backend/docs/notifications-api.md#troubleshooting) for common issues

---

## 🎯 Common Tasks

### As an Admin

**Create a Low Stock Alert Template**
→ See [Creating a New Template](./frontend/docs/notifications-user-admin-guide.md#creating-a-new-template)

**Automatically Notify Warehouse on Low Stock**
→ See [Creating a Trigger Rule](./frontend/docs/notifications-user-admin-guide.md#creating-a-trigger-rule)

**Send Emergency Notification to All Users**
→ See [Sending a Notification](./frontend/docs/notifications-user-admin-guide.md#sending-a-notification)

**Test Before Going Live**
→ See [Test Mode](./frontend/docs/notifications-user-admin-guide.md#test-mode)

### As a Developer

**Extend with Custom Notification Type**
→ See [Adding a New Notification Type](./backend/docs/notifications-api.md#adding-a-new-notification-type)

**Emit Events to Trigger Rules**
→ See [Emit Events When Triggering Condition Occurs](./backend/docs/notifications-api.md#emit-events-when-triggering-condition-occurs)

**Integrate Notifications into My Module**
→ See [Integrating Notifications into Other Modules](./backend/docs/notifications-api.md#integrating-notifications-into-other-modules)

**Debug Why Rules Aren't Triggering**
→ See [Troubleshooting](./backend/docs/notifications-api.md#troubleshooting)

### Accounts receivable (due soon / overdue)

Invoice payment schedule alerts use trigger type `AGING_RECEIVABLE` and events `invoice.due_soon` / `invoice.overdue`.

**Prerequisites:**

1. Run notification control-plane migration (`1768300000000-add-notification-control-plane`) so enum values exist
2. In **Settings → Notifications → Control Panel**, enable trigger rules for `AGING_RECEIVABLE`
3. Keep the API process running — daily scan uses `@nestjs/schedule` in the main app (`ScheduleModule`)

Alerts evaluate **posted** invoices (`SENT` / `PARTIALLY_PAID`) per **payment schedule line** due date. Invoices posted before schedule lines existed will not generate alerts until new posts include lines. See [Sales workflow — Phase 4](./backend/docs/workflow-sales-flow.md#4-due--overdue-notifications-optional).

---

## 🔐 Permissions

| Feature                         | Permission             | Who Has It?    |
| ------------------------------- | ---------------------- | -------------- |
| View & manage own notifications | `read:notification`    | All users      |
| Create/edit templates & rules   | `manage:notification`  | Admin, Manager |
| Send custom notifications       | `send:notification`    | Admin          |

See [Permissions Matrix](./backend/docs/notifications-api.md#permissions-matrix) for full details.

---

## 💡 Key Concepts

### Template

A reusable message format with dynamic {{variables}}.

**Example:**

```
Title: ⚠️ Low Stock: {{productName}}
Body: {{productName}} has {{currentStock}} units (threshold: {{threshold}})
```

### Trigger Rule

Automatically sends notifications when a business event occurs + optional conditions are met.

**Example:** When stock.updated event occurs AND currentStock < 10, send the above template to warehouse managers.

### Cooldown

Minimum time between consecutive notifications from the same rule (prevents spam).

### Recipient Scope

Who receives the notification: specific user, users in a role, or all users.

---

## 🔄 System Architecture

```
User Action / Event
      ↓
Trigger Rule Evaluator
      ↓
Template Renderer (variable substitution)
      ↓
Notification Creation
      ↓
SSE Broadcast + Database Storage
      ↓
Real-time Notification Center + User Preferences
```

---

## 📖 Documentation Structure

```
/backend/docs/
  └── notifications-api.md       # API reference, developer guide

/frontend/docs/
  └── notifications-user-admin-guide.md  # User & admin guide

/docs/
  └── NOTIFICATIONS.md (this file)  # Overview & quick start
```

---

## ❓ FAQ - Quick Answers

**Q: How do I know if my rule is working?**
A: Use the Manual Send tab to test, or check the "Last Triggered" timestamp on the rule.

**Q: Can users opt out of notifications?**
A: Yes, in their Notification Preferences. They can disable specific types.

**Q: What's the difference between Template and Rule?**
A: Template = message format. Rule = when to send it and to whom.

**Q: Can I send notifications at a specific time?**
A: Not in the current system. Notifications send immediately when triggered.

**Q: Where are old notifications stored?**
A: In the database, accessible via notification history. Users can clear them.

For more, see [FAQ](./frontend/docs/notifications-user-admin-guide.md#faq).

---

## 🐛 Troubleshooting

See the relevant guide:

- **User Issues** → [User Guide FAQ](./frontend/docs/notifications-user-admin-guide.md#faq)
- **Admin Issues** → [Admin Troubleshooting](./frontend/docs/notifications-user-admin-guide.md#troubleshooting)
- **Developer Issues** → [API Troubleshooting](./backend/docs/notifications-api.md#troubleshooting)

---

## 📝 Version & Release Notes

**Current Version:** 1.0.0 (Released: May 10, 2026)

**Features:**

- ✅ Real-time SSE notification streaming
- ✅ Low-stock alerts with configurable thresholds
- ✅ User notification preferences
- ✅ Admin message templates
- ✅ Trigger rule engine
- ✅ Manual custom notifications
- ✅ Role-based recipient targeting

**Planned Future Features:**

- Scheduled notifications (specific times)
- Advanced conditions and filtering
- Notification channels (SMS, email)
- Digest scheduling customization
- Notification analytics dashboard

---

## 📞 Support

- **Getting Started:** Start with this page, then read the relevant guide
- **Specific Question:** Use Ctrl+F to search within guides
- **Technical Issue:** Contact your development team with error logs
- **Feature Request:** File a ticket with your use case

---

## 🔗 Related Documentation

- [Architecture Overview](./backend/docs/architecture.md)
- [Database Schema](./backend/docs/db-setup.md)
- [Testing Guide](./backend/docs/testing.md)
- [Development Setup](./backend/docs/development.md)

---

Happy notifying! 🔔
