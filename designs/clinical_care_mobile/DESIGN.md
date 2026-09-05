---
name: Clinical Care Mobile
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#3f4850'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#707881'
  outline-variant: '#bfc7d2'
  surface-tint: '#006398'
  primary: '#006194'
  on-primary: '#ffffff'
  primary-container: '#007bb9'
  on-primary-container: '#fdfcff'
  inverse-primary: '#93ccff'
  secondary: '#1b6d24'
  on-secondary: '#ffffff'
  secondary-container: '#a0f399'
  on-secondary-container: '#217128'
  tertiary: '#b7131a'
  on-tertiary: '#ffffff'
  tertiary-container: '#db322f'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cce5ff'
  primary-fixed-dim: '#93ccff'
  on-primary-fixed: '#001d31'
  on-primary-fixed-variant: '#004b73'
  secondary-fixed: '#a3f69c'
  secondary-fixed-dim: '#88d982'
  on-secondary-fixed: '#002204'
  on-secondary-fixed-variant: '#005312'
  tertiary-fixed: '#ffdad6'
  tertiary-fixed-dim: '#ffb4ac'
  on-tertiary-fixed: '#410002'
  on-tertiary-fixed-variant: '#93000d'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  headline-xl:
    fontFamily: Manrope
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
  headline-xl-mobile:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '800'
    lineHeight: 36px
  headline-lg:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  headline-md:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 26px
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 18px
  label-md:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Manrope
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 12px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  space-2xs: 0.125rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-base: 1rem
  space-lg: 1.25rem
  space-xl: 1.5rem
  space-2xl: 2rem
  space-3xl: 3rem
  screen-edge-mobile: 1rem
  gutter-mobile: 0.75rem
  card-padding-mobile: 1rem
---

## Brand & Style

The brand personality embodies clinical rigor blended with patient-first empathy. Built for a rapid-response mobile pharmaceutical ecosystem, the UI projects unwavering medical authority, verified trust, and frictionless medication management.

The design movement is **Modern Clinical Precision**:
- Pristine, health-tinted white canvases paired with layered analytical surfaces.
- Crisp clinical iconography and structured data cards that streamline ordering, dosage schedules, and prescription verifications.
- Accessible, high-legibility visual density tuned for patients, caregivers, and wholesale healthcare providers navigating critical medication workflows on mobile devices.
- Subtle, luminous interaction states that provide immediate visual feedback without creating visual fatigue.

## Colors

The palette establishes a strict medical hierarchy rooted in clinical dependability and verified safety:

- **Primary (`#0284C7`)**: Clinical Sky Blue serves as the core interactive engine—driving main navigation bars, primary action buttons, dosage timelines, and verification seals.
- **Secondary (`#2E7D32`)**: Medical Leaf Green represents safety, wellness, in-stock inventory confirmation, and order fulfillment status.
- **Tertiary (`#E53935`)**: Medical Cross Red is strictly reserved for critical alerts, emergency prescription notices, counter-indication flags, and urgent re-fill indicators.
- **Neutral (`#0F172A`)**: Deep Slate Black ensures maximum legible contrast for dosage units, pharmaceutical labels, and clinical disclaimers against crisp off-white (`#F8FAFC`) and pure white (`#FFFFFF`) card surfaces.
- **Subtle Health Tints**: Backgrounds utilize an ultra-clean, cool wash (`#F0F9FF` to `#F8FAFC`) to minimize glare while preserving a sterile, high-end dispensary aesthetic.

## Typography

Manrope delivers a geometric balance of humanist openness and technical precision. Its geometric numbers and tall x-height make drug names, strength ratios (e.g., "500 mg"), and dosage timestamps instantly decipherable across all mobile screen densities.

- **Headlines (`headline-xl`, `headline-lg`, `headline-md`)**: Weighted heavily (700/800) to anchor pharmacy catalog categories, prescription tracking headers, and doctor consult banners.
- **Body (`body-lg`, `body-md`, `body-sm`)**: Neutral, open rhythm ensuring high readability for drug interactions, side effects, and patient instructions.
- **Labels & Microcopy (`label-lg`, `label-md`, `label-sm`)**: High-contrast, semi-bold to bold weights used for inventory badges, prescription verification tags, and dosage frequencies.

## Layout & Spacing

The mobile layout operates on a standard 4-column fluid mobile grid with 16px (`screen-edge-mobile`) safe margins and 12px (`gutter-mobile`) column gutters. Content scales cleanly into a 12-column layout on tablet and desktop interfaces.

- **Vertical Rhythm**: Built upon a strict 4px/8px incremental rhythm. Spacing within prescription cards is tightly bounded (`space-sm` to `space-base`) to keep pertinent medication details above the fold.
- **Touch Targets**: All primary interactive buttons, dosage stepper triggers, and navigation tabs adhere to a minimum 48px hit boundary.
- **Thumb-Zone Architecture**: Actionable checkout buttons, order tracking floating sheets, and pharmacist direct-call triggers are locked to the bottom viewport zone for single-handed mobile ergonomic safety.

## Elevation & Depth

Visual hierarchy uses clean clinical depth rather than heavy, dirty drop shadows:

- **Level 0 (Base Canvas)**: Neutral clinical canvas (`#F8FAFC`) with zero elevation.
- **Level 1 (Clinical Cards & Catalog Tiles)**: Surface pure white (`#FFFFFF`) with a hair-thin 1px border (`#E2E8F0`) and an ambient tinted shadow: `0 1px 3px rgba(2, 132, 199, 0.04), 0 1px 2px rgba(15, 23, 42, 0.03)`.
- **Level 2 (Active Sheets & Prescription Slips)**: Soft elevated cards with a distinct medical lift: `0 4px 12px rgba(2, 132, 199, 0.08), 0 2px 4px rgba(15, 23, 42, 0.04)`.
- **Level 3 (Modal Alerts & Bottom Action Trays)**: Elevated mobile navigation drawers and checkout triggers: `0 12px 28px rgba(15, 23, 42, 0.12), 0 4px 8px rgba(2, 132, 199, 0.06)`.
- **Luminous Glowing Accents**: Primary action buttons and high-priority health alerts utilize an inner micro-highlight paired with an external primary tint blur (`0 4px 14px rgba(2, 132, 199, 0.30)`) to signal instant tap-readiness.

## Shapes

The design uses a clean, architectural soft geometry (level 1):

- **Default Elements (`0.25rem` / 4px)**: Input fields, table cells, and discrete verification icons.
- **Cards & Banners (`rounded-lg` / 8px)**: Standard product cards, pharmacy wholesale tiles, and delivery tracking summaries.
- **Primary Cards & Overlays (`rounded-xl` / 12px)**: Large prescription review sheets, consultation bottom sheets, and medical alert dialogs.
- **Trust Seals & Badges**: Fully circular or soft-pill capsular enclosures used for verification checkmarks, cold-chain storage indicators, and Rx status badges.

## Components

### Buttons
- **Primary Action**: Solid Clinical Sky Blue (`#0284C7`) background with white bold Manrope typography. Subtle upper border highlight with soft blue bloom shadow (`rgba(2, 132, 199, 0.28)`).
- **Secondary (Pharmacy Success / Express Reorder)**: Solid Medical Leaf Green (`#2E7D32`) background with white text for completed prescriptions and bulk reorders.
- **Tertiary / Ghost**: Transparent fill, 1px clinical border (`#BAE6FD`), primary blue text for secondary actions like "View Pharmacist Notes."

### Chips & Health Badges
- **Prescription Verified**: Light green tint (`#DCFCE7`), solid green border (`#86EFAC`), `#166534` text with leading shield icon.
- **Urgent Refill / Low Stock**: Light red tint (`#FEE2E2`), border (`#FCA5A5`), `#991B1B` text with alert cross icon.
- **Cold Chain Certified / Bulk Wholesale**: Light cyan tint (`#E0F2FE`), border (`#7DD3FC`), `#075985` text.

### Cards
- **Medication Item Card**: Pure white background, 1px border (`#E2E8F0`), containing product imagery, brand name, generic chemical identifier, stock indicator chip, and an instant-add stepper.
- **Prescription Dossier Card**: Tonal surface with light cyan header (`#F0F9FF`), patient ID, doctor signature validation seal, and itemized dosage schedule.

### Inputs & Dosage Selectors
- **Form Inputs**: Crisp off-white backgrounds, 1px neutral slate borders (`#CBD5E1`), transitioning to a crisp 2px Sky Blue ring on focus with zero color bleed.
- **Quantity Steppers**: Rounded compact pill buttons with clear tactile increment/decrement cues.

### Trust Seals & Wholesale Banners
- **Authenticity Lockup**: Double-ringed badge incorporating clinical blue and medical green rings, paired with bold verification microcopy for wholesale pharmaceutical authenticity.