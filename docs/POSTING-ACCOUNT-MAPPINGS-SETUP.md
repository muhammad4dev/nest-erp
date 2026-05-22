# Posting Account Mappings — Setup Guide

**Audience:** Implementers, accountants, finance admins  
**Last updated:** May 22, 2026

This guide explains what **Posting Account Mappings** do in nest-erp, whether the feature is complete, which GL accounts you need, and how to configure them step by step.

Related:

- [Accounting & Inventory Phases](./ACCOUNTING-INVENTORY-PHASES.md) — end-to-end GL flows
- [Product Category Account Mappings](../frontend/docs/PRODUCT-CATEGORY-ACCOUNT-MAPPINGS.md) — per-category overrides
- UI: **Finance → Setup → Posting Account Mappings** (`/$lang/app/finance/config/posting-mappings`)

---

## Is it complete?

**Yes for the automated flows shipped in Phases 5–10** (sales invoices, AR payments, vendor bills, AP payments, perpetual inventory GL, GRNI, PPV on standard-cost receipts, AR/AP reconciliation, FX payment differences, month-end unrealized FX revaluation).

| Area | Status |
|------|--------|
| Tenant default mapping (no branch) | Done |
| Optional branch-specific override | Done (API + UI; branch entered as ID) |
| Sales invoice posting (AR, revenue, output VAT) | Done |
| Customer payments → bank/cash | Done |
| Vendor bill posting & vendor payments | Done |
| Stock receipt/issue GL (perpetual) | Done (needs inventory + COGS on mapping) |
| GRNI / purchases / input VAT / AP | Done (fields optional until you use procurement) |
| PPV (standard costing) | Done |
| Default VAT % on invoice/bill lines | Done |
| Realized / unrealized FX accounts | Done |
| Product category overrides (revenue, AR, VAT, COGS, inventory) | Done — **separate** config screen |
| Chart of accounts creation | Done — must exist **before** mapping |
| Delete posting mapping | **Not implemented** (create/update only) |
| Separate “AR bank” vs “AP bank” defaults | **Not implemented** — one `defaultPaymentAccountId` for both |
| Branch picker in UI | **Partial** — free-text branch UUID, not a dropdown |
| Account type validation (e.g. AR must be ASSET) | **Not implemented** |
| Sales discounts / credit notes / returns GL | **Not in posting mappings** |
| Payroll / commission default accounts | **Not in posting mappings** |
| Per-product VAT codes | **Not implemented** — tenant default % only |

Treat posting mappings as **production-ready for core OTC and PTP**, with the gaps above if you need advanced scenarios.

---

## How resolution works

1. If the document has a `branchId`, the system loads the mapping for that branch.
2. Otherwise (or if no branch mapping exists), it uses the **tenant default** mapping (`branchId` empty).
3. If neither exists → error: *“No posting account mapping found…”*

Service: `backend/src/modules/finance/utils/resolve-posting-mapping.ts`

**Product category mappings** override revenue, AR, output VAT, COGS, and inventory **per category** when present; otherwise posting mapping defaults apply.

---

## Suggested chart of accounts (English & Arabic)

Create these in **Finance → Chart of Accounts** first. Codes are examples (Egyptian-style numbering); adjust to your policy.

| Code | English name | Arabic name | Account type (`AccountType`) | Control? | Maps to posting field |
|------|--------------|-------------|------------------------------|----------|------------------------|
| 1010 | Cash on hand | نقدية بالصندوق | ASSET | No | `defaultPaymentAccountId` (optional) |
| 1020 | Bank — main EGP | بنك — حساب جاري رئيسي | ASSET | No | `defaultPaymentAccountId` (recommended) |
| 1100 | Accounts receivable | عملاء (ذمم مدينة) | ASSET | **Yes** | `defaultArAccountId` **(required)** |
| 1200 | Inventory — finished goods | مخزون بضاعة تامة | ASSET | No | `defaultInventoryAccountId` |
| 2100 | Accounts payable | موردون (ذمم دائنة) | LIABILITY | **Yes** | `defaultApAccountId` |
| 2150 | GRNI — goods received not invoiced | بضاعة مستلمة غير مفوترة | LIABILITY | No | `defaultGrniAccountId` |
| 2200 | Output VAT payable | ضريبة قيمة مضافة — مخرجات | LIABILITY | No | `defaultOutputVatAccountId` **(required)** |
| 2210 | Input VAT recoverable | ضريبة قيمة مضافة — مدخلات | ASSET | No | `defaultInputVatAccountId` |
| 4100 | Sales revenue | إيرادات المبيعات | INCOME | No | `defaultSalesRevenueAccountId` **(required)** |
| 5100 | Cost of goods sold | تكلفة البضاعة المباعة | EXPENSE | No | `defaultCogsAccountId` |
| 5200 | Purchases / inventory clearing | مشتريات / تسوية مخزون | EXPENSE | No | `defaultPurchasesAccountId` |
| 5300 | Purchase price variance | فرق سعر الشراء (معياري) | EXPENSE | No | `defaultPpvAccountId` |
| 7100 | Realized FX gain | أرباح فروق عملة محققة | INCOME | No | `defaultRealizedFxGainAccountId` |
| 7200 | Realized FX loss | خسائر فروق عملة محققة | EXPENSE | No | `defaultRealizedFxLossAccountId` |
| 7300 | Unrealized FX gain | أرباح فروق عملة غير محققة | INCOME | No | `defaultUnrealizedFxGainAccountId` |
| 7400 | Unrealized FX loss | خسائر فروق عملة غير محققة | EXPENSE | No | `defaultUnrealizedFxLossAccountId` |

**Minimum to post a sales invoice:** `1100`, `4100`, `2200`.

**Minimum for perpetual inventory (stock receipt/issue GL):** add `1200`, `5100`.

**Minimum for purchase-to-pay with GRNI:** add `2100`, `2150`, `5200`, `2210`, `1020`.

**Egypt VAT note:** Default rate on the mapping is **14%** (`defaultVatRatePercent`). Set to `0` if you are not charging VAT yet.

---

## Field reference (posting mapping)

| Field | Required when | Used for |
|-------|----------------|----------|
| `defaultArAccountId` | Always (create) | Invoice post, AR payments, AR GL recon, FX revaluation on AR |
| `defaultSalesRevenueAccountId` | Always (create) | Invoice revenue lines (unless category override) |
| `defaultOutputVatAccountId` | Always (create) | Output VAT on sales invoices |
| `defaultVatRatePercent` | Optional (default 14) | Auto VAT on invoice/bill lines from SO/PO |
| `defaultInventoryAccountId` | Perpetual inventory | Stock layers / inventory GL |
| `defaultCogsAccountId` | Perpetual inventory | COGS on stock issue |
| `defaultPurchasesAccountId` | Procurement / GRNI | Purchase clearing |
| `defaultApAccountId` | Vendor bills & payments | AP control |
| `defaultInputVatAccountId` | Vendor bills with VAT | Input VAT |
| `defaultGrniAccountId` | Receive-before-bill | GRNI accrual |
| `defaultPaymentAccountId` | AR & AP payments | Bank/cash (same account for both directions today) |
| `defaultPpvAccountId` | Standard costing receipts | Purchase price variance |
| `defaultRealizedFxGainAccountId` | FX customer/vendor payments | Payment rate ≠ document rate |
| `defaultRealizedFxLossAccountId` | FX payments | Same |
| `defaultUnrealizedFxGainAccountId` | Month-end revaluation | Finance → Currency → Run revaluation |
| `defaultUnrealizedFxLossAccountId` | Month-end revaluation | Same |
| `branchId` | Optional | Override tenant default for one branch |

---

## Setup steps

### 1. Chart of accounts

1. Go to **Finance → Chart of Accounts**.
2. Create accounts from the table above (or import your existing COA).
3. Mark **Accounts receivable** and **Accounts payable** as **control accounts** if your policy requires it (`isControlAccount`).

### 2. Fiscal periods

1. **Finance → Fiscal periods** — create an open period covering today’s date.
2. Payments and automated journals fail without an open period.

### 3. Currency (if multi-currency)

1. **Finance → Setup → Currency settings** — set functional currency (e.g. EGP).
2. **Exchange rates** — add rates for USD (or other document currencies).
3. On posting mapping, set **realized** and **unrealized** FX accounts before taking foreign-currency payments or running month-end revaluation.

### 4. Tenant default posting mapping

1. Open **Finance → Setup → Posting Account Mappings**.
2. Click **Create**.
3. Leave **Branch ID** empty → this is the **tenant default**.
4. Set required accounts:
   - Accounts receivable → `1100`
   - Sales revenue → `4100`
   - Output VAT → `2200`
5. Set **Default VAT rate (%)** (e.g. `14` for Egypt, `0` if exempt).
6. Add optional accounts for features you will use (inventory, AP, bank, PPV, FX).
7. Save.

You should have exactly **one** tenant-default row per tenant (no `branchId`).

### 5. Branch overrides (optional)

If you use branches and different banks or AR accounts:

1. Create another mapping with the **branch UUID** in Branch ID.
2. Repeat account selections for that branch.
3. Documents with that `branchId` use this row; others use tenant default.

### 6. Product category overrides (recommended)

1. **Finance → Setup → Product Category Account Mappings**.
2. For each category (e.g. Retail, Services), map revenue and optional AR, VAT, COGS, inventory.
3. Invoice and stock posting use category accounts when defined; otherwise posting mapping defaults apply.

### 7. Inventory settings

1. **Inventory → Settings** — set method to **PERPETUAL** if you want automatic stock journals.
2. Ensure **inventory** and **COGS** are set on posting mapping (or per category).

### 8. Verify

| Test | Expect |
|------|--------|
| Post sales invoice | Journal: Dr AR, Cr Revenue, Cr Output VAT |
| Record customer payment | Dr Bank, Cr AR |
| Complete stock receipt (perpetual) | Dr Inventory, Cr GRNI/purchases (per flow) |
| Post vendor bill | Dr Purchases/GRNI, Dr Input VAT, Cr AP |
| Pay vendor bill | Dr AP, Cr Bank |
| AR/AP GL reconciliation | Difference near zero after posting |

API (same data as UI):

```http
GET  /finance/config/posting-account-mappings
POST /finance/config/posting-account-mappings
PUT  /finance/config/posting-account-mappings/:id
```

---

## Troubleshooting

| Message | Fix |
|---------|-----|
| No posting account mapping found | Create tenant default mapping (step 4). |
| Inventory and COGS accounts must be configured | Set `defaultInventoryAccountId` and `defaultCogsAccountId` for perpetual inventory. |
| Configure PPV account | Set `defaultPpvAccountId` when using STANDARD costing on receipts. |
| Payment account not configured | Set `defaultPaymentAccountId` before AR/AP payments. |
| Unrealized FX accounts required | Set unrealized gain/loss before month-end revaluation. |

---

## What to configure together

| Configuration | Purpose |
|---------------|---------|
| Posting account mappings | Tenant/branch **defaults** for all automated journals |
| Product category account mappings | **Overrides** by product category |
| Payment terms | Due dates on invoices (not GL accounts) |
| Currency settings & exchange rates | FX amounts and revaluation |

---

## Related code

| Path | Role |
|------|------|
| `backend/src/modules/finance/entities/posting-account-mapping.entity.ts` | Schema |
| `backend/src/modules/finance/finance.service.ts` | CRUD + validation |
| `frontend/src/features/finance-config/pages/PostingAccountMappingsConfigPage.tsx` | Admin UI |
