# Webhook integrations

Outbound webhooks notify external systems when domain events occur in the ERP. Deliveries are **asynchronous** with a database-backed outbox, retries, and optional in-app fallback notifications.

## Event catalog

| Event | When emitted |
|-------|----------------|
| `invoice.posted` | Customer invoice posted to GL |
| `payment.confirmed` | AR payment confirmed |
| `payment.reversed` | AR payment reversed |
| `invoice.credit_note.created` | Sales credit note created (draft) |
| `vendor_bill.posted` | Vendor bill posted |
| `vendor_payment.confirmed` | Vendor bill payment recorded |
| `approval.requested` | High-value approval request created |
| `approval.decided` | Approval approved or rejected |
| `webhook.test` | Manual test from Integrations UI |

Subscribe to specific events or use `*` for all events.

## Payload format

Each delivery is a JSON POST:

```json
{
  "schemaVersion": 1,
  "deliveryId": "<outbox-uuid>",
  "event": "invoice.posted",
  "tenantId": "<tenant-uuid>",
  "payload": { "invoiceId": "...", "number": "...", "totalAmount": 1000, "partnerId": "..." },
  "at": "2026-05-24T12:00:00.000Z"
}
```

Headers:

- `Content-Type: application/json`
- `X-Webhook-Event`: event name
- `X-Webhook-Signature`: HMAC-SHA256 hex of the **raw body** using the subscription secret
- `X-Webhook-Delivery-Id`: same as `deliveryId` in the body (use for idempotency)

### Verify signature (Node.js)

```javascript
const crypto = require('crypto');

function verifyWebhook(rawBody, secret, signatureHeader) {
  const expected = crypto
    .createHmac('sha256', secret)
    .update(rawBody)
    .digest('hex');
  return crypto.timingSafeEqual(
    Buffer.from(expected, 'hex'),
    Buffer.from(signatureHeader, 'hex'),
  );
}
```

## Retries

- Each matching subscription gets its own outbox row per event.
- A cron worker runs every **2 minutes** and processes up to **30** pending/failed rows.
- On non-2xx or network error: `attempts` increments, status `FAILED`, `next_attempt_at` = `retry_backoff_seconds * 2^(attempt-1)`.
- After `max_retries` (default 5, per subscription): status `DEAD`, delivery logged, fallback may run.

Manual **Retry now** resets a row to `PENDING` from the Integrations UI.

## In-app fallback

When enabled on a subscription:

- **After retries exhausted (DEAD):** users receive an `integration_alert` in-app notification.
- **On first failure (`fallback_on_failure`):** optional early alert while retries continue.

Recipients (in order):

1. `fallback_user_ids` if set
2. Else `fallback_role_ids` if set
3. Else users with `read:invoice` or `post:invoice` permissions

Dedupe: at most one fallback per subscription + event + source entity per calendar day.

## Admin API

| Method | Path |
|--------|------|
| GET | `/finance/webhooks/events` |
| GET/POST | `/finance/webhooks` |
| PUT | `/finance/webhooks/:id` |
| PATCH | `/finance/webhooks/:id/toggle` |
| POST | `/finance/webhooks/:id/test` |
| GET | `/finance/webhooks/delivery-logs` |
| GET | `/finance/webhooks/outbox` |
| POST | `/finance/webhooks/outbox/:id/retry` |

## Deployment

1. Run migrations `1772300000000` and `1772310000000`.
2. Re-run tenant RLS script for `webhook_delivery_outbox` if applicable.
3. Ensure the app process runs `@nestjs/schedule` (cron worker).

Existing subscriptions keep working with defaults: `max_retries=5`, `fallback_enabled=false`.
