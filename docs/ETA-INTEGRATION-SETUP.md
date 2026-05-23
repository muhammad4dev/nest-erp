# ETA eInvoice & eReceipt Integration Setup

This guide covers configuring the Egyptian Tax Authority (ETA) integration for **eInvoice** (posted sales invoices) and **eReceipt** (POS sales orders).

Official reference: [ETA Invoicing SDK](https://sdk.invoicing.eta.gov.eg/)

## Prerequisites

1. Register your company on the ETA **pre-production** portal and obtain OAuth2 client credentials.
2. Export a **PKCS#12** (`.p12` / `.pfx`) signing certificate from the ETA toolkit or your CA process.
3. Ensure master data is ready:
   - Products: `taxCode` (ETA item code)
   - Units of measure: `etaCode`
   - Partners (customers): `taxId` and structured `address` for B2B invoices

## Server environment

Add to `backend/.env`:

```env
ETA_ENCRYPTION_KEY=your-secret-at-least-32-characters-long
```

Optional default environment label (tenant settings override per tenant):

```env
# ETA_ENV=preprod
```

`ETA_ENCRYPTION_KEY` encrypts tenant client secrets and PKCS#12 certificates at rest. Never commit production keys to source control.

## Tenant configuration (UI)

Navigate to **Compliance → ETA Settings** (requires `manage:eta_settings`).

| Field | Purpose |
|-------|---------|
| Environment | `preprod` or `prod` API base URLs |
| Client ID / secret | OAuth2 client credentials from ETA |
| Issuer tax ID, name, activity code, address | Your company as document issuer |
| POS device serial / OS version | eReceipt metadata for POS orders |
| Auto-submit invoice | Submit eInvoice after posting (errors do not roll back GL) |
| Auto-submit POS receipt | Submit eReceipt after successful POS sync |
| Certificate upload | PKCS#12 file + passphrase |

## API overview

| Method | Path | Description |
|--------|------|-------------|
| GET | `/compliance/settings` | Non-secret tenant ETA settings |
| PUT | `/compliance/settings` | Update settings |
| POST | `/compliance/settings/certificate` | Upload PKCS#12 (`multipart/form-data`) |
| GET | `/compliance/einvoices` | List submissions |
| POST | `/compliance/einvoices` | Create DRAFT eInvoice for an invoice |
| POST | `/compliance/einvoices/:id/submit` | Sign and submit |
| POST | `/compliance/einvoices/:id/sync-status` | Poll ETA status |
| GET | `/compliance/einvoice/preview/:invoiceId` | Canonical JSON preview |
| POST | `/compliance/einvoice/:invoiceId/submit` | Submit invoice directly |
| GET | `/compliance/ereceipt/preview/:orderId` | eReceipt preview |
| POST | `/compliance/ereceipt/:orderId/submit` | Submit POS receipt |

Permissions:

- `read:compliance_report` — list/read submissions and previews
- `manage:eta_settings` — settings and certificate
- `submit:eta_document` — submit and sync status

## Test flow (preprod)

1. Run migrations: `pnpm --filter backend migration:run`
2. Configure ETA settings and upload certificate.
3. Post a sales invoice with valid product/partner data.
4. Open **Compliance → E-Invoices** or the invoice detail page → **Submit to ETA**.
5. Use **Refresh ETA status** after submission when `etaUuid` is present.
6. For POS: enable auto-submit or call submit after sync; check sync result / app bar for eReceipt UUID.

## Troubleshooting

| Symptom | Check |
|---------|--------|
| `ETA settings incomplete` | Client ID, secret, certificate, issuer fields |
| `ETA_ENCRYPTION_KEY must be set` | Server `.env` |
| Submission `FAILED` | `lastError` on submission row; ETA preprod credentials |
| Rejected document | `rejectionReason` JSON from ETA; validate tax codes and addresses |
| Signing errors | Certificate passphrase and PKCS#12 format |

## Security notes

- Secrets and certificates are encrypted with AES-256-GCM using `ETA_ENCRYPTION_KEY`.
- GET settings never returns client secret or certificate bytes.
- Canonical/signed payloads are not logged at info level in production code paths.
