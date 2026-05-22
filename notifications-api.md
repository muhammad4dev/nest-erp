# Notifications API Documentation

> **Note:** This file is kept at the repo root for backward compatibility. The canonical copy is **[backend/docs/notifications-api.md](./backend/docs/notifications-api.md)**. See [docs/README.md](./docs/README.md).

## Overview

The Nest ERP notification system provides real-time alerts, customizable templates, and trigger-based rule management. It uses Server-Sent Events (SSE) for real-time delivery and supports user preferences for notification types and thresholds.

**Key Features:**

- Real-time SSE streaming for instant notifications
- Low-stock alerts with configurable thresholds
- Admin-configurable message templates with variable substitution
- Trigger rules with event-based automation
- Manual custom notifications with recipient targeting
- User preferences for notification control
- Daily scheduled digest evaluation

---

## Architecture

### Data Models

#### Notification

Represents a single notification instance sent to a user.

```typescript
{
  id: string;
  tenantId: string;
  userId: string;
  type: 'low_stock' | 'overdue_payment' | 'custom'; // NotificationType enum
  title: string;
  message: string;
  alertData?: {
    productId?: string;
    currentStock?: number;
    threshold?: number;
    location?: string;
    [key: string]: any;
  };
  status: 'unread' | 'read' | 'archived';
  readAt?: Date;
  sourceEntityId?: string; // e.g., product ID for low_stock
  sourceEntityType?: string; // e.g., 'product'
  createdAt: Date;
  updatedAt: Date;
}
```

#### NotificationPreference

User-configured notification settings.

```typescript
{
  id: string;
  userId: string;
  notificationType: NotificationType;
  isEnabled: boolean;
  threshold?: {
    minStockLevel?: number;
    daysOverdue?: number;
    [key: string]: any;
  };
  createdAt: Date;
  updatedAt: Date;
}
```

#### NotificationTemplate

Customizable message template for notifications.

```typescript
{
  id: string;
  tenantId: string;
  name: string;
  notificationType: NotificationType; // low_stock, overdue_payment, etc.
  titleTemplate: string; // e.g., "Low Stock Alert: {{productName}}"
  messageTemplate: string; // e.g., "{{productName}} has dropped to {{currentStock}} units"
  variables: string[]; // ["productName", "currentStock", "threshold", "location"]
  isEnabled: boolean;
  createdBy: string; // admin user ID
  createdAt: Date;
  updatedAt: Date;
}
```

#### NotificationTriggerRule

Defines when and how notifications should be triggered.

```typescript
{
  id: string;
  tenantId: string;
  name: string;
  notificationType: NotificationType;
  triggerEvent: TriggerEventType; // 'stock.updated', 'invoice.overdue'
  conditionConfig: {
    operator?: 'AND' | 'OR';
    conditions?: Array<{
      field: string;
      operator: '<' | '>' | '=' | 'contains';
      value: any;
    }>;
  };
  templateId: string; // references NotificationTemplate
  recipientScope: {
    type: 'user' | 'role' | 'all';
    userIds?: string[];
    roleIds?: string[];
  };
  cooldownMinutes: number; // prevent duplicate notifications
  isEnabled: boolean;
  lastTriggeredAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}
```

#### NotificationDispatchRequest

Audit log for manual notification sends.

```typescript
{
  id: string;
  tenantId: string;
  templateId: string;
  recipients: Array<{ userId: string; email?: string }>;
  targetType: 'user' | 'role' | 'all'; // targeting mode
  sentAt: Date;
  successCount: number;
  failureCount: number;
  status: 'pending' | 'completed' | 'failed';
  createdBy: string; // admin who sent it
  createdAt: Date;
}
```

---

## User-Facing API Endpoints

### Get User Notifications

**Endpoint:** `GET /notifications`

**Authentication:** Required (JWT)

**Query Parameters:**

- `status` (optional): 'unread', 'read', 'archived'
- `type` (optional): notification type (low_stock, custom, etc.)
- `skip` (optional): pagination offset (default: 0)
- `limit` (optional): pagination limit (default: 20)

**Response:**

```json
{
  "data": [
    {
      "id": "uuid",
      "type": "low_stock",
      "title": "Low Stock Alert: Widget Pro",
      "message": "Widget Pro has dropped to 5 units at Main Warehouse",
      "alertData": {
        "productId": "prod-123",
        "currentStock": 5,
        "threshold": 10,
        "location": "Main Warehouse"
      },
      "status": "unread",
      "readAt": null,
      "createdAt": "2026-05-10T14:32:00Z"
    }
  ],
  "pagination": {
    "total": 47,
    "skip": 0,
    "limit": 20
  }
}
```

---

### Mark Notification as Read

**Endpoint:** `PATCH /notifications/:id/read`

**Authentication:** Required (JWT)

**Response:**

```json
{
  "message": "Notification marked as read",
  "data": {
    "id": "uuid",
    "status": "read",
    "readAt": "2026-05-10T14:35:00Z"
  }
}
```

---

### Mark All Notifications as Read

**Endpoint:** `PATCH /notifications/read-all`

**Authentication:** Required (JWT)

**Response:**

```json
{
  "message": "All notifications marked as read",
  "updatedCount": 12
}
```

---

### Clear All Notifications

**Endpoint:** `DELETE /notifications`

**Authentication:** Required (JWT)

**Query Parameters:**

- `status` (optional): clear only specific status ('unread', 'read', 'archived')

**Response:**

```json
{
  "message": "Notifications cleared",
  "deletedCount": 12
}
```

---

### Get Unread Count

**Endpoint:** `GET /notifications/unread-count`

**Authentication:** Required (JWT)

**Response:**

```json
{
  "count": 3
}
```

---

### Stream Notifications (SSE)

**Endpoint:** `GET /notifications/stream`

**Authentication:** Required (JWT, via query parameter or header)

**Headers:**

```
Authorization: Bearer <jwt-token>
```

**Description:** Opens a Server-Sent Event stream for real-time notifications. The server sends:

1. Initial bootstrap message with cached unread notifications
2. Real-time updates for new notifications

**Bootstrap Response:**

```
event: bootstrap
data: {"notifications":[{"id":"uuid","type":"low_stock","title":"..."}]}
```

**Real-time Event:**

```
event: notification
data: {"id":"uuid","type":"low_stock","title":"Low Stock Alert: Widget Pro","message":"...","createdAt":"2026-05-10T14:32:00Z"}
```

**Client Implementation:**

```javascript
const eventSource = new EventSource('/notifications/stream?token=' + jwtToken, {
  withCredentials: true,
});

eventSource.addEventListener('bootstrap', (e) => {
  const { notifications } = JSON.parse(e.data);
  // Load cached notifications
});

eventSource.addEventListener('notification', (e) => {
  const notification = JSON.parse(e.data);
  // Display new notification in real-time
});

eventSource.onerror = () => {
  // Reconnect with exponential backoff
};
```

---

### Get User Notification Preferences

**Endpoint:** `GET /notifications/preferences`

**Authentication:** Required (JWT)

**Response:**

```json
{
  "data": [
    {
      "id": "pref-uuid",
      "notificationType": "low_stock",
      "isEnabled": true,
      "threshold": {
        "minStockLevel": 10
      }
    },
    {
      "id": "pref-uuid-2",
      "notificationType": "overdue_payment",
      "isEnabled": false,
      "threshold": {
        "daysOverdue": 30
      }
    }
  ]
}
```

---

### Update User Notification Preferences

**Endpoint:** `POST /notifications/preferences`

**Authentication:** Required (JWT)

**Request Body:**

```json
{
  "notificationType": "low_stock",
  "isEnabled": true,
  "threshold": {
    "minStockLevel": 5
  }
}
```

**Response:**

```json
{
  "message": "Preference updated",
  "data": {
    "id": "pref-uuid",
    "notificationType": "low_stock",
    "isEnabled": true,
    "threshold": {
      "minStockLevel": 5
    }
  }
}
```

---

## Admin Control Panel API Endpoints

All control panel endpoints require:

- **Authentication:** JWT
- **Authorization:** `@RequirePermissions('manage:notification')` or `@RequirePermissions('send:notification')`

### Message Templates

#### Create Template

**Endpoint:** `POST /notifications/templates`

**Permissions:** `manage:notification`

**Request Body:**

```json
{
  "name": "Low Stock Alert Template",
  "notificationType": "low_stock",
  "titleTemplate": "⚠️ Low Stock: {{productName}}",
  "messageTemplate": "Product {{productName}} has dropped to {{currentStock}} units at {{location}}. Threshold is {{threshold}} units.",
  "variables": ["productName", "currentStock", "threshold", "location"]
}
```

**Response:**

```json
{
  "message": "Template created",
  "data": {
    "id": "tpl-uuid",
    "name": "Low Stock Alert Template",
    "notificationType": "low_stock",
    "titleTemplate": "⚠️ Low Stock: {{productName}}",
    "messageTemplate": "Product {{productName}} has dropped to {{currentStock}} units...",
    "variables": ["productName", "currentStock", "threshold", "location"],
    "isEnabled": true,
    "createdBy": "admin-user-id",
    "createdAt": "2026-05-10T14:32:00Z"
  }
}
```

---

#### List Templates

**Endpoint:** `GET /notifications/templates`

**Permissions:** `manage:notification`

**Query Parameters:**

- `type` (optional): filter by notification type
- `enabled` (optional): filter by enabled status (true/false)
- `skip` (optional): pagination offset (default: 0)
- `limit` (optional): pagination limit (default: 20)

**Response:**

```json
{
  "data": [
    {
      "id": "tpl-uuid",
      "name": "Low Stock Alert Template",
      "notificationType": "low_stock",
      "titleTemplate": "⚠️ Low Stock: {{productName}}",
      "messageTemplate": "...",
      "variables": ["productName", "currentStock", "threshold", "location"],
      "isEnabled": true,
      "createdBy": "admin-user-id",
      "createdAt": "2026-05-10T14:32:00Z"
    }
  ],
  "pagination": {
    "total": 5,
    "skip": 0,
    "limit": 20
  }
}
```

---

#### Update Template

**Endpoint:** `PATCH /notifications/templates/:id`

**Permissions:** `manage:notification`

**Request Body:**

```json
{
  "name": "Updated Low Stock Alert",
  "titleTemplate": "📦 Low Stock Alert: {{productName}}",
  "messageTemplate": "URGENT: {{productName}} is at {{currentStock}} units!",
  "variables": ["productName", "currentStock", "threshold", "location"],
  "isEnabled": true
}
```

**Response:** Updated template object

---

#### Delete Template

**Endpoint:** `DELETE /notifications/templates/:id`

**Permissions:** `manage:notification`

**Response:**

```json
{
  "message": "Template deleted successfully"
}
```

---

### Trigger Rules

#### Create Trigger Rule

**Endpoint:** `POST /notifications/rules`

**Permissions:** `manage:notification`

**Request Body:**

```json
{
  "name": "Low Stock on Critical Products",
  "notificationType": "low_stock",
  "triggerEvent": "stock.updated",
  "conditionConfig": {
    "operator": "AND",
    "conditions": [
      {
        "field": "currentStock",
        "operator": "<",
        "value": 10
      },
      {
        "field": "productCategory",
        "operator": "=",
        "value": "critical"
      }
    ]
  },
  "templateId": "tpl-uuid",
  "recipientScope": {
    "type": "role",
    "roleIds": ["role-warehouse-manager-id", "role-admin-id"]
  },
  "cooldownMinutes": 60,
  "isEnabled": true
}
```

**Response:**

```json
{
  "message": "Trigger rule created",
  "data": {
    "id": "rule-uuid",
    "name": "Low Stock on Critical Products",
    "notificationType": "low_stock",
    "triggerEvent": "stock.updated",
    "conditionConfig": { ... },
    "templateId": "tpl-uuid",
    "recipientScope": {
      "type": "role",
      "roleIds": ["role-warehouse-manager-id", "role-admin-id"]
    },
    "cooldownMinutes": 60,
    "isEnabled": true,
    "lastTriggeredAt": null,
    "createdAt": "2026-05-10T14:32:00Z"
  }
}
```

---

#### List Trigger Rules

**Endpoint:** `GET /notifications/rules`

**Permissions:** `manage:notification`

**Query Parameters:**

- `type` (optional): filter by notification type
- `event` (optional): filter by trigger event
- `enabled` (optional): filter by enabled status
- `skip` (optional): pagination offset (default: 0)
- `limit` (optional): pagination limit (default: 20)

**Response:**

```json
{
  "data": [
    {
      "id": "rule-uuid",
      "name": "Low Stock on Critical Products",
      "notificationType": "low_stock",
      "triggerEvent": "stock.updated",
      "conditionConfig": { ... },
      "templateId": "tpl-uuid",
      "recipientScope": { ... },
      "cooldownMinutes": 60,
      "isEnabled": true,
      "lastTriggeredAt": "2026-05-10T13:00:00Z",
      "createdAt": "2026-05-10T14:32:00Z"
    }
  ],
  "pagination": {
    "total": 3,
    "skip": 0,
    "limit": 20
  }
}
```

---

#### Update Trigger Rule

**Endpoint:** `PATCH /notifications/rules/:id`

**Permissions:** `manage:notification`

**Request Body:**

```json
{
  "name": "Low Stock on Critical Products (Updated)",
  "conditionConfig": {
    "operator": "AND",
    "conditions": [
      {
        "field": "currentStock",
        "operator": "<",
        "value": 5
      }
    ]
  },
  "cooldownMinutes": 30,
  "isEnabled": true
}
```

**Response:** Updated rule object

---

#### Delete Trigger Rule

**Endpoint:** `DELETE /notifications/rules/:id`

**Permissions:** `manage:notification`

**Response:**

```json
{
  "message": "Trigger rule deleted successfully"
}
```

---

### Manual Notifications

#### Preview Template

**Endpoint:** `POST /notifications/preview`

**Permissions:** `manage:notification` or `send:notification`

**Description:** Renders a template with sample or actual variables to preview the output.

**Request Body:**

```json
{
  "templateId": "tpl-uuid",
  "variables": {
    "productName": "Widget Pro",
    "currentStock": 5,
    "threshold": 10,
    "location": "Main Warehouse"
  }
}
```

**Response:**

```json
{
  "title": "⚠️ Low Stock: Widget Pro",
  "message": "Product Widget Pro has dropped to 5 units at Main Warehouse. Threshold is 10 units."
}
```

---

#### Send Custom Notification

**Endpoint:** `POST /notifications/send`

**Permissions:** `send:notification`

**Description:** Manually dispatch notifications to selected recipients.

**Request Body:**

```json
{
  "templateId": "tpl-uuid",
  "targetType": "role",
  "recipientIds": ["role-warehouse-manager-id"],
  "customVariables": {
    "productName": "Widget Pro",
    "currentStock": 5,
    "threshold": 10,
    "location": "Main Warehouse"
  },
  "testMode": false
}
```

**Query Parameters:**

- `testMode` (optional): if true, logs dispatch without sending (default: false)

**Response:**

```json
{
  "message": "Notifications dispatched",
  "data": {
    "id": "dispatch-uuid",
    "templateId": "tpl-uuid",
    "targetType": "role",
    "recipients": [
      {
        "userId": "user-123",
        "email": "manager@example.com"
      },
      {
        "userId": "user-456",
        "email": "admin@example.com"
      }
    ],
    "successCount": 2,
    "failureCount": 0,
    "status": "completed",
    "sentAt": "2026-05-10T14:32:00Z"
  }
}
```

---

## Developer Integration Guide

### Adding a New Notification Type

1. **Add to NotificationType Enum**

   File: `src/common/enums/notification-type.enum.ts`

   ```typescript
   export enum NotificationType {
     LOW_STOCK = 'low_stock',
     OVERDUE_PAYMENT = 'overdue_payment',
     CUSTOM_ALERT = 'custom_alert', // new type
   }
   ```

2. **Create a Notification Service/Evaluator**

   Example for overdue invoice notifications:

   ```typescript
   @Injectable()
   export class InvoiceAlertService {
     constructor(
       private notificationService: NotificationService,
       private triggerRuleService: NotificationTriggerRuleService,
     ) {}

     async checkOverdueInvoices(tenantId: string): Promise<void> {
       const overdueInvoices = await this.findOverdueInvoices(tenantId);

       for (const invoice of overdueInvoices) {
         const rules = await this.triggerRuleService.findActiveRules(
           tenantId,
           NotificationType.OVERDUE_PAYMENT,
           'invoice.overdue',
         );

         if (rules.length > 0) {
           for (const rule of rules) {
             await this.dispatchFromRule(rule, invoice);
           }
         } else {
           // Fallback to hardcoded notification
           await this.notificationService.create(
             tenantId,
             targetUsers,
             NotificationType.OVERDUE_PAYMENT,
             'Invoice Overdue',
             `Invoice #${invoice.invoiceNumber} is overdue by ${daysOverdue} days.`,
             { invoiceId: invoice.id, daysOverdue },
           );
         }
       }
     }

     private async dispatchFromRule(
       rule: NotificationTriggerRule,
       invoice: Invoice,
     ): Promise<void> {
       // Get template and render with variables
       const template = await this.templateService.findById(rule.templateId);
       const users = await this.resolveRuleRecipients(rule.recipientScope);

       for (const user of users) {
         await this.notificationService.create(
           invoice.tenantId,
           user.id,
           rule.notificationType,
           this.renderTemplate(template.titleTemplate, {
             invoiceNumber: invoice.invoiceNumber,
             daysOverdue: invoice.daysOverdue,
           }),
           this.renderTemplate(template.messageTemplate, {
             invoiceNumber: invoice.invoiceNumber,
             daysOverdue: invoice.daysOverdue,
           }),
           { invoiceId: invoice.id },
         );
       }
     }
   }
   ```

3. **Emit Events When Triggering Condition Occurs**

   Example in InvoiceService:

   ```typescript
   private notificationEventsService: NotificationEventsService;

   async updateInvoiceStatus(invoiceId: string, status: string): Promise<void> {
     const invoice = await this.invoiceRepo.findById(invoiceId);
     invoice.status = status;
     await this.invoiceRepo.save(invoice);

     // Emit event for notification system
     this.notificationEventsService.emitEvent({
       event: 'invoice.overdue',
       tenantId: invoice.tenantId,
       entityId: invoice.id,
       entityType: 'Invoice',
       data: {
         invoiceNumber: invoice.invoiceNumber,
         daysOverdue: this.calculateDaysOverdue(invoice),
       },
     });
   }
   ```

4. **Update Stock Alert Service** (if extending low-stock logic)

   File: `src/modules/notifications/services/stock-alert.service.ts`

   The service already checks for active rules and templates. No changes needed unless adding new conditions.

---

### Integrating Notifications into Other Modules

**In your module's service:**

```typescript
import { NotificationService } from '@modules/notifications/services';
import { NotificationType } from '@common/enums';

@Injectable()
export class MyModuleService {
  constructor(private notificationService: NotificationService) {}

  async performAction(): Promise<void> {
    // Your logic here

    // Create a notification
    await this.notificationService.create(
      tenantId,
      userId,
      NotificationType.CUSTOM_ALERT,
      'Action Completed',
      'Your action has been processed successfully.',
      { actionId: '123', timestamp: new Date() },
    );
  }
}
```

---

### Testing Notifications

**Unit Test Example:**

```typescript
describe('NotificationService', () => {
  let service: NotificationService;
  let repo: MockRepository<Notification>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        NotificationService,
        {
          provide: 'NotificationRepository',
          useValue: { create: jest.fn(), save: jest.fn() },
        },
      ],
    }).compile();

    service = module.get(NotificationService);
    repo = module.get('NotificationRepository');
  });

  it('should create a notification', async () => {
    const result = await service.create(
      'tenant-1',
      'user-1',
      NotificationType.LOW_STOCK,
      'Title',
      'Message',
      { productId: '1' },
    );

    expect(repo.create).toHaveBeenCalled();
    expect(repo.save).toHaveBeenCalled();
  });
});
```

---

### Environment Configuration

**Required environment variables:**

```bash
# Notifications
NOTIFICATION_ENABLED=true
NOTIFICATION_SSE_HEARTBEAT_INTERVAL=30000 # ms
NOTIFICATION_DIGEST_CRON='0 9 * * *' # Daily at 9 AM
NOTIFICATION_BATCH_SIZE=50 # For digest sending
```

---

## Troubleshooting

### SSE Connection Drops

**Issue:** Real-time notifications not arriving

**Solution:**

1. Check JWT token validity in SSE query parameter
2. Verify server heartbeat (should send comment every 30s)
3. Check browser console for CORS errors
4. Ensure tenant context is properly set for AsyncLocalStorage

### Templates Not Rendering

**Issue:** Variables not substituted in messages

**Solution:**

1. Verify template variables match the provided data
2. Check variable names are exact (case-sensitive)
3. Use `{{variableName}}` format (double braces)
4. Test with preview endpoint first

### Rules Not Triggering

**Issue:** Configured trigger rules never fire

**Solution:**

1. Verify rule is enabled (`isEnabled: true`)
2. Check trigger event name matches emission
3. Verify cooldown period hasn't expired
4. Check recipient scope resolves correctly (roles exist, users assigned)
5. Use admin logs to confirm event emissions

---

## Performance Considerations

- **Caching:** Templates and rules are cached; invalidate after updates
- **Batch Processing:** Daily digest processes up to `NOTIFICATION_BATCH_SIZE` per batch
- **Indexes:** Database indexes on (tenant_id, created_at) and (tenant_id, enabled) for optimal query performance
- **SSE Limits:** Each user can maintain one active SSE connection; old connections are closed on new login

---

## Permissions Matrix

| Feature                   | Permission            | Role           |
| ------------------------- | --------------------- | -------------- |
| View notifications        | `read:notification`   | All users      |
| Update preferences        | `read:notification`   | All users      |
| Create/Edit templates     | `manage:notification` | Admin, Manager |
| Create/Edit trigger rules | `manage:notification` | Admin, Manager |
| Send custom notifications | `send:notification`   | Admin          |
| View dispatch history     | `send:notification`   | Admin          |

---

## Version History

- **1.0.0** (2026-05-10): Initial release
  - Real-time SSE streaming
  - Low-stock alerts
  - User preferences
  - Template management
  - Trigger rule engine
  - Manual custom notifications
