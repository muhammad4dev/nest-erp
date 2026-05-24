# Payroll, attendance, and timesheets

## Overview

Payroll combines:

- Contract **basic wage** (monthly or hourly)
- **Attendance** (HR daily grid) for pro-rated monthly pay
- **Timesheets** (employee self-service + HR approval) for hours and overtime
- **Sales commissions**
- Manual **additions / deductions**
- **Scheduled pay date** and **hold / release** before GL posting

**Net pay** is posted to the general ledger on finalize (not gross salary alone).

## Attendance (HR only)

Path: **HRMS → Attendance**

- Select a period and set status per employee per day: `PRESENT`, `ABSENT`, `LEAVE_PAID`, `LEAVE_UNPAID`, `LATE`
- Missing rows on working days count as present
- Monthly contracts: `adjusted basic = wage × (paid days / working days)`

## Timesheets (employees + HR)

### Employee self-service

Path: **HRMS → My timesheet** (requires linked user on employee record)

1. HR links a **user account** on the employee form (`userId`)
2. Employee enters clock in/out per day and **submits**
3. HR approves or rejects on **Timesheets**

Only **APPROVED** timesheet hours affect payroll.

### HR review

Path: **HRMS → Timesheets** — filter by status `SUBMITTED`, approve or reject.

## Payroll run

1. Enter attendance for the period (if using monthly pro-ration)
2. Ensure timesheets are approved
3. **HRMS → Payroll** — select period → **Calculate**
4. Open **View** on a row: adjustments, scheduled pay date, hold/release
5. **Approve** then **Finalize** (blocked if on hold or pay date in future)

## Permissions

| Permission | Use |
|------------|-----|
| `manage:attendance` | Attendance grid, approve timesheets |
| `manage:payroll` | Adjustments, schedule, hold/release |
| `read:own_timesheet` | View my timesheet |
| `submit:own_timesheet` | Edit and submit own timesheet |

## HR settings

**HRMS → HR settings** (`/app/hrms/settings`) — working days (0=Sun…6=Sat), default hours/day, overtime multiplier, default pay day of month. Requires `manage:payroll`.

## Contract pay type

On **employee contracts** (create or edit): **Monthly salary** (attendance pro-ration) or **Hourly** (approved timesheet hours). Set **standard hours per day** for overtime and hourly rate derivation.

## API summary

| Method | Path |
|--------|------|
| PUT | `/hrms/attendance` |
| GET/PUT | `/hrms/timesheets`, `/hrms/timesheets/me` |
| POST | `/hrms/timesheets/me/:id/submit` |
| PATCH | `/hrms/timesheets/:id/approve`, `/reject` |
| POST | `/payroll/periods/:start/:end/calculate` |
| PATCH | `/payroll/:id/hold`, `/release`, `/schedule` |
| POST | `/payroll/:id/adjustments` |

Migration: `1772400000000000-dynamic-payroll-attendance.ts`
