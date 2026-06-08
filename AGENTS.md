# nest-erp Agent Guide

Monorepo: `backend/` (NestJS) + `frontend/` (React/Vite). Global rules in `.cursorrules`.

## Skill Index — load before domain work

| Task | Skill file |
|------|------------|
| Monorepo layout, build, multi-tenancy, RLS | `docs/skills/01-core-architecture.md` |
| Backend entities, DTOs, auth, idempotency, interceptors | `docs/skills/02-backend-patterns.md` |
| Frontend stores, React Query, forms, MUI, i18n, routing | `docs/skills/03-frontend-patterns.md` |
| Cross-module flows (Sales↔Inventory↔Finance, POS, HRMS) | `docs/skills/04-domain-logic.md` |

## Quick Routing

### Backend (`backend/src/`)
- **Auth/passkeys/sessions** → `auth/` + `02-backend-patterns.md`
- **Tenant/RLS/transaction issues** → `common/interceptors/tenant-transaction.interceptor.ts` + `01-core-architecture.md`
- **Finance/GL/journals** → `modules/finance/` + `04-domain-logic.md` (InventoryPostingService, webhooks)
- **Inventory/stock** → `modules/inventory/` + `04-domain-logic.md`
- **Sales/invoices/commissions** → `modules/sales/` + `04-domain-logic.md`
- **Procurement/POs/vendor bills** → `modules/procurement/` + `04-domain-logic.md`
- **HRMS/payroll** → `modules/hrms/` + `04-domain-logic.md`
- **POS offline sync** → `modules/pos/` + `04-domain-logic.md` (POS ≠ full invoice path)
- **Migrations/schema** → `database/` (admin DS only) + `02-backend-patterns.md`

### Frontend (`frontend/src/`)
- **Auth UI** → `features/auth/` + `03-frontend-patterns.md`
- **API hooks** → `lib/api/queries/`, `lib/api/mutations/` + `query-keys.ts`
- **Forms** → `shared/form/useAppForm.ts` (TanStack Form + Zod, not RHF)
- **New feature page** → `features/<domain>/` + `scripts/generate-feature.ts`
- **i18n/RTL** → `lib/i18n/` + `frontend/.cursor/skills/fix-i18n-tsc-crash/` (typed-key fixes)
- **RBAC UI** → `lib/rbac/` + `IfAllowed` / `RequireAuth`

## Non-Negotiables
- All API requests: `x-tenant-id` header; JWT tenant must match.
- Tenant writes: interceptor transaction + RLS — not manual `WHERE tenant_id` alone.
- Mutating POSTs (Finance/Sales/Procurement/Inventory): `@Idempotent()` + `Idempotency-Key`.
- Frontend server state: TanStack Query + `queryKeys` factory — not Zustand.
- POS sync creates `SalesOrder` only — no auto-invoice/stock-issue.

## Existing Cursor Skills
- `frontend/.cursor/skills/fix-i18n-tsc-crash/` — unsafe i18n key patterns
