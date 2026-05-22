# Nest ERP — Documentation Index

Central index for all project documentation. Prefer links here over scattered root-level markdown files.

**Last updated:** May 15, 2026

---

## Start here

| Audience | Document |
| -------- | -------- |
| **End users (all features)** | **[End user manual](./END-USER-MANUAL.md)** |
| New developers | [Backend developer index](../backend/docs/DEVELOPER-INDEX.md) |
| Business / ops | [ERP workflows index](../backend/docs/WORKFLOWS-INDEX.md) |
| Accounting & inventory (Phases 5–10) | [Accounting & inventory phases](./ACCOUNTING-INVENTORY-PHASES.md) |
| Permissions & UI gating | [RBAC & permissions](./RBAC-AND-PERMISSIONS.md) |
| Notifications | [Notifications hub](../NOTIFICATIONS.md) |

---

## Monorepo layout

```
nest-erp/
├── backend/          NestJS API (submodule)
├── frontend/         React + TanStack Router (submodule)
└── docs/             Cross-cutting guides (this folder)
```

Clone with submodules: `git clone --recursive <url>`

---

## Backend (`backend/docs/`)

### Architecture & development

| Document | Topic |
| -------- | ----- |
| [DEVELOPER-INDEX.md](../backend/docs/DEVELOPER-INDEX.md) | Master technical index |
| [architecture.md](../backend/docs/architecture.md) | Multi-tenancy, RLS, modules |
| [development.md](../backend/docs/development.md) | Local dev setup |
| [db-setup.md](../backend/docs/db-setup.md) | Database initialization |
| [migrations.md](../backend/docs/migrations.md) | TypeORM migrations |
| [testing.md](../backend/docs/testing.md) | Test strategy |
| [operations.md](../backend/docs/operations.md) | Production operations |
| [roadmap.md](../backend/docs/roadmap.md) | Planned work |

### Security & RLS

| Document | Topic |
| -------- | ----- |
| [error-handling-security.md](../backend/docs/error-handling-security.md) | API error patterns |
| [rls-http-status-quick-reference.md](../backend/docs/rls-http-status-quick-reference.md) | 403 vs 500 for RLS |
| [rls-violation-diagnosis-and-fix.md](../backend/docs/rls-violation-diagnosis-and-fix.md) | INSERT RLS failures |
| [rls-violation-quick-fix.md](../backend/docs/rls-violation-quick-fix.md) | Quick transaction pattern |

### Business workflows

| Document | Topic |
| -------- | ----- |
| [WORKFLOWS-INDEX.md](../backend/docs/WORKFLOWS-INDEX.md) | Order-to-cash, purchase-to-pay |
| [workflow-sales-flow.md](../backend/docs/workflow-sales-flow.md) | Quotes → orders → invoices → payments |
| [workflow-cash-flow.md](../backend/docs/workflow-cash-flow.md) | AR/AP, GL, reports |
| [workflow-products-operations.md](../backend/docs/workflow-products-operations.md) | Inventory & products |
| [workflow-clients-management.md](../backend/docs/workflow-clients-management.md) | Partners |

### Domain-specific (implemented)

| Document | Topic |
| -------- | ----- |
| [ACCOUNTING-INVENTORY-PHASES.md](./ACCOUNTING-INVENTORY-PHASES.md) | Phases 5–10: GL, procurement, payments, PPV, reconciliation |
| [RBAC-AND-PERMISSIONS.md](./RBAC-AND-PERMISSIONS.md) | Permission enum, routes, UI gating |
| [notifications-api.md](../backend/docs/notifications-api.md) | Notifications API & integration |

---

## Frontend (`frontend/`)

| Document | Topic |
| -------- | ----- |
| [README.md](../frontend/README.md) | Frontend overview |
| [GETTING_STARTED.md](../frontend/GETTING_STARTED.md) | Setup |
| [FEATURES.md](../frontend/FEATURES.md) | Feature map |
| [docs/ROUTING_AND_I18N.md](../frontend/docs/ROUTING_AND_I18N.md) | Routes & i18n |
| [docs/route-factory-guide.md](../frontend/docs/route-factory-guide.md) | Route factory |

### Key UI routes (accounting)

| Path | Page |
| ---- | ---- |
| `/$lang/app/sales/invoices/$invoiceId` | Invoice detail — post, record payment |
| `/$lang/app/procurement/bills/$billId` | Vendor bill — post, record payment |
| `/$lang/app/procurement/orders/$orderId` | PO — confirm, receive, create bill |
| `/$lang/app/finance/gl-reconciliation` | AR/AP subledger vs GL |
| `/$lang/app/inventory/settings` | Valuation method, standard costs |
| `/$lang/app/settings/notifications` | Notification control plane |

---

## Root-level legacy files

These files predate the `docs/` hub. They remain for history; prefer the canonical docs above.

| File | Status | Use instead |
| ---- | ------ | ----------- |
| `notifications-api.md` | Duplicate | `backend/docs/notifications-api.md` |
| `NOTIFICATIONS.md` | Index | Still valid — links to backend doc |
| `NOTIFICATION_TESTING_*.md`, `HOW_TO_TEST_NOTIFICATIONS.md` | Test notes | [notifications-api.md](../backend/docs/notifications-api.md) |
| `POS-*.md` | POS redesign notes | `frontend` POS module when building UI |
| `BUG_FIX_*.md` | Incident notes | [ACCOUNTING-INVENTORY-PHASES.md](./ACCOUNTING-INVENTORY-PHASES.md) |

---

## Migrations quick reference (accounting track)

| Migration | Phase | Summary |
| --------- | ----- | ------- |
| `1768700000000` | Valuation | FIFO/LIFO/AVERAGE/STANDARD, tenant inventory settings |
| `1768900000000` | 5 | Journal `source_type` / `source_id`, period close reversal |
| `1769000000000` | 6 | PO `qty_received` / `qty_billed`, receipt/bill line links |
| `1769100000000` | 7 | Category COGS & inventory GL accounts |
| `1769200000000` | 8 | `vendor_payments` table |
| `1769300000000` | 9 | `invoice_payments`, `default_ppv_account_id` |

Run migrations: `cd backend && pnpm migration:run`

---

## Contributing to docs

1. Add cross-cutting guides under `docs/`.
2. Add module-specific API detail under `backend/docs/`.
3. Update this index and [DEVELOPER-INDEX.md](../backend/docs/DEVELOPER-INDEX.md).
4. Keep [permissions.enum.ts](../backend/src/modules/identity/constants/permissions.enum.ts) and [backend-permissions.ts](../frontend/src/lib/rbac/backend-permissions.ts) in sync — see [RBAC-AND-PERMISSIONS.md](./RBAC-AND-PERMISSIONS.md).
