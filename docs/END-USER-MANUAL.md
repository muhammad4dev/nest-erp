# Nest ERP — End User Manual

A practical guide to every major feature in the web application. This manual is written for **business users** (sales, warehouse, accounting, HR, administrators)—not developers.

**Last updated:** May 15, 2026  
**Related:** [Documentation index](./README.md) · [Accounting features (technical)](./ACCOUNTING-INVENTORY-PHASES.md)

---

## Table of contents

1. [Getting started](#1-getting-started)
2. [Navigation and layout](#2-navigation-and-layout)
3. [Your access (roles and permissions)](#3-your-access-roles-and-permissions)
4. [Home dashboard](#4-home-dashboard)
5. [Partners (customers and vendors)](#5-partners-customers-and-vendors)
6. [Products and catalog](#6-products-and-catalog)
7. [Inventory and warehouse](#7-inventory-and-warehouse)
8. [Sales](#8-sales)
9. [Procurement (purchasing)](#9-procurement-purchasing)
10. [Finance and accounting](#10-finance-and-accounting)
11. [HRMS (human resources)](#11-hrms-human-resources)
12. [Point of sale (POS)](#12-point-of-sale-pos)
13. [Compliance (e-invoices)](#13-compliance-e-invoices)
14. [Notifications](#14-notifications)
15. [Administration](#15-administration)
16. [Translations](#16-translations)
17. [End-to-end workflows](#17-end-to-end-workflows)
18. [Status reference](#18-status-reference)
19. [Frequently asked questions](#19-frequently-asked-questions)

---

## 1. Getting started

### Signing in

1. Open the ERP URL provided by your organization.
2. Enter your **email** and **password**.
3. After login you land on the **Dashboard** (home).

If you cannot log in, contact your administrator to verify your account and tenant.

### Language and display

| Control | Where | What it does |
| ------- | ----- | ------------ |
| **Language** | Top bar (globe icon) | Switch between English and Arabic (and other configured locales). Layout flips automatically for right-to-left languages. |
| **Theme** | Top bar (sun/moon icon) | Light, dark, or follow system appearance. |
| **Sidebar** | Arrow on the side panel | Collapse or expand the main menu. |

Your choices are remembered on this device.

### Notification bell

The **bell icon** in the top bar opens your **Notification Center**:

- See recent alerts (e.g. low stock).
- Mark one or all as read.
- Clear old history.

To change which alerts you receive, use **Preferences** inside the notification menu (when available) or ask an admin about notification rules.

---

## 2. Navigation and layout

### Main menu (sidebar)

Modules appear based on **your permissions**. If you do not see Sales, Finance, or Inventory, your role may not include that area—contact an administrator.

Typical groups:

| Section | Modules |
| ------- | ------- |
| **Commerce** | Sales, Point of Sale |
| **Operations** | Products, Inventory, Procurement, Partners, Finance, HRMS |
| **Admin** | Users, Roles |
| **Platform** | Compliance, Translations, Notifications (admin) |

### Module home pages

Most modules open a **hub page** with cards (e.g. Sales → Quotations, Orders, Invoices). Click a card to open that feature.

### Lists and detail pages

- **List pages** show tables with search, filters, and pagination.
- Click a **row** or **document number** to open the **detail page**.
- Detail pages show status, lines, totals, and **action buttons** (Post, Pay, Confirm, etc.) when your role allows and the document is in the right status.

### Going back

Use the browser back button or the **back arrow** on detail screens to return to lists.

---

## 3. Your access (roles and permissions)

### Why is a button missing?

Action buttons (e.g. **Record payment**, **Post invoice**, **Receive goods**) only appear when **both** are true:

1. You have the required **permission** (assigned through your role).
2. The document is in the correct **status** (e.g. you cannot pay a draft invoice).

The system still blocks unauthorized actions on the server if someone tries anyway.

### Common permissions (what to ask your admin for)

| If you need to… | Typical permission |
| --------------- | ------------------ |
| Create sales orders / quotes | `create:sales_order` |
| Confirm orders, send quotes | `update:sales_order` |
| Create and post invoices | `create:invoice`, `post:invoice` |
| Record customer payments | `pay:invoice` |
| Receive purchase orders | `confirm:purchase_order` |
| Post and pay vendor bills | `post:vendor_bill`, `pay:vendor_bill` |
| Complete stock receipts | `update:stock` |
| Manage chart of accounts / mappings | `read:account`, `update:account` |
| Manage users and roles | Admin role |

Administrators configure roles under **Roles** (admin menu).

---

## 4. Home dashboard

**Menu:** Dashboard (home icon) — first item after login.

The dashboard summarizes activity across modules, for example:

- Open sales orders and invoices
- Purchase orders and vendor bills
- Draft vs completed stock documents (receipts, issues, transfers, adjustments)
- HR headcount and payroll period summary (if you have HR access)

**Quick actions** on the dashboard jump to common lists (orders, invoices, inventory documents).

Use the dashboard for a daily snapshot; drill into modules for work.

---

## 5. Partners (customers and vendors)

**Menu:** Partners

Partners are **customers**, **vendors**, or both. They are used on sales orders, invoices, purchase orders, and bills.

### Partner list

1. Open **Partners** → **Partner list**.
2. Search and open a partner to view or edit.

### Create a partner

1. Click **New** (or **Add partner**).
2. Fill in name, type (customer/vendor), contact details, tax ID, addresses, payment terms if applicable.
3. Save.

### Tips

- Set **payment terms** and **credit** information before heavy sales use.
- One partner record can be linked to many orders and invoices.

---

## 6. Products and catalog

**Menu:** Products

### Product list

View all products, search, and open a product to see details, variants, and stock summary.

### Create or edit a product

1. **Products** → **Product list** → **New**.
2. Enter SKU, name, category, unit of measure, sale price, etc.
3. Add **variants** if the product has sizes/colors (attributes).
4. Save.

### Categories

**Products** → **Categories** — organize products in a tree. Categories can drive **account mapping** for revenue, COGS, and inventory (finance setup).

### Attributes

**Products** → **Attributes** — define variant options (e.g. Size: S, M, L).

### Stock levels (product module)

**Products** → **Stock** — quick view of quantities by product and location (read-only overview; movements are done under **Inventory**).

---

## 7. Inventory and warehouse

**Menu:** Inventory

The inventory hub shows **KPI cards** (draft vs completed counts) and links to all warehouse tools.

### 7.1 Stock receipts (goods in)

**Use when:** Goods arrive (purchase, return, opening balance, etc.)

1. **Inventory** → **Stock receipts**.
2. Open a receipt or create one (depending on your process—some receipts are created from **purchase order receive**).
3. While status is **Draft**: add lines (product, location, quantity, unit cost if required).
4. Click **Edit** to change lines; click **Complete** when physically received.

Completing a receipt **updates stock** and may post **inventory GL** entries (if enabled in settings).

### 7.2 Stock issues (goods out)

**Use when:** Goods leave the warehouse (sales fulfillment, consumption, etc.)

1. **Inventory** → **Stock issues**.
2. Create or open a draft issue; add lines.
3. Complete the issue when goods are picked/shipped.

Issues reduce on-hand quantity and may post COGS/inventory accounting on invoice or issue, per tenant settings.

### 7.3 Stock transfers

Move stock **between locations** within your organization.

1. **Inventory** → **Stock transfers**.
2. Create transfer: from location, to location, lines, quantities.
3. Complete when goods are physically moved.

### 7.4 Stock adjustments

Correct quantities after a count or for write-offs.

1. **Inventory** → **Stock adjustments**.
2. Enter adjustment lines (positive or negative quantities).
3. Complete to apply.

### 7.5 Inventory settings

**Inventory** → **Settings**

| Setting | Meaning |
| ------- | ------- |
| Inventory method | **Perpetual** (update stock on each transaction) vs periodic |
| Default costing method | FIFO, LIFO, **Average**, or **Standard** for new products |
| Post COGS on invoice post | When enabled, posting a sales invoice can book COGS |
| Post inventory on receipt | When enabled, completing receipts posts inventory asset to GL |

Save after changes. Coordinate with accounting before changing costing method.

### 7.6 Inventory reports

**Inventory** → **Reports**

| Tab / report | Purpose |
| ------------ | ------- |
| **Valuation** | Stock on hand and value by product/location; edit **standard cost** or costing method per row (with permission) |
| **Movement ledger** | Detailed in/out movements with filters |
| **COGS by period** | Cost of goods sold over a date range |
| **COGS by category** | COGS grouped by product category |
| **GL reconciliation (inventory / COGS)** | Compare system totals to general ledger (for accountants) |

### 7.7 Stocktakes

**Inventory** → **Stocktakes** — plan and record physical counts, then reconcile variances (often via adjustments).

### 7.8 Inventory period close

**Inventory** → **Period close** — month-end inventory closing and opening snapshots (finance-controlled process).

---

## 8. Sales

**Menu:** Sales

### 8.1 Quotations (price offers)

1. **Sales** → **Quotations**.
2. **New quotation** — select customer, add lines, prices, validity date.
3. While **Draft**: edit freely.
4. **Send quote** — marks quote as sent to customer (status workflow).

### 8.2 Sales orders

1. **Sales** → **Sales orders** → **New order** (if allowed).
2. Add customer, lines, warehouse/location if required.
3. Actions on the order detail page (depend on status and permission):

| Action | Typical status | Result |
| ------ | -------------- | ------ |
| **Edit** | Draft | Change lines |
| **Send quote** | Draft | Send to customer |
| **Confirm** | Draft / Sent | Confirms order for fulfillment |
| **Cancel** | Not cancelled/invoiced | Cancels order |
| **Create invoice** | Confirmed | Creates sales invoice |
| **Download PDF** | Most statuses | PDF of order |

Optional: **Auto issue inventory** when creating invoice (issues stock from order).

### 8.3 Invoices

1. **Sales** → **Invoices** — list of all customer invoices.
2. Open an invoice to view lines, tax, totals, payments.

| Action | When available | Result |
| ------ | -------------- | ------ |
| **Post invoice** | Draft | Books revenue and AR (and COGS if configured); status becomes **Sent** |
| **Record payment** | Sent, balance due | Records customer payment; may set **Paid** when fully paid |
| **Download PDF** | Any | Customer invoice PDF |
| **COGS preview** | Before post | Estimated cost of goods (if shown) |

**Recording a payment:**

1. Click **Record payment**.
2. Enter amount, date, bank account (if prompted), reference (check number, transfer ID).
3. Confirm. Payment history appears on the same page.

Partial payments are supported until the invoice is fully paid.

### 8.4 Sales reports

**Sales** → **Reports** — sales analysis (by period, product, customer—depending on configuration).

### 8.5 Commissions

| Screen | Purpose |
| ------ | ------- |
| **Commission plans** | Define how sales reps earn commission |
| **Commission ledger** | View accrued commission entries |

---

## 9. Procurement (purchasing)

**Menu:** Procurement

### 9.1 Request for quotation (RFQ)

1. **Procurement** → **RFQ** (or hub → RFQ).
2. **New RFQ** — vendor, lines, requested quantities.
3. Track status until converted to a purchase order.

### 9.2 Purchase orders

1. **Procurement** → **Purchase orders**.
2. Open an order to see lines, **qty received**, **qty billed**.

| Action | When | Result |
| ------ | ---- | ------ |
| **Confirm** | RFQ / RFQ sent | Confirms PO with vendor |
| **Receive** | PO / partially received | Records goods receipt; increases `qty received` |
| **Create bill** | Received qty not fully billed | Creates vendor bill from PO |

**Reconciliation** view on the PO shows received vs ordered vs billed quantities.

### 9.3 Vendor bills

1. **Procurement** → **Vendor bills**.
2. Open a bill.

| Action | When | Result |
| ------ | ---- | ------ |
| **Match preview** | Draft, linked to PO | 3-way match (PO – receipt – bill) |
| **Post** | Draft | Books expense/AP to general ledger |
| **Record payment** | Posted, balance due | Pays vendor; reduces amount due |

### 9.4 AP aging report

**Procurement** → **AP aging** (or Reports) — see overdue vendor bills by age bucket.

---

## 10. Finance and accounting

**Menu:** Finance (often restricted to **Manager** / **Admin** roles)

### 10.1 Finance hub

Cards include:

| Feature | Purpose |
| ------- | ------- |
| **Chart of accounts** | GL account list |
| **Journal entries** | Manual journals; view automated entries |
| **Fiscal periods** | Open/close accounting periods |
| **Trial balance** | Debit/credit totals by account |
| **General ledger** | Transaction detail by account |
| **Subledger reconciliation** | Compare AR/AP on invoices/bills to GL control accounts |
| **Payment terms** | Due date rules (Net 30, etc.) |
| **Posting account mappings** | Default AR, AP, bank, revenue, PPV, **default VAT rate (%)** — see [setup guide](./POSTING-ACCOUNT-MAPPINGS-SETUP.md) |
| **Category account mappings** | Revenue/COGS/inventory/AR by product category |
| **Notification control panel** | Admin notification templates and rules |

Set **Default VAT rate (%)** on posting mappings (e.g. `14` for 14%). It applies automatically when creating invoices from sales orders and vendor bills from purchase orders. Use `0` for no tax until per-product rates exist.

### 10.2 Chart of accounts

**Finance** → **Accounts**

- Browse account code, name, type (asset, liability, equity, revenue, expense).
- Create or edit accounts (with permission).

### 10.3 Journal entries

**Finance** → **Journal entries**

- List manual and system-generated journals.
- Create manual adjusting entries (with permission).
- **Post** or **delete** draft entries per your workflow.
- Automated journals from invoices, payments, and inventory show a **reference** and link to source documents.

### 10.4 Fiscal periods

**Finance** → **Fiscal periods**

- Define period start/end dates.
- **Close** a period to block posting in that date range.
- **Reopen** only when policy allows (admin).

Payments and inventory posts require an **open** period for the transaction date.

### 10.5 Trial balance and general ledger

| Report | Use |
| ------ | --- |
| **Trial balance** | Verify debits = credits as of a date |
| **General ledger** | Audit all activity on one account |

Filter by date and account as needed; export if your screen offers it.

### 10.6 AR/AP subledger reconciliation

**Finance** → **Subledger reconciliation**

1. Choose **as of date** (and branch if used).
2. View **AR** tab: open customer invoice total vs AR control account in GL.
3. View **AP** tab: open vendor bill total vs AP control account in GL.

A small **difference** may indicate timing, manual journals, or setup issues—investigate with your accountant.

### 10.7 Record expense / income

**Finance** → **Record expense** or **Record income** — quick forms for non-invoice cash movements (petty cash, misc income) when enabled.

### 10.8 Finance configuration (setup)

Accessible from Finance hub or **Finance config** menu:

| Screen | Configure |
| ------ | --------- |
| **Payment terms** | Net days, discount terms |
| **Posting account mappings** | Default AR, AP, bank, revenue, inventory, PPV, realized/unrealized FX |
| **Product category account mappings** | Override GL accounts per category |
| **Currency settings** | Functional currency (books), default purchase/sales document currencies |
| **Exchange rates** | Dated rates (e.g. 1 USD = 48.5 EGP) for foreign-currency documents and payments |

Complete these **before** go-live posting of invoices and bills.

#### Multi-currency (quick setup)

1. Open **Finance** → **Finance Setup** → **Currency settings**. Set **functional currency** to **EGP** (amounts in GL and inventory use this currency).
2. Set **default purchase** and **default sales** currencies (typically **EGP** unless you routinely buy in USD).
3. Open **Exchange rates** and add a rate for each foreign currency you use, with an **effective date** on or before the document/payment date. The rate is **how many EGP per 1 unit** of the foreign currency (example: USD → EGP, rate `48.5`).
4. On **Posting account mappings**, configure **realized FX gain/loss** (customer/vendor payments at a different rate than the invoice/bill) and **unrealized FX gain/loss** (month-end revaluation).
5. When creating RFQs, sales orders, invoices, or vendor bills, pick **document currency**; the system resolves the exchange rate for that date (you can override it).
6. **Month-end:** on **Exchange rates**, run **FX revaluation** for the period-end date to revalue open foreign-currency AR/AP balances.

Payments are recorded in the **invoice/bill currency**; the general ledger uses **functional (EGP)** amounts. If the payment-date rate differs from the document rate, a **realized FX** line is posted when the FX accounts are configured.

---

## 11. HRMS (human resources)

**Menu:** HRMS (if visible)

### Employees

1. **HRMS** → **Employees** — list and search.
2. **New employee** — personal data, job info, active flag.
3. Employee **detail** — view profile; open **Contracts** for employment terms.

### Contracts

**HRMS** → **Contracts** — employment contracts, dates, salary structure links.

### Payroll

**HRMS** → **Payroll** — payroll period summary and processing (per your organization’s setup).

### HR reports

| Report | Content |
| ------ | ------- |
| **Headcount** | Employees by department/status |
| **Salary expense** | Salary costs over time |
| **Contract expiration** | Contracts ending soon |

---

## 12. Point of sale (POS)

**Menu:** Point of Sale

Retail checkout interface for in-store sales:

- Scan or select products.
- Apply discounts and take payments.
- Sync sales back to the ERP (requires POS permission).

POS is optimized for touch screens; use a dedicated terminal where possible. Offline behavior depends on your deployment—ask IT if sync fails.

---

## 13. Compliance (e-invoices)

**Menu:** Compliance (if visible)

| Screen | Purpose |
| ------ | ------- |
| **E-invoices** | List ETA submissions (eInvoice and eReceipt), create drafts, submit, refresh status |
| **ETA settings** | Preprod/prod credentials, PKCS#12 certificate, issuer data, auto-submit toggles |

**Invoice detail** (posted invoices) — ETA section: preview canonical JSON, submit to ETA, refresh status.

**POS** — after sync, eReceipt status may appear in the app bar when auto-submit is enabled.

Setup guide for administrators: [ETA-INTEGRATION-SETUP.md](./ETA-INTEGRATION-SETUP.md)

---

## 14. Notifications

### For all users

- **Bell icon** — recent notifications.
- **Mark as read** / **Mark all read** / **Clear history**.

### For administrators

**Finance hub** → **Notification control panel** (or **Notifications** in platform menu):

| Area | Purpose |
| ---- | ------- |
| **Message templates** | Reusable titles/bodies with variables |
| **Trigger rules** | Send alerts when events occur (e.g. low stock) |
| **Manual send** | One-off message to users or roles |
| **Test mode** | Preview before enabling rules |

See [NOTIFICATIONS.md](../NOTIFICATIONS.md) for admin walkthroughs.

---

## 15. Administration

### Users

**Menu:** Users (Admin / Manager)

- List users, filter by role.
- Open a user profile; edit details and assignments (admin).
- Create users (admin) and reset access as per your IT policy.

### Roles

**Menu:** Roles (**Admin only**)

- View roles (Admin, Manager, custom roles).
- Open a role → **Permissions** — tick what that role may do.
- After changing permissions, users may need to **log out and back in**.

Always grant minimum permissions needed (e.g. separate **pay invoice** from **read invoice**).

### Tenants

Multi-tenant installations: super-admins manage tenants outside day-to-day operations—ignore unless IT assigns you tenant admin tasks.

---

## 16. Translations

**Menu:** Translations / i18n (platform)

**Product translations** — maintain product names and descriptions in multiple languages for catalogs and documents.

---

## 17. End-to-end workflows

### 17.1 Order to cash (sell and collect)

```
Partner (customer) → Quotation (optional) → Sales order → Confirm
    → Create invoice → Post invoice → Record payment(s)
```

**Inventory path (if you ship stock):**

```
Confirm order → Create invoice (with auto issue) OR Stock issue manually
    → Stock receipt/issue documents completed in Inventory
```

**Accounting path:**

```
Post invoice → AR + revenue (+ COGS if enabled)
    → Record payment → Bank + reduce AR
    → Month-end: Subledger reconciliation (Finance)
```

### 17.2 Purchase to pay (buy and pay vendor)

```
Partner (vendor) → RFQ → Purchase order → Confirm
    → Receive goods (updates qty received)
    → Create vendor bill → Match preview → Post bill
    → Record vendor payment
```

**Accounting path:**

```
Post bill → AP + expense/inventory
    → Record payment → Reduce AP + bank
    → AP aging + subledger reconciliation
```

### 17.3 Month-end (accountant checklist)

1. Complete all draft stock receipts/issues.
2. Post remaining invoices and vendor bills.
3. Record payments received and sent.
4. Run **Trial balance** and **Subledger reconciliation**.
5. Run inventory **GL reconciliation** reports.
6. **Close fiscal period** when satisfied.

---

## 18. Status reference

### Sales order

| Status | Meaning |
| ------ | ------- |
| Draft | Being prepared |
| Sent | Quote sent |
| Confirmed | Customer accepted; ready to invoice |
| Invoiced | Fully invoiced |
| Cancelled | No longer active |

### Invoice

| Status | Meaning |
| ------ | ------- |
| Draft | Not posted to accounts |
| Sent | Posted; awaiting payment |
| Paid | Fully paid |
| Cancelled | Voided |

### Purchase order

| Status | Meaning |
| ------ | ------- |
| RFQ / RFQ sent | Requesting quotes |
| Purchase order | Confirmed with vendor |
| Received | Goods partially/fully received |
| Billed | Billed in full |
| Cancelled / Locked | End states |

### Vendor bill

| Status | Meaning |
| ------ | ------- |
| Draft | Not posted |
| Posted | In AP; can pay |
| Paid | Fully paid |
| Cancelled | Voided |

### Stock documents (receipt, issue, transfer, adjustment)

| Status | Meaning |
| ------ | ------- |
| Draft | Editable; not affecting stock (or pending) |
| Completed | Applied to inventory |
| Cancelled | Discarded |

---

## 19. Frequently asked questions

### I posted an invoice but cannot record payment

- Invoice must be **Sent** (posted), not Draft.
- You need **pay:invoice** permission.
- There must be **balance due** > 0.
- A **fiscal period** must be open for the payment date.

### Post invoice failed: “No posting account mapping”

Finance must configure **Posting account mappings** (AR, revenue, bank, category mappings). See [Posting Account Mappings — Setup Guide](./POSTING-ACCOUNT-MAPPINGS-SETUP.md).

### Vendor bill post blocked by match

Open **Match preview** — quantity or price may not match PO/receipt. Fix the bill or receipt, or escalate to procurement.

### Stock receipt Complete button missing

- Receipt must be **Draft**.
- You need **update:stock** permission.

### Numbers on reconciliation do not match

Normal causes: manual GL journals, unposted documents, wrong as-of date, or missing category mappings. Ask finance to review [subledger reconciliation](./ACCOUNTING-INVENTORY-PHASES.md#phase-10--arap-gl-reconciliation).

### PDF download fails

Check network; try again. If it persists, report invoice/order number to support.

### I see English labels but need Arabic

Use the **language switcher** in the top bar. Some screens use translation keys—report missing translations to admin (Translations module).

---

## Document history

| Version | Date | Notes |
| ------- | ---- | ----- |
| 1.0 | May 15, 2026 | Initial end-user manual covering all major modules |

For technical implementation details, developers should use [ACCOUNTING-INVENTORY-PHASES.md](./ACCOUNTING-INVENTORY-PHASES.md) and [backend workflow guides](../backend/docs/WORKFLOWS-INDEX.md).
