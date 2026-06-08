# 05 — React Hooks ESLint (React 19)

Load when writing/fixing `frontend/src/**/*.{ts,tsx}`. Enforced by `eslint-plugin-react-hooks` (recommended) + React Compiler.

Run: `pnpm lint:fix` in `frontend/`.

## Rules That Break Builds

### `react-hooks/set-state-in-effect`
No synchronous `setState` in `useEffect` / `useLayoutEffect` bodies (including via helpers like `close()` that call `setState`).

### `react-hooks/refs`
No `ref.current` read/write during render. Refs only in effects, event handlers, or callbacks.

---

## Approved Patterns

### Derive during render (visibility, flags)
```tsx
const shouldPrompt = isAuthenticated && isSuccess && items.length === 0;
const visible = shouldPrompt && !manuallyDismissed;
```

### Reset state when props/key changes (dialogs, forms)
```tsx
const dialogKey = open ? entity.id : null;
const [initializedFor, setInitializedFor] = useState<string | null>(null);

if (dialogKey && dialogKey !== initializedFor) {
  setInitializedFor(dialogKey);
  setFormState(initialValue);
  setError(null);
}
if (!dialogKey && initializedFor !== null) setInitializedFor(null);
```

### Dialog error reset — use transition callbacks, not effects
```tsx
<Dialog
  slotProps={{ transition: { onEntered: () => setFormError(null) } }}
  onClose={() => { setFormError(null); onClose(); }}
/>
```

### Display values in JSX — use state, not refs
```tsx
// ❌ lastOrderIdRef.current in JSX
// ✅
const [lastOrderId, setLastOrderId] = useState<string | null>(null);
setLastOrderId(orderId); // in event/success handler
```

### Sync props to local state — render-time key check
```tsx
const [syncedId, setSyncedId] = useState(initialData?.id);
if (initialData && initialData.id !== syncedId) {
  setSyncedId(initialData.id);
  setLocalField(initialData.field);
}
// form.reset(...) may stay in useEffect — linter only flags setState there
```

### Custom hooks — refs updated in effects; derive inactive state
```tsx
useEffect(() => { urlRef.current = url; }, [url]);

const isActive = Boolean(url && enabled);
const status = isActive ? connectionStatus : "closed";

useEffect(() => {
  if (url && enabled) connect();
  else cleanup(); // not close() if close() calls setState
  return cleanup;
}, [url, enabled]);
```

### Side effects without setState in effect
```tsx
useEffect(() => {
  if (isSuccess && items.length > 0) clearExternalFlag();
}, [isSuccess, items]);
```

---

## Anti-Patterns

| ❌ Avoid | ✅ Use instead |
|----------|----------------|
| `useEffect(() => setVisible(...), [deps])` | Derive `visible` from deps + local dismiss flag |
| `useEffect(() => { form.reset(); setError(null) }, [open])` | `form.reset` in effect; `setError` in `onEntered` / `handleClose` |
| `useEffect(() => setSelectedIds(...), [open, entity])` | Render-time `dialogKey` reset pattern |
| `ref.current = value` during render | `useEffect(() => { ref.current = value }, [value])` |
| `ref.current` in JSX | `useState` for displayed values |
| `useEffect(() => close(), [enabled])` where `close` sets state | `cleanup()` only; derive status when inactive |

---

## High-Risk Locations in This Repo
- `*FormDialog.tsx`, `*PermissionsDialog.tsx`, `*RoleDialog.tsx` — open/reset cycles
- `*SetupPrompt.tsx`, `*Panel.tsx` — conditional visibility from queries
- `features/pos/pages/POSPage.tsx` — post-checkout display data
- `shared/hooks/useSSE.ts` — ref mirrors + connection lifecycle
- Any `useEffect` that syncs props → local `useState`

---

## Do Not
- Disable `react-hooks/set-state-in-effect` or `react-hooks/refs` without team approval.
- Use `eslint-disable` for these rules in feature code.
- Reach for `useEffect` to copy props into state when render-time sync or form `reset` suffices.
