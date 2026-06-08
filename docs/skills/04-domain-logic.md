# 04 — Domain Logic

## Integration Model
- Cross-module: direct Nest DI service calls inside transactions — **no EventEmitter**.
- Async external: `WebhookEventHubService.emit()` / `WebhookDispatcherService.dispatch()` (Finance-owned).
- GL bridge: `InventoryPostingService.postBalancedJournal()` + inline `JournalEntry` saves.
- Approval gate: `ApprovalService` (Sales-owned) blocks Invoice + VendorBill posting.

## Module Dependency Graph
```
SalesModule       → InventoryModule, FinanceModule, ComplianceModule
ProcurementModule → InventoryModule, FinanceModule, SalesModule
PosModule         → InventoryModule, FinanceModule, ComplianceModule
InventoryModule   → Finance entities (TypeORM only, no FinanceModule import)
HrmsModule        → Finance entities + SalesCommission (TypeORM only)
FinanceModule     → Inventory/Sales/Procurement entities (reconciliation)
```

## Shared Entities (cross-module FKs)
| Entity | Owner | Consumed By |
|--------|-------|-------------|
| `Partner` | Sales | Procurement PO/Bill, POS orders, Finance `PartnerBalance` |
| `Product`, `ProductVariant`, `ProductUom`, `Location` | Inventory | Sales/Procurement lines, POS stock checks |
| `PaymentTerm`, `PostingAccountMapping`, `FiscalPeriod`, `JournalEntry`, `Account` | Finance | Sales invoicing, Procurement bills, Inventory posting, HRMS payroll |
| `Employee`, `EmploymentContract` | HRMS | Sales commissions, `SalesOrder.salesRepId` |
| `SalesCommission` | Sales | HRMS payroll (accrue on payment, mark PAID on finalize) |
| `StockReceipt`, `StockIssue`, `StockQuant`, `StockReservation` | Inventory | Sales invoicing, Procurement receiving, POS availability |

---

## Sales

### Sales → Inventory
- `SalesService.confirmOrder()` → `StockReservationService.reserveForOrderLine()` per line.
- `SalesService.cancelOrder()` → `StockReservationService.releaseForOrder()`.
- `SalesService` → `InventoryService.toBaseQuantity()` on confirm (UOM conversion).
- `SalesStockCheckService` → sellable-qty checks at create/update/confirm.
- `InvoiceService.createFromOrder()` → `InventoryService.createIssue()` (draft `StockIssue` type `SALE`).
- `InvoiceService.postInvoice()` → `InventoryService.completeIssue()` (stock↓ + COGS GL).
- `CreditNoteService` post → `InventoryService.createReceipt()` + `completeReceipt()` (`ReceiptSourceType.RETURN`).

### Sales → Finance
- `InvoiceService.postInvoice()` → direct `JournalEntry`/`JournalLine` (AR debit, revenue credit, output VAT; `JournalSourceType.INVOICE`).
- `InvoicePaymentService.confirmPayment()` → payment journals (`JournalSourceType.INVOICE_PAYMENT`) + `WebhookDispatcherService.dispatch('payment.confirmed')`.
- `CreditNoteService` → reversing journals (`JournalSourceType.INVOICE_CREDIT_NOTE`).
- `SalesReturnService` → `JournalSourceType.SALES_RETURN`.
- Currency: `DocumentCurrencyService.applySalesDocumentCurrency()`.
- Posting accounts: `resolvePostingMapping()`, `calculateLineVat()`, `TenantFinanceSettingsService`.

### Sales → HRMS
- `CommissionService.accrueCommission()` on invoice full payment (validates active `EmploymentContract`).
- `CreditNoteService` → `CommissionService.clawbackCommission()`.
- `SalesOrder.salesRepId`, `Partner.salesRepId` → `Employee`.

### Sales Flow
```
SalesOrder DRAFT
  → confirm (stock reserve via StockReservationService)
  → InvoiceService.createFromOrder (draft StockIssue)
  → InvoiceService.postInvoice (AR journal + completeIssue → stock↓ + COGS journal)
  → InvoicePaymentService.confirmPayment (cash journal + CommissionService.accrue)
```

---

## Procurement

### Procurement → Inventory
- `ProcurementReconciliationService.receiveOrder()` → `InventoryService.createReceipt()` (`ReceiptSourceType.PURCHASE`) → `completeReceipt()`.
- `InventoryService.completeReceipt()` → `syncPurchaseOrderFromReceipt()` updates `PurchaseOrderLine.qtyReceived` + PO status.

### Procurement → Finance
- `VendorBillService.postBill()` → `InventoryPostingService.postVendorBill()` (AP + inventory GL; `JournalSourceType.VENDOR_BILL`).
- `VendorPaymentService` → AP payment journals (`JournalSourceType.VENDOR_PAYMENT`).
- `LandedCostService.post()` → `JournalSourceType.LANDED_COST`.
- `PurchaseReturnService.confirm()` → `JournalSourceType.PURCHASE_RETURN`.
- Currency: `DocumentCurrencyService.applyPurchaseDocumentCurrency()`, `convertUnitCostToFunctional()`.

### Procurement → Sales
- `VendorBillService` → `ApprovalService` (Sales-owned) for high-value bill approval.
- `PurchaseOrder.partnerId`, `VendorBill.partnerId` → Sales `Partner`.

### Procurement Flow (3-way match)
```
PurchaseOrder RFQ → confirm
  → ProcurementReconciliationService.receiveOrder
    → InventoryService.completeReceipt (stock↑ + GRNI journal + sync PO qty_received)
  → VendorBillService.createFromOrder → postBill
    → InventoryPostingService.postVendorBill (AP journal + clear GRNI)
  → VendorPaymentService.recordPayment (AP payment journal)
```

---

## Inventory

### Inventory → Finance (GL bridge)
`InventoryPostingService` (`modules/inventory/services/inventory-posting.service.ts`):
| Method | Journal | Trigger |
|--------|---------|---------|
| `postStockReceipt()` | Dr Inventory / Cr GRNI or Purchases | `STOCK_RECEIPT` |
| `postStockIssue()` | Dr COGS / Cr Inventory | `STOCK_ISSUE` |
| `postStockAdjustmentReceipt()` | positive adjustments | `STOCK_ADJUSTMENT` |
| `postVendorBill()` | Dr Inventory+Input VAT / Cr AP; clears GRNI | `VENDOR_BILL` |
| `postPeriodEndClose()` | periodic inventory | `InventoryPeriodCloseService` |

- Called from `InventoryService.completeReceipt()` / `completeIssue()` after `InventoryMovementCostingService` updates quants/valuation.
- Periodic vs perpetual method gates journal writes (`TenantInventorySettingsService`).

### Inventory → Procurement
- `completeReceipt()` dynamically imports `syncPurchaseOrderFromReceipt()`.

---

## POS

### POS → Sales
- `PosService.syncOrders()` → `SalesOrder` + `SalesOrderLine` (`orderNumber` prefix `POS-`, status `CONFIRMED`).
- `PosReceiptService` reads `SalesOrder` for receipt HTML.

### POS → Inventory
- `PosService.checkStockAvailability()` → `InventoryBatchAllocationService.getSellableQuantity()`.
- Same check in `syncOrders()` before saving each offline order.

### POS → Finance
- `PosReceiptService` → `PrintTemplateService.getDefaultTemplate(PrintTemplateType.POS_RECEIPT)`.

### POS → Compliance
- `PosService` → `EtaSubmissionService.submitReceipt()` (optional auto eReceipt after sync).

### POS Flow (limited integration)
```
POS offline checkout
  → posSyncService POST /pos/sync
  → SalesOrder CONFIRMED only (stock check via InventoryBatchAllocationService)
  → NO auto-invoice, NO auto StockIssue
Receipt: GET /pos/receipt/:orderId via PrintTemplateService
```
Full AR/inventory posting requires standard sales invoice path.

---

## HRMS

### HRMS → Finance
- `PayrollService.finalizeAndPostPayroll()` → direct `JournalEntry` (salary expense Dr / salary payable Cr).
- Uses `resolvePostingMapping()` for `defaultSalaryExpenseAccountId` / `defaultSalaryPayableAccountId`.

### HRMS → Sales
- `PayrollService.createOrUpdatePayroll()` reads `SalesCommission` for employee `salesRepId` in pay period.
- `finalizeAndPostPayroll()` marks matching `SalesCommission` records `PAID`.

### HRMS Flow
```
PayrollService.createOrUpdatePayroll (pulls SalesCommission + attendance)
  → approve
  → finalizeAndPostPayroll (salary JournalEntry + mark commissions PAID)
```

### HRMS Gaps
- No Inventory or Procurement coupling.

---

## Finance (read/reconcile)

- Registers `Invoice`, `VendorBill` entities for `ArApGlReconciliationService`.
- `AgingReportService` — AR aging (`/sales/reports/ar-aging`) and AP aging (`/procurement/reports/ap-aging`).

---

## Frontend Cross-Module API Usage

| UI Surface | Cross-Module Calls |
|------------|-------------------|
| `SalesOrderForm` | `usePartners` (Sales), `useProducts`/`useStockLocations` (Inventory), `useListEmployees` (HRMS) |
| `SalesOrderDetailPage` | `useCreateInvoiceFromOrder` → `POST /sales/orders/:id/invoice`; `useOrderSellableStock` |
| `ReceiveOrderDialog` | `useReceiveOrder` → `POST /procurement/orders/:id/receive`; `useStockLocations` |
| `VendorBillDetailPage` | `POST /procurement/bills/:id/post` |
| `POSPage` | `useProducts`, `useStockLocations`, `usePartners`; `posSyncService` → `POST /pos/sync` |
| `PayrollPeriodPage` | `useCalculatePayrollPeriod`, `useFinalizePayroll` |
| Stock pages | Direct `/inventory/receipts`, `/inventory/issues` (separate from procurement receive path) |

### Key API Files
- `lib/api/mutations/useSales.ts`, `queries/useSales.ts`
- `lib/api/mutations/useProcurement.ts`, `queries/useProcurement.ts`
- `lib/api/mutations/useStockReceipts.ts`, `queries/useProducts.ts`
- `lib/api/mutations/useFinance.ts`, `queries/useFinance.ts`
- `lib/api/mutations/usePayroll.ts`, `queries/usePayroll.ts`
- `features/pos/posSyncService.ts`, `mutations/usePos.ts`

---

## Asymmetries & Gotchas
1. POS sync does **not** call `InvoiceService` or `InventoryService.createIssue()` — confirmed `SalesOrder` only.
2. Procurement receive goes through `ProcurementReconciliationService`, not standalone `/inventory/receipts` UI (both end in `InventoryService`).
3. `ApprovalService` is Sales-owned but gates both Invoice and VendorBill posting.
4. Periodic vs perpetual inventory method gates COGS/GRNI journal writes.
5. HRMS has no direct Inventory/Procurement integration.
