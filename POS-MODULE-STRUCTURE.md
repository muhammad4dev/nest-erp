# POS Module Structure Guide

## Quick Navigation

### Core Page

- **[POSPage.tsx](../../src/features/pos/pages/POSPage.tsx)** - Main orchestrator component (115 lines)
  - Handles layout, state management, and component orchestration
  - Delegates all UI rendering to sub-components
  - No business logic - pure orchestration

### Components Directory

`src/features/pos/components/`

#### Display Components

1. **[POSAppBar.tsx](../../src/features/pos/components/POSAppBar.tsx)** (120 lines)
   - Main application header
   - Shows: customer selector, cart badge, sync status, mobile menu
   - Responsive: different layouts for mobile/desktop

2. **[ProductGrid.tsx](../../src/features/pos/components/ProductGrid.tsx)** (200 lines)
   - Displays searchable product grid
   - Sub-components: SearchBar, ProductGridContent, ProductCard
   - Handles: loading, empty states, search filtering

3. **[CartPanelDesktop.tsx](../../src/features/pos/components/CartPanelDesktop.tsx)** (145 lines)
   - Desktop-only sidebar cart panel
   - Sub-components: CartSummary (shared with mobile)
   - Handles: cart display, summary, checkout

4. **[CartDrawerMobile.tsx](../../src/features/pos/components/CartDrawerMobile.tsx)** (200 lines)
   - Mobile-only bottom drawer cart
   - Sub-components: DrawerHeader, CartDrawerFooter, CartSummary (reused)
   - Handles: mobile cart display with clear/checkout actions

5. **[CustomerSelectionDialog.tsx](../../src/features/pos/components/CustomerSelectionDialog.tsx)** (120 lines)
   - Modal dialog for choosing customer
   - Sub-components: CustomerListItem
   - Adapts: full-screen on mobile, normal dialog on desktop

6. **[CartItemCard.tsx](../../src/features/pos/components/CartItemCard.tsx)** (150 lines)
   - Reusable card for individual cart item
   - Handles: quantity controls, discount input, remove action
   - Supports: compact mode for mobile

7. **[MobileMenuDrawer.tsx](../../src/features/pos/components/MobileMenuDrawer.tsx)** (130 lines)
   - Mobile-only top drawer menu
   - Sub-components: StatusSection, CartSection
   - Shows: sync controls, cart summary, quick actions

### Custom Hooks Directory

`src/features/pos/hooks/`

1. **[usePOSUIState.ts](../../src/features/pos/hooks/usePOSUIState.ts)** (30 lines)
   - Centralizes UI state management
   - Manages: dialogs, drawers, search, loading
   - Returns: search query, dialog/drawer states, checkout loading

   ```typescript
   const {
     searchQuery,
     setSearchQuery,
     customerDialogOpen,
     setCustomerDialogOpen,
     cartDrawerOpen,
     setCartDrawerOpen,
     mobileMenuOpen,
     setMobileMenuOpen,
     checkoutLoading,
     setCheckoutLoading,
   } = usePOSUIState();
   ```

2. **[useProductFilter.ts](../../src/features/pos/hooks/useProductFilter.ts)** (20 lines)
   - Filters products by search query
   - Memoized for performance
   - Searches: name and SKU fields

   ```typescript
   const filteredProducts = useProductFilter(products, searchQuery);
   ```

3. **[usePOSCheckout.ts](../../src/features/pos/hooks/usePOSCheckout.ts)** (45 lines)
   - Manages checkout flow and error handling
   - Callbacks: start, end, customer-required, success, error
   - Returns: handleCheckout function

   ```typescript
   const { handleCheckout } = usePOSCheckout({
     selectedCustomer,
     checkout,
     onCheckoutStart: () => setCheckoutLoading(true),
     onCheckoutEnd: () => setCheckoutLoading(false),
     onCustomerRequired: () => setCustomerDialogOpen(true),
     onCheckoutSuccess: () => { ... },
     onCheckoutError: (error) => { ... },
   });
   ```

### Unchanged Core Files

- **[posStore.ts](../../src/features/pos/posStore.ts)** - Zustand store (unchanged)
- **[posDatabase.ts](../../src/features/pos/posDatabase.ts)** - Dexie IndexedDB (unchanged)
- **[posRoutes.ts](../../src/features/pos/posRoutes.ts)** - Route config (unchanged)

## Data Flow

```
POSPage (Orchestrator)
    ↓
├─ usePOSStore() ──────────────→ [cartLines, selectedCustomer, ...]
├─ useProducts() ───────────────→ [products, isLoading]
├─ usePartners() ───────────────→ [partners]
├─ usePOSUIState() ─────────────→ [searchQuery, dialogOpen, ...]
├─ useProductFilter() ──────────→ [filteredProducts]
└─ usePOSCheckout() ────────────→ [handleCheckout]
    ↓
Render Components (Receive Props Only)
    ├─ <POSAppBar />
    ├─ <MobileMenuDrawer />
    ├─ <ProductGrid />
    ├─ <CartPanelDesktop /> OR <CartDrawerMobile />
    └─ <CustomerSelectionDialog />
        ↓
    Sub-components (Atomic)
        ├─ <StatusSection />
        ├─ <SearchBar />
        ├─ <ProductCard />
        ├─ <CartItemCard />
        ├─ <CartSummary />
        └─ <CustomerListItem />
```

## Component Responsibilities

| Component               | Responsibility           | Props In            | Events Out               |
| ----------------------- | ------------------------ | ------------------- | ------------------------ |
| POSPage                 | Orchestration & layout   | (none)              | (none)                   |
| POSAppBar               | Header UI                | status, customer    | onSelect, onSync, onMenu |
| ProductGrid             | Product display & search | products, search    | onSearch, onSelect       |
| CartPanelDesktop        | Desktop cart sidebar     | cart, items         | onCheckout, onUpdate     |
| CartDrawerMobile        | Mobile cart drawer       | cart, items         | onCheckout, onClear      |
| CartItemCard            | Single cart item         | item, product       | onUpdate, onRemove       |
| CustomerSelectionDialog | Customer picker          | customers, selected | onSelect, onClose        |
| MobileMenuDrawer        | Mobile menu              | status, cart        | onSync, onViewCart       |

## Type System

### Reusable Types

```typescript
// From CartItemCard
export type CartLineItem = {
  productId: string;
  product: Product;
  quantity: number;
  unitPrice: number;
  discountRate: number;
};
```

### Component Props

All components have explicit `Props` interfaces:

- `CartPanelDesktopProps`
- `CartDrawerMobileProps`
- `CartItemCardProps`
- `ProductGridProps`
- `POSAppBarProps`
- `CustomerSelectionDialogProps`
- `MobileMenuDrawerProps`

## Adding New Features

### Example: Add "Apply Coupon Code"

1. **Add hook** (`hooks/useCoupon.ts`):

   ```typescript
   export function useCoupon() {
     const [couponCode, setCouponCode] = useState('');
     const applyCoupon = useCallback((code: string) => { ... }, []);
     return { couponCode, setCouponCode, applyCoupon };
   }
   ```

2. **Update POSPage**:

   ```typescript
   const { couponCode, applyCoupon } = useCoupon();
   ```

3. **Create component** (`components/CouponInput.tsx`):

   ```typescript
   export function CouponInput({ value, onChange, onApply }) { ... }
   ```

4. **Integrate in CartPanelDesktop/CartDrawerMobile**:
   ```typescript
   <CouponInput
     value={couponCode}
     onChange={setCouponCode}
     onApply={applyCoupon}
   />
   ```

## Testing Guide

### Unit Test Components

```typescript
import { render, screen } from '@testing-library/react';
import { CartItemCard } from './CartItemCard';

describe('CartItemCard', () => {
  it('increments quantity', () => {
    const mockUpdate = jest.fn();
    render(<CartItemCard line={mockLine} updateCartLine={mockUpdate} />);

    fireEvent.click(screen.getByTitle('Increase quantity'));
    expect(mockUpdate).toHaveBeenCalledWith(
      mockLine.productId,
      { quantity: 2 }
    );
  });
});
```

### Unit Test Hooks

```typescript
import { renderHook, act } from "@testing-library/react";
import { useProductFilter } from "./useProductFilter";

describe("useProductFilter", () => {
  it("filters by name", () => {
    const products = [
      { id: "1", name: "Apple", sku: "APP" },
      { id: "2", name: "Banana", sku: "BAN" },
    ];

    const { result } = renderHook(() => useProductFilter(products, "Apple"));

    expect(result.current).toHaveLength(1);
    expect(result.current[0].name).toBe("Apple");
  });
});
```

## Performance Tips

1. **Memoize Components**: Wrap components that receive many props with `React.memo`
2. **Memoize Callbacks**: Use `useCallback` for event handlers
3. **Lazy Load**: Code-split components using `React.lazy()`
4. **Avoid Inline Objects**: Move prop objects outside of JSX

## Documentation Links

- [Full Refactoring Summary](./POS-REFACTORING-SUMMARY.md)
- [Responsive Design](./POS-RESPONSIVE-DESIGN.md)
- [UX Improvements](./POS-UX-IMPROVEMENTS.md)
- [Quick Start Guide](./POS-QUICK-START.md)

## Summary

The POS module now follows clean architecture principles:

- ✅ **Single Responsibility**: Each component/hook has one job
- ✅ **High Cohesion**: Related code is grouped together
- ✅ **Loose Coupling**: Components depend only on props/callbacks
- ✅ **Type Safe**: 100% TypeScript coverage with zero errors
- ✅ **Testable**: Each component and hook can be tested independently
- ✅ **Maintainable**: Easy to locate and modify features
- ✅ **Scalable**: New features can be added without touching existing code
