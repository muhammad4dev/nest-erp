# 03 — Frontend Patterns

## Stack
- React 19, Vite 8, TanStack Router/Query/Form, Zustand 5, MUI 7, Axios, i18next, Zod 4, `@simplewebauthn/browser`.
- **No react-hook-form.**

## Zustand Stores

### Global (`src/stores/`)
| Hook | File | Persist | Role |
|------|------|---------|------|
| `useAuthStore` | `authStore.ts` | yes (`STORAGE_KEYS.AUTH`) | user, tokens, tenant, `login`/`logout`/`selectTenant`/`patchUser` |
| `usePreferencesStore` | `preferencesStore.ts` | yes | locale, direction, themeMode, sidebarCollapsed |
| `useNotificationStore` | `notificationStore.ts` | no | toast queue (max 10) |
| `useTenantTimezoneStore` | `tenantTimezoneStore.ts` | no | IANA timezone for date formatting |

### Feature-Local
- `usePOSStore` — `features/pos/posStore.ts` (cart, session, offline sync; persisted).

### Patterns
- Hook naming: `use{Domain}Store`.
- Persist: `zustand/middleware` `persist` + `partialize` (auth strips roles/permissions from localStorage).
- Imperative in interceptors: `useAuthStore.getState()`, `useNotificationStore.getState()`.
- Server state stays in TanStack Query — do not mirror API data in Zustand.

## React Query

### Client (`lib/api/query-client.ts`)
- Defaults: `staleTime`/`gcTime` 5min, `retry: 1`, `refetchOnWindowFocus: false`.
- Global errors → `useNotificationStore.addNotification` via `QueryCache.onError` + `mutations.onError`.

### Query Keys (`lib/api/query-keys.ts`)
- Centralized factory: `queryKeys.<domain>.all | list(filters?) | detail(id)`.
- Auth: `queryKeys.auth.user`, `.passkeys`, `.sessions`, `.userPasskeys(userId)`, `.userSessions(userId)`.
- Always use factory — avoid ad-hoc strings (exception: `useMe` uses `["auth", "me"]`).

### Hook Organization
- Queries: `lib/api/queries/use{Domain}.ts` — `useMe`, `usePasskeys`, `useProducts`, `useFinance`.
- Mutations: `lib/api/mutations/use{Domain}.ts` — `useLogin`, `useCreateUser`, `useRegisterPasskey`.
- Barrels: `queries/index.ts`, `mutations/index.ts`.

### Mutation Pattern
```typescript
onSuccess: () => queryClient.invalidateQueries({ queryKey: queryKeys.users.all })
// Detail updates: invalidate both list + detail keys
```

## API Client (`lib/api/client.ts`)
- Axios; response interceptor unwraps to `response.data`.
- Request interceptor attaches: `Authorization`, `x-tenant-id`, `Accept-Language`, `Idempotency-Key` on POST.
- Token refresh queue (`refreshAccessToken`); module-level `freshAccessToken` bypasses stale Zustand hydration.
- Exported: `apiClient.get/post/put/patch/delete/postForm`.
- Paths: `config/constants.ts` → `API_PATHS`, `ROUTES`, `STORAGE_KEYS`.

## Forms (TanStack Form + Zod)

### Toolkit (`shared/form/`)
- `useAppForm`, `withForm` from `useAppForm.ts` (`createFormHook` from `@tanstack/react-form`).
- MUI field components: `TextField`, `NumberField`, `PasswordField`, `SelectField`, `AutocompleteField`, `DatePickerField`, `CheckboxField`, `SwitchField`, `SubmitButton`, etc.

### Usage Pattern
```tsx
const form = useAppForm({ defaultValues, onSubmit });
<form.AppForm>
  <form.TextField name="name" label="Name" fullWidth required />
  <form.SubmitButton label="Save" />
</form.AppForm>
```

### Schemas
- Zod in `features/*/schemas/` (e.g. `inventory/schemas/stockIssueFormSchema.ts`) or inline.
- Simple pages (login) may use local `useState`.

## MUI & Theme

### Theme (`lib/theme/`)
- `createAppTheme()` — light/dark palettes, RTL/LTR typography, MUI locale (`enUS`/`arSA`), `componentOverrides`.
- `app/providers/ThemeProvider.tsx` — reads `usePreferencesStore`, resolves system theme, recreates Emotion cache on direction flip.

### UI Patterns
- Page shell: `PageContainer` + `PageHeader` (`shared/components/ui/`).
- Dialogs: `*FormDialog.tsx`, `ResponsiveDialog`.
- Layouts: `AppLayout` (sidebar from `moduleNavigationRegistry`), `PublicLayout`.
- RBAC: `IfAllowed`, `RequireAuth` (`lib/rbac/components.tsx`).
- Notifications: `useNotification()` wrapper — not raw store in components.
- PWA: `PWAUpdatePrompt`, `PWAInstallPrompt`.

## i18n

### Core (`lib/i18n/config.ts`)
- i18next + react-i18next + browser-languagedetector.
- Languages: `en`, `ar`; lazy JSON bundles (`locales/en.json`, `locales/ar.json`).
- `defaultNS = "common"`; localStorage key `app_locale`.
- Typed keys: `lib/i18n/i18next.d.ts`.

### Hooks
- `useTranslation()` — primary everywhere.
- `useI18nFormat()` — `formatNumber`, `formatCurrency`, `formatDate`, `formatDateTime`, `formatRelativeTime`, `formatList` (uses preferences locale + tenant timezone + finance currency).
- `translationKey()` — bridges dynamic strings to typed `t()` keys.
- `getDirectionForLanguage()`, `languageConfig` — RTL for `ar`.

### URL ↔ Locale Sync
- URL is source of truth: `/:lang/...`.
- `langRoute.beforeLoad` in `app/router/layouts.tsx` syncs i18n + direction.
- `LocaleSwitcher` updates URL, preferences store, document `dir`/`lang`.

## Auth UI

### Routes
- Public: `/$lang/login`, `/$lang/login/$tenantId`, `/$lang/change-password`.
- Authenticated: `/$lang/app/account/security` → `AccountSecurityPage`.

### Login (`features/auth/pages/LoginPage.tsx`)
- Password: `useLogin()` → `upgradeRouterWithAppRoutes()` → dashboard or change-password.
- Passkey: `PasskeySignInButton` → `usePasskeyLogin()` (`@simplewebauthn/browser`).

### Account Security Panels
- `ChangePasswordPanel` → `useChangeOwnPassword()`.
- `PasskeyRegistrationPanel` → `usePasskeys()`, `useRegisterPasskey()`, `useDeletePasskey()`.
- `ActiveSessionsPanel` → `useMySessions()`, `useRevokeSession()`, `useLogoutAllDevices()`.
- Post-login nudge: `PasskeySetupPrompt` in `AppLayout`.

### Admin Variants
- `UserPasskeysPanel` — `useAdminPasskeys(userId)`, `useAdminDeletePasskey(userId)`.
- `UserSessionsPanel` — `useAdminSessions(userId)`, `useAdminRevokeSession(userId)`.
- Revoke current device: `useLogout()` + `downgradeRouterForPublicAccess()` + navigate to login.

## Feature Module Anatomy
```
features/{domain}/
  {domain}Routes.ts       # TanStack routes + optional {domain}ModuleNav
  pages/                  # *Page.tsx (lazy-loaded)
  components/
  schemas/                # Zod (optional)
  hooks/                  # feature hooks (e.g. pos/hooks/)
```

## Navigation Helpers
- `useAppNavigate()` — auto-injects `lang` param.
- `AppLink` — declarative lang-aware links.
- `appRedirect()` — for `beforeLoad` redirects.
- Each feature exports `{domain}ModuleNav: NavigationModule` with `labelKey`, `iconKey`, `permissions`, grouped `links`.

## Naming Reference
| Area | Convention | Example |
|------|------------|---------|
| Stores | `use{Domain}Store` | `useAuthStore` |
| Query hooks | `use{Entity}` | `useMe`, `usePasskeys` |
| Mutation hooks | `use{Action}{Entity}` | `useCreateUser`, `useRevokeSession` |
| Pages | `{Name}Page.tsx` | `LoginPage`, `StockReceiptsPage` |
| Dialogs | `{Entity}FormDialog.tsx` | `UserFormDialog` |
| Panels | `{Purpose}Panel.tsx` | `ActiveSessionsPanel` |
| i18n keys | dot-separated | `auth.passkeys.addPasskey` |
| Permissions | `action:resource` | `read:user` |

## Scaffolding
- `scripts/generate-feature.ts` — scaffolds feature pages/routes.
- Docs: `docs/ROUTING_AND_I18N.md`, `docs/rtl-i18n-theme-guide.md`.
