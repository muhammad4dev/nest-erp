# Nest ERP — End User Manual

A practical guide to every major feature in the web application. This manual is written for **business users** (sales, warehouse, accounting, HR, administrators)—not developers.

**Last updated:** May 26, 2026  
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
| **Total movements summary** | Aggregate incoming and outgoing quantities across all products |
| **Category card** | Movements grouped by product category for quick comparison |
| **Items matrix** | Products × locations grid showing on-hand quantity at each warehouse |
| **Monthly movement breakdown** | Month-by-month view of receipts, issues, and net change |
| **Daily incoming monitoring** | Day-by-day log of received goods for tracking delivery patterns |
| **Store expenditures** | Total consumption and issue value per warehouse/store |

### 7.7 Stocktakes

**Inventory** → **Stocktakes** — plan and record physical counts, then reconcile variances (often via adjustments).

### 7.8 Inventory period close

**Inventory** → **Period close** — month-end inventory closing and opening snapshots (finance-controlled process).

### 7.9 Bill of materials (BOM)

**Inventory** → **BOMs**

A bill of materials defines the **component structure** of an assembled or manufactured product.

1. Create a BOM: select the finished product, then add component lines (product, quantity per unit).
2. BOMs support **multi-level** structures — a component can itself have a BOM, forming a tree.
3. Use **cost rollup** to calculate the finished product's cost from its components.

BOMs are referenced when planning production or calculating landed cost of assemblies.

### 7.10 Reorder rules

**Inventory** → **Reorder Rules**

Set automatic replenishment thresholds per product and location:

| Field | Purpose |
| ----- | ------- |
| **Minimum qty** | Stock level at which a reorder alert triggers |
| **Maximum qty** | Target stock level after replenishment |
| **Reorder point** | Quantity threshold that triggers a suggestion |

Use **Check reorder** to scan all products against their rules. The system generates a **reorder suggestions** list showing every item below its threshold, with the recommended order quantity.

### 7.11 Advanced stock balances

Stock detail views now show **five balance types** for a clearer picture of availability:

| Balance | Meaning |
| ------- | ------- |
| **Total** | Physical quantity in the location |
| **Reserved** | Committed to confirmed sales orders or production |
| **In-transit** | Shipped from another location but not yet received |
| **Under production** | Allocated to active production/assembly orders |
| **Available** | Total minus reserved, in-transit, and under production |

### 7.12 Item substitutes

**Inventory** → **Substitutes**

Define alternative products that can replace a primary item when it is out of stock:

1. Select the **primary product**.
2. Add one or more **substitute products** with a **priority** (lower number = preferred).
3. When the primary item is unavailable, users see the substitute list ranked by priority.

### 7.13 Gift and bonus policies

**Inventory** → **Gift Policies**

Create promotional "buy X get Y free" rules:

| Field | Purpose |
| ----- | ------- |
| **Trigger product** | The item the customer must purchase |
| **Minimum quantity** | How many units they must buy |
| **Gift product** | The free item awarded |
| **Gift quantity** | How many free units are given |
| **Active from / to** | Date range during which the policy applies |

Policies are evaluated at order or invoice time and the gift item is added automatically when conditions are met.

### 7.14 Expiry management

**Inventory** → **Expiry Reports**

Track products approaching or past their expiry dates:

- **Expiring within N days** — set the look-ahead window (e.g. 90 days) to see at-risk stock.
- **Bucketed report** — items grouped by urgency: *Expired*, *0–30 days*, *31–60 days*, *61–90 days*, *90+ days*.
- **Per-product expiry view** — drill into a specific product to see individual batch expiry dates and quantities.

Use these reports to plan clearance, returns to vendor, or write-offs before product expires.

---

## 8. Sales

**Menu:** Sales

The sales hub provides cards for **Orders**, **Invoices**, **Credit Notes**, **Delivery Notes**, and **Reports**. Click any card to open the corresponding list.

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

1. **Sales** → **Invoices** — list of all customer invoices with search, filters, and status indicators.
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

### 8.4 Credit notes

**Sales** → **Credit Notes**

Credit notes are invoices with a **credit** type that reduce a customer's outstanding balance. They are typically created from a sales return or as a manual adjustment.

1. Open the credit notes list to see all credit note invoices.
2. Post a credit note to apply it against the customer's AR balance.

### 8.5 Delivery notes

**Sales** → **Delivery Notes**

Delivery notes track the physical dispatch of goods to customers:

1. View all delivery notes from the list page.
2. Open a note to see line items, quantities, and dispatch status.
3. Use **Dispatch** actions to mark goods as shipped.

Delivery notes link back to the originating sales order for traceability.

### 8.6 Sales returns

**Sales** → **Sales Returns**

Record goods returned by customers as standalone return documents:

1. **New return** — select the customer, add return lines (product, quantity, reason).
2. While **Draft**: edit freely.
3. **Confirm** the return:
   - A **stock receipt** is automatically created (goods back into the warehouse).
   - A **GL reversal** is posted (reverses the original revenue, AR, and COGS entries).
4. Optionally, the system **auto-creates a credit note** to adjust the customer's balance.

### 8.7 Commission engine

**Sales** → **Commission Rules**

Define how sales representatives earn commission:

| Setting | Options |
| ------- | ------- |
| **Calculation basis** | On invoice amount, on payment received, or on profit margin |
| **Rate type** | Flat percentage, tiered (rate changes at volume thresholds), or per product category |

**Commission entries** are calculated automatically when the triggering event occurs (invoice post, payment, etc.). Each entry shows the salesperson, amount, and accrual status.

- **Accrued** entries post to the commission liability GL account.
- Mark entries as **Paid** when the commission is disbursed to the salesperson.

View the full commission ledger under **Sales** → **Commission Entries**.

### 8.8 Advanced pricing rules

**Sales** → **Pricing Rules**

Control pricing beyond the standard product price:

| Rule type | What it does |
| --------- | ------------ |
| **Min/max price** | Prevents selling below cost or above a ceiling |
| **Quantity breaks** | Automatic unit price reduction at volume thresholds |
| **Auto-discounts** | Percentage or fixed discount applied when conditions match |

Rules are evaluated by **priority** — the highest-priority matching rule wins. The system validates prices against active rules before saving invoices, alerting users if a price falls outside allowed bounds.

### 8.9 Discount and addition notices

**Sales** → **Adjustment Notices**

Post-invoice balance adjustments for a customer:

- **Discount notice** — reduces the customer's outstanding balance (e.g. early-payment discount, goodwill).
- **Addition notice** — increases the customer's balance (e.g. late fees, additional charges).

1. Create a notice: select customer, type (discount or addition), amount, and reason.
2. **Confirm** the notice — a GL journal is posted automatically (adjusting AR and the corresponding income/expense account).

### 8.10 Inter-customer settlement

**Sales** → **Customer Settlements**

Transfer an outstanding balance from one customer to another (e.g. when a subsidiary pays on behalf of a parent company):

1. Select the **source customer** (balance debited) and the **target customer** (balance credited).
2. Enter the settlement amount.
3. Confirm — the system posts a GL journal: debit AR of the source customer, credit AR of the target customer.

### 8.11 Sales reports

**Sales** → **Reports**

| Report | What it shows |
| ------ | ------------- |
| **Daily net sales** | Revenue totals per day for a selected period |
| **Monthly item sales** | Quantities and revenue by product per month |
| **Average selling price** | Mean selling price per product over time |
| **Customer–item analysis** | Cross-tab of customers vs products with quantities and revenue |
| **Item–customer analysis** | Cross-tab of products vs customers (inverse view) |
| **Item profitability** | Revenue, cost, and margin per product |
| **Customer profitability** | Revenue, cost, and margin per customer |
| **Rep profitability** | Revenue and margin attributed to each salesperson |
| **Sales growth rate** | Period-over-period revenue growth percentage |
| **Sales traffic summary** | Transaction counts and average ticket size |

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

### 9.5 Material requests

**Procurement** → **Material Requests**

Internal departments use material requests to ask for items they need:

1. **New request** — select the requesting department, add item lines with quantities.
2. **Submit** the request for management review.
3. A manager **Approves** or **Rejects** the request.
4. Once approved, each line can be fulfilled in one of two ways:
   - **Items already in stock** → Convert to an **Exchange** (internal stock issue from warehouse to the requesting department).
   - **Items to purchase** → Convert to an **RFQ**, which follows the normal procurement flow (RFQ → PO → Receive → Bill → Pay).

Material requests give departments a formal channel to requisition goods while keeping procurement centralized.

### 9.6 Quotation comparison

**Procurement** → **Quotations**

When you send an RFQ to multiple vendors, each vendor's response is recorded as a **supplier quotation**:

1. Open the RFQ and view **received quotations**.
2. Use the **comparison matrix** — a side-by-side view of each vendor's prices, lead times, and terms for every line item.
3. **Accept** the best quotation (or accept line by line from different vendors).
4. **Reject** the remaining quotations.
5. The system can **auto-generate a purchase order** from the accepted quotation.

### 9.7 Purchase returns

**Procurement** → **Purchase Returns**

Return defective or unwanted goods to a vendor:

1. **New return** — select vendor, add return lines (product, quantity, reason).
2. While **Draft**: edit freely.
3. **Confirm** the return:
   - A **stock issue** is created (goods leave the warehouse).
   - A **GL reversal** is posted (debit AP / credit inventory).
4. Optionally, the system **auto-creates a vendor credit note** to offset the original bill.

### 9.8 Landed costs

**Procurement** → **Landed Costs**

Allocate additional costs (freight, customs duties, insurance, handling fees) to the purchase cost of received goods:

1. Select the **stock receipt** (or purchase order receipt) to which costs apply.
2. Add cost lines: amount, cost type (freight, customs, etc.), and **allocation method**.

| Allocation method | How cost is spread |
| ----------------- | ------------------ |
| **By value** | Proportional to the purchase value of each item |
| **By quantity** | Equal share per unit received |
| **By weight** | Proportional to item weight |

3. **Confirm** — the system posts a GL journal and updates the inventory cost layers so future COGS reflects the true landed cost.

### 9.9 Supplier catalog

**Procurement** → **Supplier Products**

Maintain a catalog of vendor-specific item information:

| Field | Purpose |
| ----- | ------- |
| **Supplier item code** | The vendor's own SKU for the product |
| **Supplier price** | The vendor's quoted price |
| **Last purchase price** | Automatically updated from the most recent PO |
| **Lead time (days)** | Expected delivery time from this vendor |
| **Preferred supplier** | Flag this vendor as the default source for the product |

When creating purchase orders, the system can pre-fill prices and codes from the preferred supplier's catalog entry.

### 9.10 Supplier performance

**Procurement** → **Supplier Performance**

Track vendor reliability and quality over time:

| Metric | What it measures |
| ------ | ---------------- |
| **On-time delivery rate** | Percentage of PO lines delivered by the promised date |
| **Quality rating** | Score based on accepted vs rejected quantities per PO |

Use these metrics to evaluate vendor contracts, negotiate terms, or decide which supplier to award future orders to.

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

Additional fields available on journal entries:

| Field | Purpose |
| ----- | ------- |
| **Tags** | Add searchable keywords (e.g. "year-end", "audit") to find entries quickly |
| **Book reference** | Manual reference number from your physical books or registers |
| **Analysis code** | Free-form grouping code for management reporting |
| **Auto-narration** | System-generated description based on the source type (invoice, payment, depreciation, etc.) — saves time on routine entries |

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

### 10.9 Cost centers

**Finance** → **Cost Centers**

Cost centers let you track income and expenses by **department, branch, project, or any organizational unit**.

1. Create a cost center hierarchy (tree structure) — e.g. *Company → Division → Department*.
2. Each cost center has a code, name, and optional parent.
3. When creating or editing journal entries, select a **cost center** on each line to tag the transaction.
4. Set **opening balances** per cost center when migrating from a previous system.

Cost center data feeds into departmental reports (see [10.25 Financial reports](#1025-financial-reports)).

### 10.10 Budgets

**Finance** → **Budgets**

Plan and monitor spending against targets:

1. **New budget** — give it a name, fiscal year, and status (**Draft** while building).
2. Add **budget lines**: select an account, then enter monthly amounts (or a single annual/quarterly figure that the system spreads).
3. Set the budget to **Active** when approved.

**Variance report:** Compare budgeted amounts to actual journal entry totals for any period. The report highlights over-budget accounts so you can act before period close.

### 10.11 Cash flow statement

**Finance** → **Reports** → **Cash Flow**

An **indirect-method** cash flow statement generated from your GL data:

| Section | What it includes |
| ------- | ---------------- |
| **Operating activities** | Net income adjusted for non-cash items (depreciation, working capital changes) |
| **Investing activities** | Fixed asset purchases, disposals, investment changes |
| **Financing activities** | Loan proceeds, repayments, equity changes |

Select a date range to generate. The statement reconciles opening and closing cash balances.

### 10.12 Fixed assets

**Finance** → **Fixed Assets**

Register, depreciate, and dispose of long-lived assets (equipment, vehicles, furniture, etc.):

**Registering an asset:**

1. **New asset** — enter description, category, acquisition date, original cost, useful life, and salvage value.
2. Choose a **depreciation method**:

| Method | How it works |
| ------ | ------------ |
| **Straight-line** | Equal expense each period over useful life |
| **Declining balance** | Higher expense early, decreasing over time (accelerated) |

3. Assign a **cost center** if departmental tracking is needed.

**Running depreciation:**

- **Finance** → **Fixed Assets** → **Run Depreciation** (monthly).
- The system calculates the period's depreciation for all active assets and **auto-posts a GL journal** (debit depreciation expense, credit accumulated depreciation).

**Disposing an asset:**

1. Open the asset and click **Dispose**.
2. Enter the disposal date and proceeds (sale price, if any).
3. The system posts a GL journal that removes the asset cost and accumulated depreciation, and records any **gain or loss on disposal**.

**Asset summary report:** View assets grouped by category, status, and cost center — showing original cost, accumulated depreciation, and net book value.

### 10.13 Cheque management

**Finance** → **Cheques**

Full lifecycle tracking for cheques received from customers (**AR cheques**) and cheques issued to vendors (**AP cheques**).

**AR cheque lifecycle (cheques received):**

| Step | Action | What happens |
| ---- | ------ | ------------ |
| 1 | **Receive** | Record the cheque details (number, bank, amount, due date) |
| 2 | **Deposit** | Mark the cheque as deposited at your bank |
| 3a | **Collect** | Bank clears the cheque — GL is posted (debit bank, credit cheques receivable) |
| 3b | **Bounce** | Cheque is returned unpaid — reverse and follow up with customer |
| Alt | **Endorse** | Transfer the cheque to a third party (vendor or another bank) |

**AP cheque lifecycle (cheques issued):**

| Step | Action | What happens |
| ---- | ------ | ------------ |
| 1 | **Issue** | Record the cheque written to a vendor |
| 2 | **Outstanding** | Cheque is with the vendor, awaiting presentation |
| 3a | **Paid** | Bank debits your account — GL is posted (debit AP, credit bank) |
| 3b | **Cancel** | Void the cheque before it clears |

**Cheque reports:**
- **AR cheque aging** — receivable cheques grouped by due-date buckets.
- **AP outstanding cheques** — issued cheques not yet cleared, grouped by vendor.

### 10.14 Treasury and safes

**Finance** → **Treasury Safes**

Manage petty-cash boxes, office safes, and other physical cash stores:

1. **New safe** — name, custodian (responsible person), opening balance.
2. The system tracks the **current balance** as transactions are recorded.
3. **Transfer between safes** — move cash from one safe to another with a recorded transaction.

Use treasury safes to monitor cash held outside the bank and reconcile with physical counts.

### 10.15 Payment deductions

**Finance** → **Payment Deductions**

Define deduction types that are automatically calculated when recording payments:

| Deduction type | Example |
| -------------- | ------- |
| **Withholding tax** | 1–5% deducted at source on vendor payments |
| **Stamp duty** | Fixed or percentage duty on payment instruments |

1. Set up deduction rules: name, rate (percentage or fixed), applicable payment direction (customer / vendor / both).
2. When recording a payment, applicable deductions are **auto-calculated** and shown before confirmation.
3. The net payment amount and deduction amounts are posted to their respective GL accounts.

### 10.16 Advance payments

**Finance** → **Advance Payments**

Track prepayments made by customers or to vendors before an invoice or bill is issued:

1. **New advance** — select partner (customer or vendor), amount, date, reference.
2. The advance is recorded with status **Open**.
3. When an invoice or bill is later created, **settle** all or part of the advance against it.
4. Partial settlements are supported — the **unsettled balance** is tracked per partner.

View advance balances per partner to understand prepayment exposure at any time.

### 10.17 Bank transfers

**Finance** → **Bank Transfers**

Move funds between your organization's bank accounts or cash accounts:

1. Select the **from account** and **to account**.
2. Enter the transfer amount and date.
3. Confirm — the system **auto-posts a GL journal** (debit the receiving account, credit the sending account).

Use bank transfers for internal fund movements, sweeps between accounts, or transfers to/from petty cash.

### 10.18 Credit card settlements

**Finance** → **Credit Card Settlements**

Record the settlement of POS terminal (credit/debit card) transactions with your payment processor:

| Field | Meaning |
| ----- | ------- |
| **Gross amount** | Total card sales for the settlement period |
| **Commission** | Processor/merchant fee deducted |
| **Net amount** | Cash deposited to your bank (gross minus commission) |

On confirmation, the system **auto-posts a GL journal**: debit bank (net) + debit commission expense, credit the merchant receivable account. This clears the card sales from your books when the bank deposit arrives.

### 10.19 Recurring journals

**Finance** → **Recurring Journals**

Automate repetitive journal entries (rent, loan payments, depreciation overrides, etc.):

1. **New template** — define the journal lines (accounts, amounts, descriptions) as you would a normal journal entry.
2. Set the **frequency**: daily, weekly, monthly, quarterly, or yearly.
3. Set the **start date** and optionally an **end date**.
4. **Execute** the template — the system creates a journal entry for the current period and advances the **next run date** automatically.

Review generated entries under **Journal entries** like any other posting.

### 10.20 Cost center distributions

**Finance** → **Cost Center Distributions**

Automatically allocate shared expenses across multiple cost centers:

1. **New distribution rule** — select the source GL account (e.g. "Rent Expense").
2. Define the **percentage split**: assign a percentage to each target cost center (must total 100%).
3. When expenses are posted to that account, the distribution rule **splits the amount** across the designated cost centers.

Use distributions for overhead allocation (rent, utilities, IT costs) shared among departments.

### 10.21 Custom financial statements

**Finance** → **Custom Statements**

Design your own report layouts beyond the standard trial balance and P&L:

1. **New statement** — give it a name (e.g. "Management P&L", "Board Summary").
2. Add **sections** and within each section define **account groupings** (ranges of account codes or specific accounts).
3. Arrange sections in the order you want them printed.
4. **Generate** the report for any date range — the system pulls actual balances into your layout.

Custom statements are useful for board reporting, bank submissions, or internal management formats that differ from the statutory layout.

### 10.22 Receipt books

**Finance** → **Receipt Books**

Manage serialized receipt number books for cash collections and payments:

| Field | Purpose |
| ----- | ------- |
| **Prefix** | Text prepended to each number (e.g. "REC-") |
| **Start number** | First serial in the book |
| **End number** | Last serial in the book |
| **Current number** | Next number to be used (auto-incremented) |

When a receipt is issued, the system pulls the next available number from the active book and advances the counter. Multiple books can be active for different locations or purposes.

### 10.23 Voucher and cheque printing

**Finance** → **Vouchers** / **Cheque Print**

Generate print-ready data for financial documents:

- **Receipt voucher** — formatted record of money received from a customer.
- **Payment voucher** — formatted record of money paid to a vendor.
- **Cheque print** — cheque data including payee, amount in figures, **amount in words** (auto-generated), date, and bank details.

Use these with your configured **Print templates** (see below) for professional output.

### 10.24 Print templates

**Finance** → **Print Templates**

Customize the layout of printed documents for your organization:

| Setting | Options |
| ------- | ------- |
| **Document type** | Invoice, receipt, delivery note, purchase order, cheque, voucher |
| **Paper size** | A4, A5, Letter |
| **Orientation** | Portrait or landscape |
| **Sections** | Configure header (logo, company info), body (line items, totals), and footer (terms, signatures) |

Create multiple templates per document type (e.g. a compact A5 receipt and a detailed A4 invoice). Select the active template per document type in your settings.

### 10.25 Financial reports

**Finance** → **Reports**

In addition to the standard trial balance, general ledger, and cash flow, the following analytical reports are available:

| Report | What it shows |
| ------ | ------------- |
| **Vertical analysis** | Each line item as a percentage of a total (revenue for P&L, total assets for balance sheet) |
| **Horizontal analysis** | Period-over-period change in both amount ($) and percentage (%) |
| **Cost center trial balance** | Trial balance filtered or grouped by cost center |
| **Cost center P&L** | Profit and loss statement per cost center |
| **Cost center matrix** | Accounts × cost centers grid for cross-departmental comparison |
| **Subsidiary ledger** | Partner-filtered ledger showing all transactions for a specific customer or vendor (sub-ledger) |
| **Account statement** | Running balance per account with all transactions listed chronologically |
| **Account statement with drill-down** | Expandable rows showing underlying invoice/payment details; click through to source documents |
| **Cash flow forecasting** | Projected cash position over the next 8 weeks based on open AR (expected inflows) and AP (expected outflows) |
| **AR aging** | Customer debt aging in 30-day buckets (current, 30, 60, 90, 120+ days) per partner |
| **AP aging** | Vendor debt aging in 30-day buckets per partner |
| **Expense analysis** | Aggregate expenses sliced by account, cost center, and/or month |

### 10.26 Bulk data import

**Finance** → **Import Data**

Upload CSV files to bulk-import master data (accounts, products, partners, opening balances, etc.):

1. Select the **data type** to import.
2. Upload your CSV file.
3. **Preview** the data — the system shows a table of rows to be imported.
4. **Map columns** — match your CSV headers to the system's expected fields.
5. **Validate** — the system checks for errors (duplicates, missing required fields, invalid formats) and highlights problems.
6. **Import** — confirmed rows are created in the system.

Use bulk import during initial setup or when migrating data from another system.

---

## 11. HRMS (human resources)

**Menu:** HRMS (if visible)

### Employees

1. **HRMS** → **Employees** — list and search.
2. **New employee** — personal data, job info, active flag.
3. Employee **detail** — view profile; open **Contracts** for employment terms.

### Contracts

**HRMS** → **Contracts** — employment contracts, dates, salary structure links.

### Payroll, attendance, and timesheets

See **[Payroll & attendance guide](./PAYROLL-ATTENDANCE.md)** for full detail.

| Screen | Who | Purpose |
| ------ | --- | ------- |
| **Attendance** | HR | Daily present/absent/leave grid; drives monthly wage pro-ration |
| **Timesheets** | HR | Approve or reject employee-submitted hours |
| **My timesheet** | Employee | Enter clock in/out (requires linked user on employee record) |
| **Payroll** | HR / finance | Calculate period, adjustments, scheduled pay date, hold/release, finalize to GL |

On the **employee** form, optionally link a **user account** so the employee can use **My timesheet** without HR entering hours for them.

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
4. Run **fixed asset depreciation** for the month.
5. Review **budget variance** report for overspend.
6. Run **Trial balance** and **Subledger reconciliation**.
7. Run inventory **GL reconciliation** reports.
8. Review **cash flow forecast** for upcoming weeks.
9. **Close fiscal period** when satisfied.

### 17.4 Material request to purchase

```
Department → Material Request → Submit → Approve
    → Items in stock: Convert to Exchange (stock issue to department)
    → Items to buy: Convert to RFQ → PO → Receive → Bill → Pay
```

A single material request can result in **both** an exchange (for stocked items) and an RFQ (for items to purchase). Track fulfillment status on the request itself.

### 17.5 Sales return

```
Customer returns goods → Sales Return → Confirm
    → Stock Receipt (goods back to warehouse)
    → GL reversal (revenue, AR, COGS reversed)
    → Optional: Credit Note auto-created
```

If a credit note is created, it can be applied against the customer's future invoices or refunded.

### 17.6 Fixed asset lifecycle

```
Register asset → Monthly: Run Depreciation (auto-posts GL journal)
    → Asset fully depreciated or no longer needed
    → Dispose: GL posting (remove asset cost, clear accumulated depreciation, record gain/loss)
```

The asset summary report shows the current state of all assets at any point in this lifecycle.

### 17.7 Cheque lifecycle

**AR cheques (received from customers):**

```
Receive cheque → Deposit at bank → Collect (GL posted) or Bounce
                                  → If bounced: follow up with customer
Alternative: Endorse cheque to a third party
```

**AP cheques (issued to vendors):**

```
Issue cheque → Outstanding (with vendor) → Paid (GL posted) or Cancel
```

Each status change is recorded with a date, so you have a full audit trail of cheque movements.

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

### Material request

| Status | Meaning |
| ------ | ------- |
| Draft | Being prepared by the requesting department |
| Submitted | Sent for management approval |
| Approved | Approved; ready for fulfillment |
| Partially fulfilled | Some lines converted to exchange or RFQ |
| Fulfilled | All lines fulfilled |
| Rejected | Request denied by approver |

### Cheque — AR (received)

| Status | Meaning |
| ------ | ------- |
| Received | Cheque recorded from customer |
| Deposited | Submitted to bank for clearing |
| Collected | Bank confirmed funds received |
| Bounced | Cheque returned unpaid |
| Endorsed | Transferred to a third party |

### Cheque — AP (issued)

| Status | Meaning |
| ------ | ------- |
| Issued | Cheque written and recorded |
| Outstanding | Cheque is with vendor, awaiting bank presentation |
| Paid | Bank has debited the account |
| Cancelled | Cheque voided before clearing |

### Fixed asset

| Status | Meaning |
| ------ | ------- |
| Active | In use; depreciation is running |
| Fully depreciated | Useful life ended; net book value equals salvage value |
| Disposed | Asset removed from service; disposal GL posted |

### Advance payment

| Status | Meaning |
| ------ | ------- |
| Open | Advance recorded; not yet applied |
| Partially settled | Part of the advance applied to invoices/bills |
| Fully settled | Entire advance consumed against invoices/bills |

### Sales return

| Status | Meaning |
| ------ | ------- |
| Draft | Return being prepared |
| Confirmed | Return approved; stock and GL reversed |
| Completed | All follow-up actions (credit note, etc.) finished |

### Purchase return

| Status | Meaning |
| ------ | ------- |
| Draft | Return being prepared |
| Confirmed | Return approved; stock issued and GL reversed |
| Completed | All follow-up actions (credit note, etc.) finished |

### Budget

| Status | Meaning |
| ------ | ------- |
| Draft | Budget being built; not yet enforced |
| Active | Approved; variance tracking is live |
| Closed | Period ended; budget is locked for historical reference |

### Commission entry

| Status | Meaning |
| ------ | ------- |
| Accrued | Commission calculated and posted to liability |
| Paid | Commission disbursed to the salesperson |

---

## 19. Frequently asked questions

### I posted an invoice but cannot record payment

- Invoice must be **Sent** (posted), not Draft.
- You need **pay:invoice** permission.
- There must be **balance due** > 0.
- A **fiscal period** must be open for the payment date.

### Post invoice failed: "No posting account mapping"

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

### How do I allocate overhead expenses to departments?

Set up **Cost center distributions** under Finance. Define the source expense account and the percentage split across cost centers. Future postings to that account will be allocated automatically.

### A cheque I deposited bounced — what now?

Open the cheque under **Finance → Cheques**, and mark it as **Bounced**. The GL entry is reversed. Follow up with the customer to arrange a replacement payment.

### How do I track an advance payment against a future invoice?

Record the advance under **Finance → Advance Payments**. When the invoice is created and posted, open the advance and **Settle** it (fully or partially) against the invoice. The unsettled balance updates automatically.

---

## Document history

| Version | Date | Notes |
| ------- | ---- | ----- |
| 2.0 | May 26, 2026 | Added coverage for all Phase 2–6 finance features, supply chain enhancements (procurement, inventory, sales), and new frontend modules |
| 1.0 | May 15, 2026 | Initial end-user manual covering all major modules |

For technical implementation details, developers should use [ACCOUNTING-INVENTORY-PHASES.md](./ACCOUNTING-INVENTORY-PHASES.md) and [backend workflow guides](../backend/docs/WORKFLOWS-INDEX.md).
