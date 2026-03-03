# 🎨 Design Style Guide: "Neo-Nature" (2025 Premium Dark Mode)

> **Philosophy**: A radical departure from "Safe Blue" booking apps. "Neo-Nature" combines the stability of deep forest tones with the electric energy of acid lime. It feels organic, premium, and hyper-modern.

---

## 1. 🎨 Color Palette (The Anti-Cliché)

**Concept**: Deepest immersion (Void Green) meets electric user action (Acid Lime).

| Token              | Hex                     | Usage                                                                |
| :----------------- | :---------------------- | :------------------------------------------------------------------- |
| **Primary Action** | `#CCFF00` (Acid Lime)   | Main CTA buttons, active states, key data highlights.                |
| **Background**     | `#020402` (Void Green)  | Main page background. Not pure black, but a rich, deep organic void. |
| **Surface**        | `#0A1F13` (Deep Jungle) | Card backgrounds, sticky headers, inputs.                            |
| **Border/Stroke**  | `#1F4031` (Moss Edge)   | 1px borders, subtle dividers.                                        |
| **Text Primary**   | `#F0FDF4` (Pale Mint)   | Headings, primary content.                                           |
| **Text Secondary** | `#6B9C88` (Sage Mist)   | Subtitles, meta-data, placeholders.                                  |
| **Error/Alert**    | `#FF453A` (Neon Red)    | Errors, cancellations (kept vibrant to match solidity).              |

---

## 2. 📐 Geometry & Shape (Sharp Extremism)

**Rule**: Avoid the "Safe Boredom" zone (4px-8px).

- **Cards/Containers**: `2px` (Close to sharp, ultra-premium tech feel).
- **Buttons**: `0px` (Strict rectangular) OR `9999px` (Full pill). **Choose ONE and stick to it.** (Recommended: **0px Sharp** for specific premium modern feel).
- **Inputs**: `2px` border radius.

---

## 3. 🅰️ Typography (Modern Grotesque)

**Font Family**: `Inter` (Tight tracking) or `Space Grotesk` (for headers).

- **H1 (Hero)**: Bold, Tight tracking (`-0.02em`). Huge scale (e.g., 4rem+).
- **Body**: Regular, Normal tracking. High legibility.
- **Micro-labels**: Uppercase, tracked out (`0.05em`), smaller size (`0.75rem`).

---

## 4. 🎭 Effects & Depth (No Glassmorphism)

**Rule**: Real depth through layering and solidity, not blur.

- **Borders**: All "Surfaces" must have a `1px` border (`#1F4031`).
- **Active State**: No simple opacity change. Use **Glow** or **Translation**.
    - _Hover_: `transform: translate(-2px, -2px); box-shadow: 4px 4px 0px #CCFF00;` (Hard shadow offset).
- **Depth**: Use "Z-Axis Layering". Content should visually sit _on top_ of massive background typography or images.

---

## 5. 🌀 Motion (Spring Physics)

**Rule**: Nothing appears linearly.

- **Load**: Staggered reveal. Elements slide up (`y: 20px -> 0`) with `opacity: 0 -> 1`.
- **Interaction**: Snappy, spring-based feedback.
- **Scroll**: Parallax effects on background elements vs foreground cards.

---

## 6. 🧩 UI Components (Examples)

### Primary Button

```css
background: #ccff00;
color: #020402;
border: 1px solid #ccff00;
border-radius: 0px; /* Sharp */
font-weight: 700;
text-transform: uppercase;
letter-spacing: 0.05em;
transition: all 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
```

### Booking Card

```css
background: #0a1f13;
border: 1px solid #1f4031;
border-radius: 2px;
/* No Drop Shadow - Use Border for separation in dark mode */
```

### Input Field

```css
background: #020402;
border: 1px solid #1f4031;
color: #f0fdf4;
/* Focus: Border becomes #CCFF00 */
```
