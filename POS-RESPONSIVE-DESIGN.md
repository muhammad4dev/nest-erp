# POS Responsive Design System

## Breakpoints

The POS system uses Material-UI's standard breakpoints with custom adjustments:

```typescript
// Material-UI Standard Breakpoints
xs: 0px      // Mobile phones
sm: 600px    // Small tablets
md: 960px    // Tablets/Small desktops
lg: 1280px   // Desktops
xl: 1920px   // Large desktops
```

## Layout Strategies

### Mobile-First Approach

1. **Design for smallest screens first** (mobile)
2. **Layer on features for larger screens**
3. **Test at real breakpoints** with actual devices

### Responsive Patterns Used

#### 1. **Flex Layout with Breakpoint-Based Direction**

```tsx
<Box
  sx={{
    display: "flex",
    flexDirection: { xs: "column", md: "row" }, // Column on mobile, row on desktop
    gap: { xs: 1, md: 2 }, // Smaller gap on mobile
  }}
>
  {/* Content */}
</Box>
```

#### 2. **Conditional Rendering Based on Screen Size**

```tsx
const isMobile = useMediaQuery(theme.breakpoints.down("md"));
const isTablet = useMediaQuery(theme.breakpoints.between("md", "lg"));

{
  !isMobile && <CartPanelDesktop />;
}
{
  isMobile && <CartDrawerMobile />;
}
```

#### 3. **Responsive Sizing**

```tsx
<Button
  size={isMobile ? "small" : "medium"}
  sx={{
    fontSize: { xs: "0.75rem", md: "0.875rem" },
    px: { xs: 1, md: 2 },
  }}
>
  Action
</Button>
```

#### 4. **CSS Grid with Auto-Columns**

```tsx
<Box
  sx={{
    display: "grid",
    gridTemplateColumns: {
      xs: "repeat(auto-fill, minmax(120px, 1fr))",
      sm: "repeat(auto-fill, minmax(150px, 1fr))",
      md: "repeat(auto-fill, minmax(180px, 1fr))",
    },
    gap: 2,
  }}
>
  {/* Items */}
</Box>
```

## Component Sizing Guidelines

### Touch Targets (Mobile)

- **Minimum Size**: 44px × 44px for interactive elements
- **Preferred Size**: 48px × 48px for frequently used buttons
- **Spacing**: At least 8px between adjacent targets

### Text Sizing

```typescript
// Mobile
xs: {
  h6: "1rem",      // Headings
  body2: "0.875rem",
  caption: "0.75rem",
}

// Desktop
md: {
  h6: "1.25rem",
  body2: "1rem",
  caption: "0.875rem",
}
```

### Button Sizing Strategy

```tsx
// Mobile: Use "small" size, full width when possible
<Button size={isMobile ? "small" : "medium"} fullWidth={isMobile}>

// Desktop: Use "medium" or "large", natural width
<Button size="large" sx={{ width: "auto" }}>
```

## Spacing System

### Responsive Padding/Margin

```tsx
sx={{
  p: { xs: 1, sm: 1.5, md: 2 },    // 8px → 12px → 16px
  mb: { xs: 1, md: 2 },            // 8px → 16px
  gap: { xs: 1, md: 2 },           // Flexible spacing
}}
```

### Safe Areas on Mobile

Consider notches and home indicators:

```tsx
sx={{
  p: { xs: 2, md: 3 },
  pb: { xs: "calc(2rem + env(safe-area-inset-bottom))", md: "2rem" },
}}
```

## Navigation Patterns

### Mobile Navigation

```
┌─────────────────────┐
│ [Title] ... [Menu]  │
├─────────────────────┤
│   Main Content      │
│                     │
└─────────────────────┘
      [FAB/Action]      <- Bottom action
```

**Benefits:**

- Menu button triggers drawer/bottom-sheet
- Content takes full width
- Actions at thumb-friendly bottom area

### Desktop Navigation

```
┌──────────────────────────────────┐
│ [Logo] Title [Status] [Actions]  │
├───────────────────┬──────────────┤
│   Primary Area    │  Secondary   │
│                   │    Area      │
└───────────────────┴──────────────┘
```

**Benefits:**

- All actions visible in header
- Horizontal space for side panel
- Efficient use of screen real estate

## Form Input Responsive Design

### Text Fields

```tsx
// Mobile-optimized
<TextField
  size="small"
  fullWidth
  inputProps={{
    fontSize: { xs: "0.875rem", md: "1rem" },
  }}
/>

// Desktop
<TextField
  size="medium"
  sx={{ maxWidth: 300 }}
/>
```

### Number Input (Quantity/Discount)

```tsx
// Width that works on all screens
<TextField
  type="number"
  sx={{
    width: { xs: 60, md: 80 },
    "& .MuiInputBase-input": {
      textAlign: "center",
    },
  }}
  inputProps={{ min: 1, step: 1 }}
/>
```

## Modal & Drawer Patterns

### Mobile Modal Strategy

```tsx
// Full screen on mobile
<Dialog
  fullScreen={isMobile}
  maxWidth="sm"
/>

// Or use Drawer
<Drawer
  anchor="bottom"
  PaperProps={{
    sx: {
      maxHeight: "90vh",
      borderTopLeftRadius: 16,
      borderTopRightRadius: 16,
    }
  }}
/>
```

### Desktop Modal Strategy

```tsx
// Constrained size on desktop
<Dialog fullScreen={false} maxWidth="sm" fullWidth />
```

## Image & Media Handling

### Responsive Images

```tsx
<Box
  component="img"
  src={product.image}
  sx={{
    width: { xs: "100%", md: "80%" },
    maxHeight: { xs: 200, md: 400 },
    objectFit: "cover",
    borderRadius: 1,
  }}
/>
```

## Typography Responsiveness

### Heading Hierarchy

```tsx
// Mobile-first
<Typography
  variant="h6"
  sx={{
    fontSize: { xs: "1rem", md: "1.25rem" },
    lineHeight: { xs: 1.4, md: 1.5 },
  }}
>
  Product Name
</Typography>
```

### Line Length

- Mobile: 20-40 characters
- Tablet: 40-60 characters
- Desktop: 60-80 characters

```tsx
sx={{
  maxWidth: { xs: "90vw", md: "100%" },
  wordBreak: "break-word",
}}
```

## Color & Contrast

### Accessibility on Small Screens

- Higher contrast needed (WCAG AA minimum 4.5:1)
- Avoid small colored text (< 12px)
- Test with actual mobile devices

### Dark Mode Considerations

```tsx
// Adaptive backgrounds
bgcolor: {
  light: "background.paper",
  dark: "background.default",
}
```

## Animation & Transitions

### Mobile-Optimized Animations

```tsx
sx={{
  transition: theme.transitions.create(
    ["transform", "box-shadow"],
    {
      duration: theme.transitions.duration.shorter, // 150ms
      easing: theme.transitions.easing.easeInOut,
    }
  ),
  "&:hover": {
    transform: isMobile ? "none" : "translateY(-4px)", // Disable on mobile
  },
}}
```

### Performance Tips

- Disable complex animations on low-end mobile devices
- Use GPU-accelerated properties (transform, opacity)
- Avoid animating layout properties (width, height)

## Scrolling Behavior

### Mobile Scrolling

```tsx
sx={{
  overflowY: "auto",
  WebkitOverflowScrolling: "touch", // Smooth momentum scrolling
  scrollBehavior: "smooth",
}}
```

### Pull-to-Refresh

Currently handled by browser, consider adding for offline apps:

```typescript
// Future enhancement: custom pull-to-refresh
window.addEventListener("touchmove", (e) => {
  if (scrollTop === 0) {
    // Handle pull-to-refresh
  }
});
```

## Grid System Best Practices

### Column Distribution

```typescript
// Mobile: 1 column, or auto-fill based on item width
xs: "repeat(auto-fill, minmax(100px, 1fr))"

// Tablet: 2-3 columns
sm: "repeat(2, 1fr)" or "repeat(3, 1fr)"

// Desktop: 4+ columns
md: "repeat(auto-fill, minmax(200px, 1fr))"
```

### Aspect Ratio Management

```tsx
<Box
  sx={{
    aspectRatio: "1",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
  }}
>
  {/* Content maintains 1:1 ratio */}
</Box>
```

## Testing Responsive Design

### Breakpoint Testing

```typescript
// Test at exact breakpoints
const breakpoints = [
  375, // iPhone SE
  390, // iPhone 12
  410, // Pixel
  600, // Tablet portrait
  768, // iPad
  1024, // iPad landscape
  1440, // Desktop HD
];
```

### Device Orientation

```tsx
const isLandscape = useMediaQuery("(orientation: landscape)");

sx={{
  flexDirection: isMobile && isLandscape ? "row" : "column",
}}
```

### Touch vs Mouse

```tsx
const isTouch = useMediaQuery("(hover: none)");

sx={{
  "&:hover": {
    // Skip hover effects on touch devices
    ...(isTouch ? {} : { boxShadow: 2 })
  },
}}
```

## Performance Optimization

### Code Splitting by Breakpoint

```tsx
// Load heavy components only on desktop
const CartPanel = isMobile
  ? lazy(() => import("./CartDrawerMobile"))
  : lazy(() => import("./CartPanelDesktop"));
```

### Image Optimization

```tsx
// Serve appropriately sized images
<picture>
  <source srcSet={smallImage} media="(max-width: 600px)" />
  <source srcSet={largeImage} media="(min-width: 601px)" />
  <img src={defaultImage} />
</picture>
```

## Common Pitfalls to Avoid

❌ **Don't:**

- Use fixed widths (use percentages or max-width)
- Assume landscape orientation on mobile
- Forget about notches and safe areas
- Use tiny fonts on mobile
- Ignore touch target sizes
- Test only in DevTools (use real devices!)

✅ **Do:**

- Test on actual mobile devices
- Use flexible layouts
- Test both portrait and landscape
- Check safe areas for notched devices
- Use semantic HTML
- Provide keyboard navigation
- Test with screen readers
- Consider offline functionality

## Design Decision Matrix

| Feature         | Mobile        | Tablet     | Desktop    |
| --------------- | ------------- | ---------- | ---------- |
| Cart Position   | Bottom Drawer | Side Panel | Side Panel |
| Product Columns | 1-2           | 3-4        | 4-5        |
| Button Size     | Small         | Medium     | Medium     |
| Search          | Full Width    | Full Width | 300px      |
| Header Items    | Menu          | Normal     | Normal     |
| Touch Targets   | 44px+         | 40px+      | 32px+      |

## Future Considerations

### Responsive Typography Enhancements

- [ ] Implement fluid typography scaling
- [ ] Use CSS `clamp()` for responsive sizing
- [ ] Test with system fonts

### Gesture Support

- [ ] Swipe to delete items
- [ ] Long-press for context menu
- [ ] Pinch to zoom on images

### Accessibility Improvements

- [ ] High contrast mode support
- [ ] Reduced motion support
- [ ] Screen reader optimization

### Performance Enhancements

- [ ] Virtual scrolling for long product lists
- [ ] Progressive image loading
- [ ] Code splitting by breakpoint
