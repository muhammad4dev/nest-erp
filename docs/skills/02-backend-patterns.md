# 02 — Backend Patterns

## TypeORM

### Config (`config/database.config.ts`)
- Postgres, `autoLoadEntities: true`, `synchronize: false`.
- `uuidExtension: 'pgcrypto'` (TypeORM uses `gen_random_uuid()`).
- Pool via `extra`: `DB_POOL_MAX`, keepalive, `application_name: 'nest-erp-api'`.

### Base Entity (`common/entities/base.entity.ts`)
- `@PrimaryGeneratedColumn('uuid') id`
- `tenantId` (`tenant_id` column)
- `createdAt` / `updatedAt` (timestamptz, snake_case)
- `@VersionColumn()` optimistic locking
- Exceptions: `Tenant` (no tenant_id), `IdempotencyLog` (custom shape).

### Entity Locations
- Domain: `modules/<domain>/entities/*.entity.ts`
- Shared inventory costing: `common/entities/inventory/`
- Table names: snake_case plural (`journal_entries`); enum columns: PascalCase enum, UPPER values.

### Migrations
- Baseline: `database/migrations/1766964247724-migrations.ts`
- UUIDv7 defaults: `migrations/utils/ensure-uuidv7-defaults.ts`
- Audit triggers: `migrations/audit_trigger.sql`
- Run: `pnpm migration:run` (admin DS only).

## Idempotency

### Decorator + Interceptor
- `@Idempotent()` (`common/decorators/idempotent.decorator.ts`) — opt-in via `IDEMPOTENT_KEY` metadata.
- `IdempotencyInterceptor` (global) — requires `Idempotency-Key` header.
- Heavy use: `FinanceController` (39 endpoints), `ProcurementController` (9), `InventoryController` (5), `SalesController` (1).

### Storage (`common/entities/idempotency-log.entity.ts`)
- Tenant-scoped; global unique `idempotencyKey`.
- JSONB request/response; 24h `expiresAt`.
- `IdempotencyService.checkAndStore()` — rejects key reuse on different endpoint/method.

## Global Interceptors & Filters

| Component | File | Role |
|-----------|------|------|
| `TenantTransactionInterceptor` | `common/interceptors/tenant-transaction.interceptor.ts` | Tx + RLS session vars |
| `TenantTimezoneInterceptor` | `common/interceptors/tenant-timezone.interceptor.ts` | Tenant IANA tz |
| `IdempotencyInterceptor` | `common/interceptors/idempotency.interceptor.ts` | Dedup mutating POSTs |
| `DatabaseExceptionFilter` | `common/filters/database-exception.filter.ts` | PG errors → 503 via `DatabaseRecoveryService` |

## Guards & RBAC

### Stack (per-controller, not global)
- `JwtAuthGuard` (`auth/jwt-auth.guard.ts`) — thin `AuthGuard('jwt')` wrapper.
- `PermissionsGuard` (`modules/identity/guards/permissions.guard.ts`) — reads `@RequirePermissions()`, checks cache/DB, validates tenant header vs JWT.

### Permissions Model
- Denormalized `User.permissions` (`text[]`, format `action:resource`).
- `PermissionsCacheService` — in-memory TTL aligned with JWT (15m).
- Decorator: `@RequirePermissions('create:journal', 'read:stock')`.
- Enum: `permissions.enum.ts`.

## Auth Flow

### Key Files
- `auth/auth.module.ts`, `auth.service.ts`, `auth.controller.ts`
- `auth/jwt.strategy.ts`, `auth/jwt-auth.guard.ts`
- `auth/passkey.service.ts`, `auth/passkey.controller.ts`, `auth/config/webauthn.config.ts`
- `auth/session.service.ts`, `auth/user-security.controller.ts`
- Entities: `UserPasskey`, `WebAuthnChallenge`, `RefreshToken` in `modules/identity/entities/`

### Password Login
1. `validateUser()` — tenant-scoped lookup via `wrapTenantRepository`, bcrypt compare.
2. `login()` — JWT `{ sub, email, tenantId, roles }`, 15m expiry.
3. Refresh token: 64-byte random hex, **SHA-256 hash stored** in `refresh_tokens`, 30-day expiry.
4. Stores `userAgent`, `ipAddress`, `authMethod`.
5. Denormalized permissions cached via `PermissionsCacheService.set()`.

### Refresh / Logout
- `refreshAccessToken()` — hash lookup, expiry check, **token rotation** (revoke old, issue new).
- `logout()` / `logoutAllDevices()` — revoke by hash / userId.

### Passkeys (WebAuthn — `@simplewebauthn/server`)
- Config: `WEBAUTHN_RP_ID`, `WEBAUTHN_ORIGIN`, `WEBAUTHN_ADDITIONAL_ORIGINS`.
- Registration (auth'd): `POST auth/passkeys/register/options|verify` — challenges in `WebAuthnChallenge`.
- Login (public): `POST auth/passkeys/login/options|verify` → `PasskeyService.verifyAuthentication()` → `AuthService.login(..., 'passkey')`.
- Admin mgmt: `UserSecurityController` at `users/:userId/passkeys|sessions`.

### Sessions
- Sessions **are refresh-token rows** (`RefreshToken` entity) — not opaque session IDs.
- `SessionService.listSessions()` → `SessionResponseDto` with UA-parsed device label.
- Current session flagged via optional `x-refresh-token` header hash compare.
- Endpoints: `GET/DELETE auth/sessions`; admin variants on `UserSecurityController`.

## DTO Validation
- `class-validator` + `class-transformer` + `@nestjs/swagger`.
- Global `ValidationPipe({ transform: true })` in `main.ts`.
- Route params: `ParseUUIDPipe`; inventory routes: `ParseUUIDPipe({ version: '7' })`.
- No custom pipes in codebase.
- Controller tests: `.overrideGuard(PermissionsGuard).useValue({ canActivate: () => true })`.

## Service Patterns
```typescript
// Constructor pattern
constructor(@InjectRepository(Entity) repo: Repository<Entity>) {
  this.repo = wrapTenantRepository(repo);
}

// Complex writes
await withTenantTransaction(this.dataSource, async (manager) => { ... });
// Or rely on TenantTransactionInterceptor transaction
```

## Cross-Module Integration
- Direct Nest DI imports — **no EventEmitter**.
- Async external: `WebhookEventHubService.emit()` / `WebhookDispatcherService.dispatch()`.
- Event catalog: `modules/finance/webhooks/webhook-events.ts`.
- Journal creation: direct service/repo calls inside transactions.

## Webhooks (Finance-owned)
- `WebhookEventHubService` — internal event emission.
- `WebhookDispatcherService` — external webhook delivery.
- Events: `invoice.posted`, `payment.confirmed`, `VENDOR_BILL_POSTED`, `VENDOR_PAYMENT_CONFIRMED`, `INVOICE_CREDIT_NOTE_CREATED`.

## Testing
- Unit: co-located `*.spec.ts` in `src/`.
- E2E: `test/jest-e2e.json`; tenant isolation: `test/tenant-header.e2e-spec.ts`, `test/leak.e2e-spec.ts`.

## Naming Reference
| Artifact | Pattern | Example |
|----------|---------|---------|
| Files | kebab-case + suffix | `journal-entry.service.ts` |
| Classes | PascalCase + suffix | `JournalEntryService` |
| DTOs | `create-*.dto.ts` | `CreateSalesOrderDto` |
| Permissions | `action:resource` | `create:journal` |
| Scripts | `scripts/*.ts` | `setup-db.ts`, `create-tenant.ts` |
