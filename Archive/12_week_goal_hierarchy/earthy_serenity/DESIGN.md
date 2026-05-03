# Design System Document: Tactical Serenity

## 1. Overview & Creative North Star: "The Breathing Canvas"
This design system rejects the frantic, high-contrast density of traditional digital interfaces. Our Creative North Star is **"The Breathing Canvas"**—an editorial approach where the UI feels less like a software tool and more like a curated, physical space. 

We break the "template" look by prioritizing negative space as a functional element rather than a void. By utilizing intentional asymmetry, oversized margins, and soft tonal layering, we create a rhythmic flow that guides the eye without demanding its attention. The goal is an "organized but gentle" experience where every interaction feels like a deep breath.

---

## 2. Colors: Tonal Atmosphere
Our palette moves away from digital vibrancy toward organic, light-absorbing tones. 

### The "No-Line" Rule
**Explicit Instruction:** 1px solid borders are strictly prohibited for sectioning or containment. Boundaries must be defined solely through background color shifts or subtle tonal transitions. For example, a `surface-container-low` section should sit directly against a `surface` background to define its area.

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked, fine papers. 
- **Base Layer:** `surface` (#fafaf5)
- **Nested Content:** Use `surface-container-low` (#f3f4ee) for secondary content areas.
- **Elevated Focus:** Use `surface-container-lowest` (#ffffff) for primary cards or interactive modules to create a "lifted" feel against the cream base.

### The "Glass & Gradient" Rule
To add "soul," use a signature subtle gradient for Hero backgrounds or primary CTAs: transitioning from `primary` (#4d654a) to `primary-container` (#ceeac7) at a 135-degree angle. For floating navigation or overlays, apply **Glassmorphism**: use `surface` at 80% opacity with a `24px` backdrop-blur to allow underlying sage and cream tones to bleed through.

---

## 3. Typography: Approachable Authority
We use a dual-typeface system to balance character with extreme legibility.

*   **Display & Headlines (Plus Jakarta Sans):** A modern, soft sans-serif with friendly apertures. Use `display-lg` (3.5rem) with generous letter-spacing (-0.02em) to create an editorial, high-end feel.
*   **Body & UI (Be Vietnam Pro):** Chosen for its exceptional readability and "honest" character. The `body-lg` (1rem) should be the default for most reading experiences to prevent eye strain.
*   **Color Note:** Never use pure black. All text should utilize `on-surface` (#2f342e) or `on-surface-variant` (#5c605a) to maintain a soft, charcoal-like contrast that is gentle on the eyes.

---

## 4. Elevation & Depth: Tonal Layering
We convey hierarchy through material weight rather than artificial shadows.

*   **The Layering Principle:** Depth is achieved by "stacking." Place a `surface-container-lowest` card on a `surface-container-high` background to create natural prominence.
*   **Ambient Shadows:** If a floating element (like a FAB or Menu) requires a shadow, it must be ultra-diffused. 
    *   *Spec:* `Y: 12px, Blur: 40px, Color: #2f342e at 6% opacity`. This mimics natural light filtered through a soft lens.
*   **The "Ghost Border" Fallback:** If accessibility requires a container edge, use a "Ghost Border": `outline-variant` (#afb3ac) at 15% opacity. Never use 100% opaque lines.
*   **Motion Depth:** When elements move, they should "fade and slide" using a `cubic-bezier(0.4, 0, 0.2, 1)` easing, mimicking the weight of physical paper.

---

## 5. Components: Soft & Intentional

### Buttons
*   **Primary:** Background: `primary` (#4d654a); Text: `on-primary` (#eaffe3). Shape: `full` (9999px) for a "pebble" feel.
*   **Secondary:** Background: `secondary-container` (#efe0cf); Text: `on-secondary-container` (#5a5043). 
*   **States:** On hover, use a `primary-dim` shift; do not use heavy shadows.

### Cards & Lists
*   **The Divider Ban:** Absolute prohibition of horizontal rules. Use `1.5rem` to `2rem` of vertical whitespace (the Spacing Scale) to separate items. 
*   **Cards:** Use `lg` (2rem) corner radius. Use `surface-container-lowest` for the card body against a `surface-container` background.

### Input Fields
*   **Style:** No bottom-line only inputs. Use a soft-filled container (`surface-container-high`) with `sm` (0.5rem) rounding. 
*   **Focus:** Indicate focus via a 2px `primary` Ghost Border (20% opacity) and a subtle shift to `surface-container-highest`.

### Signature Component: The "Zen Tray"
A specialized bottom-sheet or side-panel using `surface-container-lowest` with a `xl` (3rem) corner radius on the leading edge. It should utilize Glassmorphism to feel integrated into the "Breathing Canvas."

---

## 6. Do’s and Don’ts

### Do:
*   **Do** embrace asymmetry. Center-aligning everything feels like a template; offset your headlines to create a sophisticated, editorial rhythm.
*   **Do** use "Sage Breathing Room." Ensure the distance between unrelated sections is at least `4rem` to maintain the "Serene Life" promise.
*   **Do** use `primary-fixed-dim` for subtle icons or decorative elements to maintain the earthy, organic vibe.

### Don’t:
*   **Don’t** use high-contrast "Pure White" backgrounds if the user is in a "Rest" mode; stick to the `surface` cream (#fafaf5).
*   **Don’t** use sharp corners. Anything less than `sm` (0.5rem) rounding is too aggressive for this system.
*   **Don’t** use "Red" for errors if a "Warm Earth" `error` (#a73b21) will suffice. We want to inform the user of an error, not alarm them.