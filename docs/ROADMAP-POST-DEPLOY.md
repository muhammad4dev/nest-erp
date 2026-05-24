# Roadmap features — post-deploy configuration

After running migrations `1771000000000` through `1772310000000`:

1. **Posting account mappings** — set `default_sales_returns_account_id` for credit notes; set payroll salary expense/payable accounts.
2. **Credit enforcement** — `tenant_finance_settings.credit_enforcement_mode` (`OFF` / `WARN` / `BLOCK`, default `WARN`).
3. **Permissions** — assign `reverse:invoice_payment` and `reverse:vendor_payment` to finance roles.
4. **Approvals** — invoices/vendor bills ≥ 50,000 functional require an approved `approval_requests` row before posting.
5. **Cheques** — enable `cheque_tracking_enabled` on tenant finance settings when using cheque fields on payments.
6. **Webhooks** — configure subscriptions under Finance → Event Integrations; see [WEBHOOK-INTEGRATIONS.md](./WEBHOOK-INTEGRATIONS.md) for events, HMAC verification, retries, and in-app fallback.
7. **RLS** — re-run `backend/src/database/scripts/rls_setup.sql` if new tenant-scoped tables were added before the script last ran.

New tenant-scoped tables covered by the dynamic RLS script when `tenant_id` is present:

- `stock_reservations`, `delivery_notes`, `delivery_note_lines`
- `price_lists`, `price_list_lines`
- `approval_requests`, `webhook_subscriptions`, `webhook_delivery_logs`, `webhook_delivery_outbox`
- `saved_reports`, `eta_submission_outbox`
- `bank_accounts`, `bank_statement_imports`, `bank_statement_lines`
