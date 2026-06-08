# 01 — Core Architecture

## Monorepo Layout
- Root: two independent apps — `backend/`, `frontend/` — each with own `package.json`, `pnpm-lock.yaml`.
- No root workspace; `pnpm-workspace.yaml` exists per app (build allowlist only).
- Backend entry: `backend/src/main.ts` → `dist/src/main`.
- Frontend entry: `frontend/src/main.tsx` → `frontend/src/app/index.tsx`.

## Build Tools
- **pnpm** — install/run per app directory.
- **Nest CLI** — `nest build`, `nest start --watch`; config: `backend/nest-cli.json` (`sourceRoot: src`, single app).
- **Vite 8** — `frontend/vite.config.ts`: `@/` alias, React Compiler, PWA injectManifest, dev proxy `/api` → `:3000`.
- Vendor chunks: react, mui-core, mui-icons, tanstack, date-fns, i18n.

## Backend Bootstrap
- Global prefix: `api/v1` via `applyGlobalApiPrefix()`; excludes `health`, Swagger.
- Global providers (`AppModule`): `DatabaseExceptionFilter`, `TenantTimezoneInterceptor`, `TenantTransactionInterceptor`, `IdempotencyInterceptor`.
- Global pipe: `ValidationPipe({ transform: true })`.
- Swagger requires `bearer` + `x-tenant-id` on all operations.

## Module Map (`AppModule` imports)
| Module | Path | Notes |
|--------|------|-------|
| IdentityModule | `modules/identity/` | `@Global()` — users, tenants, roles, RBAC, audit |
| AuthModule | `auth/` | JWT, passkeys, sessions |
| FinanceModule | `modules/finance/` | GL, AR/AP, webhooks, budgets |
| InventoryModule | `modules/inventory/` | Products, stock, BOM, stocktake |
| SalesModule | `modules/sales/` | Orders, invoices, partners, commissions |
| ProcurementModule | `modules/procurement/` | POs, vendor bills, RFQs |
| HrmsModule | `modules/hrms/` | Employees, payroll, attendance |
| PosModule | `modules/pos/` | Offline sync |
| ComplianceModule | `modules/compliance/` | ETA eInvoicing (Egypt) |
| I18nModule | `modules/i18n/` | Product translations |
| NotificationsModule | `modules/notifications/` | Email/push outbox |
| FilesModule | `modules/files/` | Local/S3 attachments |
| ImportModule | `modules/import/` | Import jobs |
| CommonModule | `common/` | `@Global()` DB health, timezone cache |

## Per-Domain Internal Structure
```
modules/<domain>/
  <domain>.module.ts
  <domain>.controller.ts
  <domain>.service.ts
  entities/*.entity.ts
  dto/*.dto.ts
  services/*.service.ts
  controllers/*.controller.ts   # split when surface grows
```

## Multi-Tenancy Pipeline

### Request → Context
1. `TenantMiddleware` (`common/middleware/tenant.middleware.ts`)
   - Resolves tenant: `x-tenant-id` header → `?tenantId=` → JWT from `?token=`.
   - Parses `Accept-Language` → locale.
   - Wraps in `TenantContext.run({ tenantId, locale }, next)`.
   - Registered for `*` excluding `/`, `health`.

2. `TenantContext` (`common/context/tenant.context.ts`)
   - `AsyncLocalStorage`: `tenantId`, `userId`, `entityManager`, `locale`, `timezone`.
   - APIs: `requireTenantId()`, `setUserId()`, `getEntityManager()`, `setEntityManager()`.

### Transaction + RLS
3. `TenantTransactionInterceptor` (global)
   - Wraps each HTTP request in DB transaction.
   - Sets `app.current_tenant_id`, `app.current_user_id` via parameterized `set_config(..., true)`.
   - Stores transaction `EntityManager` in `TenantContext`.
   - Enforces JWT `tenantId` === `x-tenant-id`.
   - Skips for SSE handlers (`SSE_METADATA`).

4. `TenantTimezoneInterceptor` (global)
   - Loads tenant IANA timezone via `TenantTimezoneCacheService` → `TenantContext`.

### Repository Access
- `wrapTenantRepository()` (`common/repositories/tenant-repository-wrapper.ts`) — Proxy redirects repo calls to transaction-scoped manager.
- `tenant-query.helper.ts`: `applyTenantScope()`, `getTenantRepository()`, `validateTenantOwnership()`, `withTenantContext()`.
- Manual tx: `withTenantTransaction()` / `createTenantQueryRunner()` in `audit-session.util.ts` (POS batch sync uses per-item runners).

### PostgreSQL RLS
- `database/scripts/rls_setup.sql` — auto-loops tables with `tenant_id` column.
- `ENABLE ROW LEVEL SECURITY` + `FORCE ROW LEVEL SECURITY`.
- Policy `tenant_isolation_policy`: `current_setting('app.current_tenant_id', true)::uuid`.
- Excludes: `permissions`, `migrations`, `typeorm_metadata`.
- Applied by `scripts/setup-db.ts` after schema init.

### Tenant Provisioning
- `scripts/create-tenant.ts`, `TenantService` / `TenantController` in identity module.

## Database Dual-Role Pattern
- **App DS** (`database/data-source.ts`): `DB_USERNAME` — RLS-enforced role; used at runtime.
- **Admin DS** (`database/admin-data-source.ts`): `DB_ADMIN_USER` — migrations only (`pnpm migration:run`).
- Entities glob: `src/modules/**/*.entity.ts`.
- Migrations: `src/database/migrations/*.ts`; `synchronize: false`.
- Bootstrap: `scripts/setup-db.ts` — admin role/DB → schema → RLS → audit triggers.

## Frontend App Structure
```
src/
  app/          # router, providers, navigation registry
  features/     # domain modules (auth, finance, inventory, sales, pos, hrms, …)
  lib/          # api, auth, i18n, rbac, theme
  shared/       # layouts, UI, form toolkit
  stores/       # global Zustand
  config/       # APP_CONFIG, API_PATHS, ROUTES, STORAGE_KEYS
  types/        # backend DTO types
```

## Frontend Routing
- TanStack Router; URL: `/:lang/app/<feature>`.
- Public tree: `app/router/buildRouteTree.ts` (login, change-password).
- Authenticated: `app/router/appRoutes.ts` aggregates feature `*Routes.ts`.
- Auth-gated swap: `routerManager.ts` — `upgradeRouterWithAppRoutes()` on login.
- Guards: `RouteGuard()` — auth rehydrate, `mustChangePassword`, RBAC `canAccess()`.
- Nav: `{domain}ModuleNav` → `app/navigation/moduleRegistry.ts`.

## Doc Drift Warning
- `docs/db-setup-architecture.md` references `TenantSubscriber` — **not present**. Live impl: `TenantTransactionInterceptor` + `audit-session.util.ts`.
