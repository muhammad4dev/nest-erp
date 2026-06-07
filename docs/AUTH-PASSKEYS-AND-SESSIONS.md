# Authentication — Passkeys & Session Management

Guide for **end users**, **administrators**, and **developers** covering password login, passkeys (WebAuthn), active session visibility, and deployment behind reverse proxies / Cloudflare Tunnel.

**Last updated:** June 7, 2026

**Related:** [End user manual](./END-USER-MANUAL.md) · [RBAC & permissions](./RBAC-AND-PERMISSIONS.md) · [Backend operations](../backend/docs/operations.md)

---

## Overview

| Feature | Description |
| ------- | ----------- |
| **Password login** | Email + password + tenant ID (unchanged). Required for new users; used for account recovery. |
| **Passkey login** | Optional WebAuthn sign-in (Touch ID, Windows Hello, security keys, synced passkeys). Works **alongside** password. |
| **Active sessions** | Each login creates a session (refresh token) with device, IP, sign-in method, and expiry. |
| **Self-service** | **Account Security** page — register/revoke passkeys, view/revoke sessions. |
| **Admin** | **User profile** — view/revoke a user's passkeys and sessions (`read:user` / `update:user`). |

---

## End users

### Signing in with a password

1. Open the ERP URL.
2. Enter **Tenant ID**, **email**, and **password**.
3. Click **Sign In**.

### Signing in with a passkey

1. Enter **Tenant ID** and **email** (same as password login).
2. Click **Sign in with passkey**.
3. Complete the browser or device prompt (biometric, PIN, or security key).

If you have no passkey registered, use your password and register one under **Account Security**.

### Account Security

**Menu:** Top bar → **Account Security** (desktop and mobile user menu)

**Route:** `/{lang}/app/account/security`

#### Passkeys

- View registered passkeys (device name, registered date, last used).
- **Add passkey** — optional device name, then follow the browser ceremony.
- **Remove** a passkey you no longer use.

Password login remains available after adding passkeys.

#### Active sessions

Each row shows:

| Field | Meaning |
| ----- | ------- |
| **Device** | Browser and OS parsed from the user agent (e.g. Chrome on macOS). |
| **IP address** | Client IP at login time. |
| **Sign-in method** | Password or Passkey. |
| **Signed in / Expires** | Session created and expiry (30-day refresh token lifetime). |
| **This device** | Badge on your current session. |

Actions:

- **Revoke session** — signs out that device. If you revoke the current session, you are logged out here too.
- **Sign out all devices** — revokes every active session and logs you out everywhere.

---

## Administrators

### User profile — passkeys and sessions

**Menu:** Users → open a user → scroll to **Passkeys** and **Active sessions**

Requires:

| Action | Permission |
| ------ | ---------- |
| View passkeys / sessions | `read:user` |
| Revoke passkey or session | `update:user` |

Use this when offboarding a user, responding to a lost device, or auditing access.

---

## API reference (developers)

Base path: `/api/v1`. All routes require **`x-tenant-id`** except where noted.

### Password auth (existing)

| Method | Path | Auth | Notes |
| ------ | ---- | ---- | ----- |
| POST | `/auth/login` | Public | `{ email, password }` → tokens |
| POST | `/auth/refresh` | Public | Rotate refresh token |
| POST | `/auth/logout` | Public | Revoke one refresh token |
| POST | `/auth/logout-all` | JWT | Revoke all sessions for current user |
| GET | `/auth/me` | JWT | Current user + roles |

### Passkeys

| Method | Path | Auth | Notes |
| ------ | ---- | ---- | ----- |
| POST | `/auth/passkeys/register/options` | JWT | Registration challenge |
| POST | `/auth/passkeys/register/verify` | JWT | Store credential; body `{ response, deviceName? }` |
| POST | `/auth/passkeys/login/options` | Public | `{ email }` → authentication challenge |
| POST | `/auth/passkeys/login/verify` | Public | `{ response }` → tokens |
| GET | `/auth/passkeys` | JWT | List own passkeys |
| DELETE | `/auth/passkeys/:credentialId` | JWT | Remove own passkey |
| GET | `/users/:userId/passkeys` | JWT + `read:user` | Admin list |
| DELETE | `/users/:userId/passkeys/:credentialId` | JWT + `update:user` | Admin revoke |

### Sessions

Sessions are active rows in `refresh_tokens` (`is_revoked = false`, not expired).

| Method | Path | Auth | Notes |
| ------ | ---- | ---- | ----- |
| GET | `/auth/sessions` | JWT | Optional header `X-Refresh-Token` marks `isCurrent` |
| DELETE | `/auth/sessions/:sessionId` | JWT | Revoke own session; returns `{ revoked, revokedCurrent }` |
| GET | `/users/:userId/sessions` | JWT + `read:user` | Admin list |
| DELETE | `/users/:userId/sessions/:sessionId` | JWT + `update:user` | Admin revoke |

### Database

| Table / column | Purpose |
| -------------- | ------- |
| `user_passkeys` | WebAuthn credentials per user/tenant |
| `webauthn_challenges` | Short-lived ceremony state (~5 min) |
| `refresh_tokens.auth_method` | `password` or `passkey` |

Migration: `1780300000000-passkeys-and-session-auth-method.ts`

Run: `cd backend && pnpm migration:run`

---

## Environment variables

### Backend (`.env`)

```env
# JWT (required in production)
JWT_SECRET=your-strong-secret

# Trust proxy headers (default: enabled) — required for correct client IPs
# behind Vite dev proxy, nginx, or Cloudflare Tunnel
TRUST_PROXY=1

# WebAuthn / Passkeys (required in production)
WEBAUTHN_RP_ID=erp.example.com
WEBAUTHN_RP_NAME=Nest ERP
WEBAUTHN_ORIGIN=https://erp.example.com
```

| Variable | Notes |
| -------- | ----- |
| `TRUST_PROXY` | Set to `0` or `false` only if the API is reached directly with no proxy. Default: `1`. |
| `WEBAUTHN_RP_ID` | Hostname only — no scheme or port. Must match the browser URL hostname. |
| `WEBAUTHN_ORIGIN` | Full origin with scheme (and port in dev). Must match the page origin exactly. |
| `APP_PUBLIC_URL` | Fallback for `WEBAUTHN_ORIGIN` if unset. |

Dev defaults (when unset): `RP_ID=localhost`, `ORIGIN=http://localhost:5173`.

### Frontend

Passkeys require a **secure context**: HTTPS in production, or `localhost` in development.

```env
VITE_API_URL=/api/v1
```

When using the Vite dev server, `/api` is proxied to the backend with `xfwd: true` so forwarded headers are sent.

---

## Deployment — Cloudflare Tunnel

Typical flow:

```
Browser → Cloudflare → cloudflared → localhost:3000 (API)
```

`cloudflared` connects to the origin on **127.0.0.1**. Without reading forwarded headers, every session IP would show as localhost.

The backend resolves client IP in this order:

1. **`CF-Connecting-IP`** (Cloudflare Tunnel / proxy)
2. **`True-Client-IP`** (Cloudflare Enterprise)
3. **`X-Forwarded-For`** (first hop)
4. **`X-Real-IP`**
5. `req.ip` / socket address

**Requirements:**

- Keep **`TRUST_PROXY=1`** (default).
- Expose the API **only through the tunnel** (or another trusted proxy) so `CF-Connecting-IP` cannot be spoofed by clients.
- Set WebAuthn variables to your **public tunnel hostname**:

```env
WEBAUTHN_RP_ID=erp.yourdomain.com
WEBAUTHN_ORIGIN=https://erp.yourdomain.com
```

- Restart the backend after changing env vars.
- **Sign in again** to create new sessions with correct IPs (existing rows keep stored values; display is normalized on read).

### IP display notes

| Environment | Typical IP shown |
| ----------- | ---------------- |
| Same-machine dev (`localhost:5173`) | `127.0.0.1` |
| LAN device hitting dev server | Device LAN IP (with Vite `xfwd`) |
| Cloudflare Tunnel | Visitor public IP from `CF-Connecting-IP` |

IPv4-mapped IPv6 addresses (e.g. `::ffff:127.0.0.1`) are normalized to plain IPv4 in API responses.

### Passkeys and Bitwarden

Passkeys are **scoped to the Relying Party ID (your hostname)**:

| Registered on | Works on |
| ------------- | -------- |
| `localhost` | `localhost` only |
| `nest-erp.example.com` | that hostname only |

A passkey saved in Bitwarden for localhost **cannot** sign in on production, even if the server still lists an old credential in the database.

**Production setup checklist:**

1. `WEBAUTHN_RP_ID` = hostname only (e.g. `nest-erp.muhammad.fr.eu.org`) — no `https://`, no path, no trailing space.
2. `WEBAUTHN_ORIGIN` = full page origin (e.g. `https://nest-erp.muhammad.fr.eu.org`) — must match the browser address bar exactly.
3. On production, open **Account Security** → delete any passkeys registered during local dev → **Add passkey** again.
4. When the browser shows the passkey picker, choose **Bitwarden** (or “Security key”) — not only “This device” / Windows Hello, unless you want a device-bound key.

**Device names:** On registration, the server reads the authenticator **AAGUID** (when available) to label passkeys as `Bitwarden`, `1Password`, `Windows Hello`, `iCloud Keychain`, etc. Users can optionally override with a custom name in Account Security.

Bitwarden is a **cross-platform** authenticator. Login options must not restrict `allowCredentials` to `internal`/`hybrid` transports only, or Bitwarden will be hidden.

---

## Frontend implementation map

| Path | Purpose |
| ---- | ------- |
| `frontend/src/features/auth/pages/LoginPage.tsx` | Password + passkey sign-in |
| `frontend/src/features/auth/pages/AccountSecurityPage.tsx` | Passkeys + sessions self-service |
| `frontend/src/features/auth/components/PasskeySignInButton.tsx` | Login ceremony |
| `frontend/src/features/auth/components/PasskeyRegistrationPanel.tsx` | Register/list/delete passkeys |
| `frontend/src/features/auth/components/ActiveSessionsPanel.tsx` | Session list/revoke |
| `frontend/src/features/users/components/UserPasskeysPanel.tsx` | Admin passkeys |
| `frontend/src/features/users/components/UserSessionsPanel.tsx` | Admin sessions |
| `frontend/src/lib/api/mutations/usePasskeys.ts` | Passkey mutations |
| `frontend/src/lib/api/queries/usePasskeys.ts` | Passkey queries |
| `frontend/src/lib/api/queries/useSessions.ts` | Session queries/mutations |
| `frontend/src/lib/auth/webauthn.ts` | Browser support check |

---

## Backend implementation map

| Path | Purpose |
| ---- | ------- |
| `backend/src/auth/passkey.service.ts` | WebAuthn ceremonies |
| `backend/src/auth/session.service.ts` | Session list/revoke |
| `backend/src/auth/passkey.controller.ts` | Passkey HTTP routes |
| `backend/src/auth/user-security.controller.ts` | Admin passkey/session routes |
| `backend/src/auth/auth.controller.ts` | Session routes on `/auth/sessions` |
| `backend/src/common/utils/client-ip.util.ts` | IP extraction (Cloudflare-aware) |
| `backend/src/auth/config/webauthn.config.ts` | RP ID / origin config |

---

## Troubleshooting

| Problem | Check |
| ------- | ----- |
| Passkey works on localhost but not production | Passkeys are **per domain** (`RP ID`). Delete localhost passkeys, re-register on prod. Pick **Bitwarden** in the browser dialog, not only "this device". |
| Bitwarden not offered at login | Re-register on production; ensure `WEBAUTHN_RP_ID` matches browser hostname exactly; omit old localhost credentials from Account Security |
| Passkey registration fails | HTTPS (or localhost), `WEBAUTHN_ORIGIN` must match `window.location.origin` exactly (no trailing slash) |
| Passkey login says no passkeys | Register on Account Security first; same email + tenant |
| All sessions show `127.0.0.1` | `TRUST_PROXY=1`; tunnel/proxy forwards headers; sign in again after fix |
| `::ffff:127.0.0.1` in UI | Should display as `127.0.0.1` after normalization; new logins store clean IPs |
| Admin cannot see sessions | User needs `read:user`; revoke needs `update:user` |
| Session list missing current badge | Frontend sends `X-Refresh-Token` on `GET /auth/sessions` |

---

## Security notes

- Refresh token **hashes** are stored; raw tokens are never returned in session APIs.
- Passkeys do not replace password for new accounts in the current release — passwords remain for recovery.
- Revoking a passkey does not revoke existing sessions; revoke sessions separately if needed.
- Token refresh **rotates** refresh tokens (old row revoked, new row created); session list shows only active rows.
