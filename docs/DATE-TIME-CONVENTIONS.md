# Date and time conventions

This ERP uses **three** distinct kinds of date/time data. Do not mix them.

## Tenant timezone

Each tenant has an **IANA timezone** (e.g. `Africa/Cairo`) stored on `tenant_finance_settings.timezone`.

| Layer | Behavior |
|-------|----------|
| Setup | Finance → Currency settings → Organization timezone |
| API | `GET /tenant/preferences` → `{ timezone }` (any authenticated user) |
| Backend | `TenantContext.getTimezone()`; `todayCalendarDate()` uses tenant zone |
| Frontend | `useTenantTimezoneStore`; loaded on login via `TenantTimezoneSync` |

All users in a tenant see the same “today”, due dates, and formatted timestamps regardless of their browser timezone.

## 1. Calendar dates (business days)

**Format:** `YYYY-MM-DD` (ISO 8601 date only, no time, no `Z`)

**Use for:** hire date, contract dates, invoice/payment dates, fiscal periods, payroll periods, attendance days, scheduled pay date, report filters.

| Layer | Rule |
|-------|------|
| PostgreSQL | `date` column |
| API JSON | `"2025-05-24"` |
| Validation | `@IsDateString()` (Nest) |
| Frontend forms | string on `DatePickerField` / hidden inputs |

### Frontend helpers (`frontend/src/lib/utils/dateUtils.ts`)

| Function | Purpose |
|----------|---------|
| `todayCalendarDate()` | Today in the **tenant** timezone |
| `formatIsoCalendarDate(date)` | `Date` → ASCII `YYYY-MM-DD` (tenant zone, always `en-CA` — not localized) |
| `parseIsoCalendarDate(value)` | `YYYY-MM-DD` → local `Date` (no UTC shift) |
| `toCalendarDateString(value)` | Normalize `Date` or string to `YYYY-MM-DD` |
| `coerceToCalendarDateString(value)` | Nullable DB/API values |
| `eachCalendarDateInRange(start, end)` | Inclusive date list (UTC noon anchor) |

**Display:** `formatDisplayDate` / `formatToLocaleDateString` in `formatDisplayDate.ts` (locale-aware).

**Avoid:**

```ts
new Date("2025-05-24");              // UTC midnight → wrong day in many zones
new Date().toISOString().split("T")[0]; // “today” in UTC, not local
```

## 2. Instants (timestamps)

**Format:** ISO 8601 UTC, e.g. `2025-05-24T14:30:00.000Z`

**Use for:** `createdAt`, `finalizedAt`, audit fields, webhook payloads, POS sync time.

| Layer | Rule |
|-------|------|
| PostgreSQL | `timestamptz` |
| API JSON | full ISO with `Z` or offset |

**Display:** `formatDisplayDateTime` / `formatToLocaleString`.

## 3. Time of day (no date)

**Format:** `HH:mm` or `HH:mm:ss` (24-hour), e.g. `"09:00"`

**Use for:** timesheet `clockIn` / `clockOut` (date is separate `entryDate` as calendar date).

| Layer | Rule |
|-------|------|
| PostgreSQL | `time` |

---

## Backend helpers

`backend/src/common/utils/calendar-date.util.ts`:

- `todayCalendarDate()` — today in tenant timezone (`TenantContext`)
- `formatCalendarDateLocal(date)` / `formatCalendarDateUtc(date)`
- `toCalendarDateString(value)` / `coerceToCalendarDateString(value)`
- `formatCalendarDateInTimeZone` in `timezone.util.ts` — always **`en-CA`** for API/DB (never `ar-EG` or other localized digit formats)

Payroll date ranges use **UTC noon** (`T12:00:00Z`) when iterating `YYYY-MM-DD` strings so each civil day is counted once (`payroll-calendar.util.ts`).

---

## Date pickers

`DatePickerInput` / `form.DatePickerField` store **`YYYY-MM-DD`** using `parseIsoCalendarDate` / `formatIsoCalendarDate`.

Native HTML forms must sync dates via hidden inputs or read from React state (see employee contract create form).

---

## Future: tenant timezone

There is no tenant timezone setting yet. “Today” uses **browser local** (frontend) and **server local** (backend). When adding tenant TZ, centralize in `todayCalendarDate()` on both sides.
