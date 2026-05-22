# RBAC & Permissions

How permissions are defined, synced, enforced on the API, and reflected in the UI.

**Last updated:** May 15, 2026

---

## Single source of truth

| Layer | File |
| ----- | ---- |
| Backend enum | `backend/src/modules/identity/constants/permissions.enum.ts` |
| DB sync on bootstrap | `backend/src/modules/identity/permission-sync.service.ts` |
| Frontend mirror | `frontend/src/lib/rbac/backend-permissions.ts` |
| Route meta | `frontend/src/lib/rbac/types.ts`, route definitions |
| Guards | `frontend/src/lib/rbac/guards.ts` |

**Rule:** When adding a permission, update **both** enum files, run the backend (sync inserts new rows), and assign the permission to roles.

---

## Permission catalog

### Identity & admin

| Permission | Description |
| ---------- | ----------- |
| `create:role`, `read:role`, `update:role`, `delete:role` | Role management |
| `create:user`, `read:user`, `update:user`, `delete:user` | User management |
| `create:tenant`, `read:tenant`, `update:tenant`, `delete:tenant` | Tenant management |

### Finance

| Permission | Description |
| ---------- | ----------- |
| `create:account`, `read:account`, `update:account`, `delete:account` | Chart of accounts |
| `create:journal`, `read:journal`, `approve:journal`, `delete:journal` | Journal entries |
| `create:period`, `read:period`, `update:period` | Fiscal periods |

### Inventory

| Permission | Description |
| ---------- | ----------- |
| `create:stock`, `read:stock`, `update:stock`, `delete:stock` | Stock documents |
| `adjust:stock`, `transfer:stock` | Adjustments & transfers |
| `create:location`, `read:location`, `update:location` | Warehouses |
| `create:product`, `read:product`, `update:product`, `delete:product` | Products |

### Sales

| Permission | Description |
| ---------- | ----------- |
| `create:sales_order`, `read:sales_order` | Sales orders |
| `update:sales_order` | Send quote, confirm order, edit draft |
| `cancel:sales_order` | Cancel order |
| `create:invoice`, `read:invoice` | Invoices |
| `post:invoice` | Post invoice (AR + revenue) |
| `pay:invoice` | Record customer payment |

### Procurement

| Permission | Description |
| ---------- | ----------- |
| `create:purchase_order`, `read:purchase_order` | POs & RFQs |
| `confirm:purchase_order` | Confirm PO, receive goods |
| `create:vendor_bill`, `read:vendor_bill` | Vendor bills |
| `post:vendor_bill` | Post bill (AP) |
| `pay:vendor_bill` | Record vendor payment |

### Partners & other

| Permission | Description |
| ---------- | ----------- |
| `create:partner`, `read:partner`, `update:partner`, `delete:partner` | Customers/vendors |
| `read:notification`, `manage:notification`, `send:notification` | Notifications |
| `sync:pos` | POS sync |

Full list: `permissions.enum.ts`.

---

## Backend enforcement

Controllers use:

```typescript
@RequirePermissions(PERMISSIONS.INVOICES.PAY)
```

with `PermissionsGuard` and `JwtAuthGuard`.

The JWT payload includes `permissions: string[]` from the user's roles. Missing permission → **403 Forbidden**.

---

## Frontend enforcement

### Route level

Routes declare `beforeLoad` checks using `read:*` permissions or role lists (e.g. finance pages may require `ADMIN` / `MANAGER`).

Routes block navigation; they do not replace API checks.

### Action level (detail pages)

Hooks and helpers:

| Utility | Path | Usage |
| ------- | ---- | ----- |
| `usePermission(permission)` | `frontend/src/shared/hooks/usePermission.ts` | Single permission boolean |
| `usePermissions([...], 'all' \| 'any')` | same | Multiple permissions |
| `PermissionGate` | `frontend/src/shared/components/PermissionGate.tsx` | Conditional render wrapper |
| `hasPermission` | `frontend/src/lib/rbac/guards.ts` | Imperative checks |

### Gated UI (implemented)

| Page | Permissions combined with document status |
| ---- | ---------------------------------------- |
| `InvoiceDetailPage` | `post:invoice`, `pay:invoice` |
| `VendorBillDetailPage` | `post:vendor_bill`, `pay:vendor_bill` |
| `PurchaseOrderDetailPage` | `confirm:purchase_order`, `create:vendor_bill` |
| `SalesOrderDetailPage` | `update:sales_order`, `cancel:sales_order`, `create:invoice` |
| `StockReceiptDetailPage` | `update:stock` (edit, complete) |
| `SalesOrdersListPage` | `create:sales_order` (New button) |
| `PurchaseOrdersListPage`, `RfqListPage` | `create:purchase_order` (New RFQ button) |

Pattern:

```typescript
const mayPay = usePermission(PERMISSIONS.INVOICES.PAY);
const canPay = invoice.status === "SENT" && balanceDue > 0.01 && mayPay;
```

### Admin bypass

```typescript
if (user.role === "ADMIN") return true; // all permissions
```

Applies to legacy primary `role` field only. Users with admin in `roles[]` but not primary `ADMIN` rely on explicit permission grants.

---

## Assigning permissions to roles

1. Start backend — `PermissionSyncService` upserts permission rows.
2. Open **Settings → Roles** (or use API).
3. Assign new permissions (e.g. `pay:invoice`, `pay:vendor_bill`) to Accountant, Manager, etc.
4. User must re-login (or refresh token) to load updated `permissions` in JWT.

Tenant bootstrap (`create-tenant.ts`) may grant all permissions to the initial admin role only.

---

## Action → permission quick reference

| User action | Permission |
| ----------- | ---------- |
| Post invoice | `post:invoice` |
| Record invoice payment | `pay:invoice` |
| Post vendor bill | `post:vendor_bill` |
| Record vendor payment | `pay:vendor_bill` |
| Confirm / receive PO | `confirm:purchase_order` |
| Create bill from PO | `create:vendor_bill` |
| Send quote / confirm order | `update:sales_order` |
| Cancel order | `cancel:sales_order` |
| Create invoice from order | `create:invoice` |
| Complete stock receipt | `update:stock` |
| New sales order | `create:sales_order` |
| New RFQ / PO | `create:purchase_order` |

---

## Testing permissions

1. Create a role with only `read:invoice` (no `pay:invoice`).
2. Assign to test user, log in.
3. Open invoice detail — Pay button should be hidden; `POST .../payments` returns 403.

---

## Related documentation

- [Accounting phases](./ACCOUNTING-INVENTORY-PHASES.md) — API endpoints per permission
- [Workflows index](../backend/docs/WORKFLOWS-INDEX.md) — business process overview
- [Error handling / 403](../backend/docs/rls-http-status-quick-reference.md)
