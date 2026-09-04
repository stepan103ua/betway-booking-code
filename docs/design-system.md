# Design system — Betway Nigeria Booking Code Product

One visual language, two clients. `apps/mobile` (Flutter) and `apps/web` (Next.js) render the
same screens — Decode, Create, Convert — and they are meant to look like one product, not two
ports of a brief.

**`apps/mobile/lib/design/` is the reference implementation.** It was built first, from a
`tokens/*.css` + `.jsx` component kit ("Booking Code Studio") that is *not* in this repo — so
this document is the canonical form of that kit now. Where the Flutter code and this document
disagree, that is a bug in one of them; say so rather than picking a side (same rule as the
rest of `docs/`). `apps/web` has not been built; when it is, it restyles shadcn/ui to the
tokens below rather than inventing its own.

Read this before touching `lib/design/`, before styling a component in `apps/web`, and before
adding a color, radius, or type role anywhere. Don't restate it in `CLAUDE.md` or in widget
comments — two copies drift.

| Doc | What it settles |
|---|---|
| this file | Tokens, components, the rules the look turns on, the Flutter ↔ web mapping |
| `docs/frontend.md` | The web app's framework, rendering and data-fetching strategy |
| `docs/mobile.md` | The mobile app's architecture, state management, testing |
| `docs/backend-api.md` §0 | The DTOs the slip anatomy renders — `Slip`, `Selection`, `ConvertResult` |

---

## 1. The rules the look turns on

Break one of these and it stops looking like the same product, even if every token is right.

- **Dark is the default.** The light theme is fully defined (every alias flipped) but nothing
  toggles it yet — no theme switch is in scope. `AppColors.light` / `AppTheme.light()` cost
  nothing sitting unused; a web build ships dark first the same way.
- **One accent per screen.** Lime (`accentSolid`) and the odds numbers are the *only*
  chromatic UI on a page. Exactly one `primary` button per screen. Red / amber / blue are
  state colors — a danger alert, a stale badge — never decoration, never a second "brand"
  color.
- **Flat surfaces, always.** Layers are separated by a 1px hairline **plus** a step in surface
  lightness (`surfaceApp` → `surfaceCard` → `surfaceRaised`). Never a shadow, never Material
  elevation. On Flutter the controls are hand-built from tokens (not `ElevatedButton` etc.) so
  no elevation or ripple can sneak back in; on web, every shadcn primitive is stripped to a
  flat token treatment (§4, §9).
- **Errors name the fix.** Every `Alert` says what to do next, not just what went wrong —
  "Codes are BW followed by 8 characters. Check for an O typed as a 0" beats "Invalid code".
  The copy passed to a component already follows this; the component doesn't enforce it.
- **A dashed border means "the thing to take away".** Generated-code frames, empty slots, the
  "no slip yet" placeholder. It is the one non-solid stroke in the system and it carries that
  single meaning — don't use it decoratively.
- **No squircles, no per-corner radii.** Every corner of every surface is uniform. The one
  exception is a bottom sheet, which rounds only its top two corners.
- **Motion doesn't call attention to itself.** One curve (`easeOut`) for almost everything,
  one slower cubic for the sheet. No bounce, no spring, no attention-seeking transitions.
- **Skeletons, never spinners, for content.** A loading slip renders the *shape* of the
  answer (`Skeleton`), not a `CircularProgressIndicator`. Spinners are only for a button's own
  in-flight state.
- **44px is the floor for anything tappable.** Non-negotiable for a thumb on a phone; the web
  keeps it for parity and pointer-coarse users.
- **A type role never carries a color.** `body`, `odds`, `code` define size/weight/leading/
  tracking/family only. The caller tints — the same `oddsHero` is lime on a live slip and
  `textDisabled` on an expired one.
- **Timestamps render local.** `kickoffAt` is UTC; a Lagos user (WAT, UTC+1) must see the
  local time. `.toLocal()` before it reaches a widget is not optional (§6).

---

## 2. Color

### Base palette

The raw ramps. Nothing in a screen references these directly — they exist to be aliased.

| Ramp | Values |
|---|---|
| ink (dark surfaces) | `950 #08090A` · `900 #0E0F11` · `850 #151719` · `800 #1B1D20` · `750 #22252A` · `700 #2A2E34` |
| paper (light surfaces) | `0 #FFFFFF` · `50 #F7F7F4` · `100 #EFEFEA` · `200 #E2E2DC` |
| foreground | `fg1 #F4F5F6` · `fg2 #A8ADB4` · `fg3 #71777E` · `fg4 #4B5057` · `fgInverse1 #0E0F11` |
| lime (accent) | `400 #E2FF7A` · `500 #CFF54A` · `600 #B7DE2E` · `700 #93B420` · tint `#CFF54A1A` |
| red (danger) | `500 #FF6152` · `600 #E2412F` · tint `#FF61521F` |
| amber (warn) | `500 #FFB84D` · tint `#FFB84D1F` |
| blue (info) | `500 #6EA8FF` · tint `#6EA8FF1F` |

### Semantic aliases

Screens use only these. Flutter: `context.colors.<name>`. Web: `var(--color-<name>)`.

| Alias | Dark | Light | Use |
|---|---|---|---|
| `surfaceApp` | ink950 | paper50 | page ground |
| `surfaceCard` | ink850 | paper0 | default card |
| `surfaceRaised` | ink800 | paper0 | a card lifted off another; secondary button fill |
| `surfaceRow` | ink900 | paper0 | the selection-list band inside a card |
| `surfaceSunken` | `#000000` | paper100 | inset wells (share-code chip, diff summary) |
| `surfaceInput` | ink850 | paper0 | text field fill |
| `surfaceHover` / `surfacePress` | ink750 / ink700 | paper100 / paper200 | interactive states |
| `surfaceSkeleton` | ink750 | paper100 | skeleton bars |
| `borderSubtle` | `#FFFFFF14` | `#0E0F1114` | hairline between layers |
| `borderStrong` | `#FFFFFF29` | `#0E0F1129` | outlined controls, active tab |
| `borderInput` | `#FFFFFF1F` | `#0E0F1124` | resting text-field border |
| `borderDashed` | `#FFFFFF33` | `#0E0F1133` | the dashed "take-away" stroke |
| `textPrimary` | fg1 | fgInverse1 | body, headings |
| `textSecondary` | fg2 | `#5A5F66` | secondary copy, ghost-button label |
| `textMuted` | fg3 | `#82878E` | meta lines, micro-labels |
| `textDisabled` | fg4 | `#AEB2B8` | disabled, row index numbers |
| `textOnAccent` | ink950 | ink950 | text on a lime fill — **always dark**, lime is a light color |
| `accentSolid` / `accentHover` / `accentPress` | lime500 / lime400 / lime600 | same | primary button, active toggle |
| `accentQuiet` | lime tint | lime tint (heavier) | accent badge/alert background, text selection |
| `accentText` | lime500 | lime700 | accent text on a dark/light ground |
| `oddsText` | lime500 | lime700 | odds numbers |
| `codeText` | fg1 | fgInverse1 | booking-code monospace |
| `stateStaleText` / `stateStaleSurface` | fg3 / `#FFFFFF08` | `#82878E` / `#0E0F1108` | dead-leg row |
| `dangerSolid` / `dangerText` / `dangerQuiet` | red500 / red500 / red tint | red500 / red600 / red tint | danger alert/badge/button |
| `warnSolid` / `warnText` / `warnQuiet` | amber500 / amber500 / amber tint | amber500 / `#8A6410` / amber tint | warn alert, "some legs dead" |
| `infoText` / `infoQuiet` | blue500 / blue tint | `#2F6BD1` / blue tint | info alert |
| `focusRing` | lime500 | lime500 | keyboard focus |
| `overlayScrim` | `#000000A6` | `#0E0F1159` | sheet / dialog backdrop |

Light is a straight re-alias: the ink/paper/lime/red/amber/blue base values never change, only
which alias points at which one, and lime darkens to `700` for text where it has to sit on
white.

---

## 3. Tokens

### Typography

Two families: **Archivo** (UI) and **JetBrains Mono** (odds, codes). No binaries were
supplied, so both platforms pull from Google Fonts — Flutter via `google_fonts`, web via
`next/font/google`. Swap for local `@font-face` / `FontLoader` if real files arrive.

| Role | Size / weight / leading / tracking | Family | Where |
|---|---|---|---|
| `display` | 40 / 700 / 1.05 / −0.03em | Archivo | not used yet — reserved for a marketing hero |
| `h1` | 24 / 700 / 1.2 / −0.015em | Archivo | screen titles |
| `h2` | 18 / 600 / 1.2 | Archivo | wordmark, section headers |
| `h3` | 16 / 600 / 1.2 / −0.015em | Archivo | sheet titles, empty-state titles |
| `body` | 14 / 400 / 1.4 | Archivo | default text |
| `bodyStrong` | 14 / 600 / 1.4 / −0.015em | Archivo | event names, alert titles, button labels |
| `meta` | 12 / 400 / 1.4 | Archivo | league · kickoff, hints, secondary copy |
| `label` | 11 / 600 / 1.4 / +0.08em | Archivo | uppercase micro-labels (`BOOKING CODE`, `TOTAL ODDS`) — caller upper-cases the string |
| `odds` | 16 / 700 / 1 / +0.06em | JetBrains Mono | inline odds, outcome-chip prices |
| `oddsHero` | 32 / 700 / 1 / +0.06em | JetBrains Mono | the slip's total, the draft's running total |
| `code` | 14 / 500 / 1.2 / +0.06em | JetBrains Mono | booking codes in lists |
| `codeHero` | 24 / 700 / 1.1 / +0.06em | JetBrains Mono | the code in a slip header / result |

### Spacing

A 4-based scale plus a few product rhythms that earn their own names because they are
decisions, not just points on the scale.

`space0..12` = `0 · 2 · 4 · 6 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64`

| Named | Value | Meaning |
|---|---|---|
| `gutterMobile` / `gutterDesktop` | 16 / 32 | page side padding |
| `pageMax` | 1120 | web content max-width |
| `slipRowPadY` / `slipRowPadX` | 12 / 14 | a selection row's internal padding — rows touch, separated by a hairline, no gap between siblings |
| `cardPad` | 16 | default card padding |
| `tapMin` | 44 | never smaller for anything tappable |

### Radius

Uniform on all four corners. **Rounder than the source CSS** (`4/6/10/14/20/28`) by a
deliberate call to make the UI feel less square — change these numbers and every card, button,
input and sheet follows; nothing below the token file hardcodes a radius.

`xs 8` · `sm 12` · `md 18` · `lg 24` · `xl 32` · `xxl 40` · `pill 999`. Border widths: `1`
default, `2` thick.

Shape shortcuts: `card` = lg · `control` = md · `tile` = sm · `sheetTop` = xl on the top two
corners only.

### Motion

| Token | Duration | Used for |
|---|---|---|
| `instant` | 80ms | — |
| `fast` | 120ms | button/card/input press, chevrons, toggles — almost everything |
| `pop` | 140ms | a value snapping in — a check mark, a selected chip's tick (scale 0.6 → 1) |
| `base` | 180ms | inline height reveal (a tile expanding) |
| `rise` | 220ms | a content block mounting — fade + 6px up. Replayed by a key change on a result phase, an appended list row, a changed odds figure |
| `slow` | 240ms | — |
| `sheet` | 280ms | bottom-sheet entrance |
| `skeleton` | 1400ms | skeleton opacity pulse (0.55 ↔ 1) |

Curves: `easeOut` = `cubic(0.2, 0.8, 0.2, 1)` (default), `easeInOut` = `cubic(0.4, 0, 0.2, 1)`
(skeleton only).

`rise` and `pop` are one entrance vocabulary shared by both clients — Flutter's `AppReveal` /
`AppPop` (`lib/design/widgets/app_reveal.dart`) and the web's `--animate-rise` /
`--animate-pop`. A vertical expand/collapse is `AppExpandable` (`base`, a `SizeTransition`)
against the web's `grid-template-rows` 0fr↔1fr. All collapse to a plain passthrough under the
platform reduce-motion switch (`MediaQuery.disableAnimations` / `prefers-reduced-motion`).

### Iconography

**Lucide**, referenced everywhere by its kebab-case name (`'scan-line'`, `'external-link'`) —
the same vocabulary on both platforms, so a screen written against the design system's icons
needs no per-platform name. Flutter resolves the name against a bundled Lucide font; web uses
`lucide-react`.

Working set: `scan-line` `plus` `repeat` `hash` `copy` `check` `share-2` `external-link`
`clock` `users` `user` `list` `ticket` `ban` `triangle-alert` `info` `rotate-ccw` `search`
`chevron-left` `chevron-right` `x` `wand-sparkles` `scissors` `shield-check` `loader-circle`
`sun` `moon` `signal` `wifi` `battery-full` `history` `settings` `bookmark` `message-circle`
`send` `clipboard`. Unknown name → `help-circle` (and, in Flutter, an assertion in debug).

Flutter note: `lucide_icons` is a dependency for its bundled font asset only — its Dart
`LucideIconData` no longer compiles, so `AppIcon` carries literal codepoints, and three
renamed glyphs are mapped to their old names (`triangle-alert`→`alert-triangle`,
`loader-circle`→`loader-2`, `wand-sparkles`→`wand-2`).

---

## 4. Component kit

Hand-built from tokens. Flutter: `lib/design/widgets/`. Web: shadcn/ui primitives restyled to
match — never shadcn defaults.

| Component | Variants / sizes | Notes |
|---|---|---|
| **Button** | `primary` · `secondary` · `ghost` · `danger`; `sm` (h32) · `md` (h40) · `lg` (h48) | Pill by default (`pill: false` reserved, unused). No elevation, no ripple — press = scale to 0.985 + fill swap. Disabled/loading → 45% opacity; loading shows a `loader-circle` spinner in place of the icon. **One `primary` per screen.** |
| **Card** | tones `card` · `raised` · `sunken` · `outline`; padding `none` · `sm` (12) · `md` (16) · `lg` (20) | 1px border (`borderSubtle`, or `borderStrong` for `outline`) + radius `lg`. `interactive` adds a hover/press fill. Never a shadow. |
| **Badge** | tones `neutral` · `accent` · `danger` · `warn` · `info` · `stale`; variants `quiet` (default) · `solid` · `outline`; `sm` (h20) · `md` (h26) | `mono: true` switches to the code face — used for odds pills. Radius `sm`. |
| **Input** | `sm` (h36) · `md` (h44) · `lg` (h52, default) | `mono: true, uppercase: true` is the booking-code preset (`CodeInput` composes it, plus a `^BW[0-9A-F]{8}$` gate matching the API). Border: danger if `error`, accent if focused, else `borderInput`. Error slot = `triangle-alert` + `dangerText`; otherwise a `meta` hint. Uppercase transforms the *stored* value, not just the paint. |
| **Alert** | tones `danger` · `warn` · `info` · `success` | Icon + title + body + optional `action` slot. Default icons: `triangle-alert` / `clock` / `info` / `check`. `danger` is an ARIA live region. Copy must name the fix (§1). |
| **IconButton** | `sm` (32) · `md` (40) · `lg` (44); variants `ghost` · `solid` · `accent` | Circular, icon-only. `label` is **required** — it is the accessible name. |
| **Tabs** | — | The segmented **mode switch** (Decode / Create / Convert): a pill container on `surfaceSunken`, the active segment lifted to `surfaceRaised` + `borderStrong`, h44. This is not a bottom nav — the system keeps "which job" and "which app section" as two different controls. |
| **BottomSheet** | `showAppBottomSheet(...)` | The **only** modal surface (share, market picker, details). Wraps the platform sheet and adds the chrome: a 36×4 drag handle, a title row (`h3`) + close `IconButton`, a scrolling body, an optional bordered footer. Max height 88% of screen; `sheetTop` corners; `overlayScrim` backdrop. |
| **Skeleton** | `Skeleton` (w/h/radius) · `SkeletonLines` (stacked, last bar 62% width) | Opacity pulse over `skeleton` duration. The content-loading state — never a spinner. |
| **DashedRoundedBorder** | dash 4 / gap 3 / stroke 1 | The dashed "take-away" stroke (§1). Flutter paints it directly (`BoxDecoration` can't dash); web uses `border-style: dashed`. |
| **EmptyState** | — | A `DashedRoundedBorder` frame around a centered `list`/`info`/`wand-sparkles` icon (22, `textDisabled`), an `h3` title, a `meta` body (max 280), and an optional action. "No slip yet" / "no selections yet". |

---

## 5. Slip anatomy

The product's central object. Flutter: `lib/widgets/slip/` (kept above `features/` because
every feature renders it). Web: `components/slip-card.tsx`. Takes the real `Selection` / `Slip`
DTOs (`docs/backend-api.md` §0) — no parallel view-model. Used unchanged for Decode's result,
Create's success recap, and Convert's before/after.

- **`SlipCard`** — header, an optional partial-slip notice, the selection list on a
  `surfaceRow` band, a "Show N more" expander when `collapsedCount` truncates, and an optional
  footer (actions). No padding, clipped corners.
- **`SlipHeader`** — `BOOKING CODE` label + `codeHero` + a copy `IconButton`; `TOTAL ODDS`
  label + `oddsHero` in `oddsText`; a status badge; a row of meta pills (`list` / N
  selections, `clock` / expiry, `users` / N loaded).
  - **Status is `live` or `partial` only.** `live` = accent / `check` / "Active". `partial` =
    warn / `triangle-alert` / "Some legs dead", derived from any `isActive: false` leg. There
    is deliberately **no `expired` status** — `/resolve` always returns `expiresAt: null`
    (`docs/backend-api.md` §1), so the app cannot know, and a badge for a state the API can't
    report would be a lie.
- **`SelectionRow`** — three lines: event name (`bodyStrong`, 2-line max), then `[market
  badge] + outcome name`, then `league · kickoff`. Compact enough for ~16 rows on a 390px
  screen. Dead legs get `stateStaleSurface`, 72% opacity, line-through, and a `ban` +
  `deadLegReason` line. Optional leading index, optional trailing remove (`x`).
- **`ConvertLegRow`** (Convert only) — `SelectionRow`'s layout plus a leading keep/drop
  toggle, because Convert needs a third visual state SelectionRow doesn't model: a *live* leg
  the user chose to drop (struck through, but not dead).

---

## 6. Formatting rules

Pure display logic — lives in the widget, not a model (`docs/mobile.md` §3). Web mirrors these
exactly.

| Value | Rule |
|---|---|
| `kickoffAt` | `EEE HH:mm`, **local time** — `.toLocal()` first (UTC → WAT, mandatory) |
| `expiresAt` | relative to *now*: "Expires in 2h 15m" / "Expired 5m ago". Drifts by however long the response sat in cache — acceptable, same staleness as the odds beside it |
| `usageCount` | `en-NG` thousands grouping: `9,227 loaded` |
| odds | always `toStringAsFixed(2)` — `2.30`, never `2.3` |
| dead-leg reason | the constant string **"No longer available"**. The API collapses Betway's three staleness flags into one `isActive` and reports no reason; inventing "Market closed" / "Event started" would be fiction |
| `outcomeName` | trim it — on Totals markets it arrives as `"Over "` with a trailing space; the line lives in `marketName` (`"Total (1.5)"`) |

---

## 7. Flutter ↔ web mapping

| Concern | Flutter (`apps/mobile/lib/design/`) | Web (`apps/web`) |
|---|---|---|
| color tokens | `AppColors` `ThemeExtension`, read as `context.colors.<name>` | CSS custom properties `--color-<name>` on `:root` / `[data-theme="light"]`, surfaced through the Tailwind theme |
| typography | `AppTypography.<role>` getters (Google Fonts) | Tailwind `text-<role>` utilities or `--type-<role>`; `next/font` for Archivo + JetBrains Mono |
| spacing / radius / motion | `AppSpacing` / `AppRadius` / `AppMotion` | matching `--space-*` / `--radius-*` / `--motion-*` and Tailwind scale overrides |
| icons | `AppIcon('name')` — bundled Lucide font, literal codepoints | `lucide-react`, `<DynamicIcon name>` or a name→component map |
| components | hand-built in `lib/design/widgets/` | shadcn/ui primitives, restyled to these tokens (not shadcn defaults) |
| theming | `AppTheme.dark()` / `.light()`, `MaterialApp(theme:)` | `data-theme` attribute on `<html>` + CSS-var swap; dark is the unstyled default |
| token access | `context.colors.<name>` — a widget never imports `app_colors.dart` | `var(--color-<name>)` / Tailwind class — a component never writes a hex |

A new token is added in **both** places or neither. A component that exists on one platform
and not the other is fine (the web has no `AppTabs` equivalent yet); a component that looks
different on the two is a bug.

---

## 8. Known gaps

Carried over from the Flutter implementation — real, and worth knowing before you build the
matching web piece.

- **The light theme is unreachable.** Fully defined, zero switches. Building the toggle is a
  `data-theme` attribute on web and a `ValueNotifier<ThemeMode>` on Flutter — deliberately not
  done, since nothing asked for it.
- **No verified Betway deep-link for a specific code.** "Open in Betway" and every share
  target go to `https://www.betway.com.ng`, not a code URL — no scheme was ever supplied or
  verified. If one is confirmed, it changes `decode_screen.dart`, `created_code_view.dart`,
  `convert_result_view.dart` and the share sheet.
- **`SlipHeader`'s expiry pill never shows on Decode** — `/resolve` returns `expiresAt: null`
  (`docs/backend-api.md` §1); only `/popular` populates it, on the "try a code" list.
- **The source `tokens/*.css` and `.jsx` kit are not in the repo.** This document is their
  canonical form. If they resurface, reconcile against this, not the other way around.
- **`AppButton.pill: false`** exists and nothing uses it — reserved for a control sitting
  flush against a square edge.
- **The web modal is a bottom sheet only below 640px.** §4 calls the bottom sheet the one
  modal surface; on `apps/web` a full-width sheet reads as mobile on a desktop, so
  `components/ui/modal.tsx` renders the sheet under 640px and a centred dialog at/above it —
  same chrome, same tokens, same `overlayScrim`. Flutter stays sheet-only (it is phone-only).

---

## 9. Explicitly not used, and why

- **Material / shadcn components raw.** `AppButton` is not `ElevatedButton`, `AppCard` is not
  `Card`, `AppInput` is not a themed `TextField` wrapper. Each is built from tokens so no
  framework default — elevation, ripple, minimum sizes, focus rings — has to be overridden
  back to nothing.
- **Shadows / elevation.** Layering is a hairline plus a surface-lightness step. A `z`-axis
  never appears.
- **A second accent.** Lime is the only chromatic UI color. Red / amber / blue are strictly
  state.
- **An icon library's runtime in Flutter.** `package:lucide_icons` is a font-asset dependency
  only; its Dart API is dead on current Flutter.
- **Golden / visual-regression tests.** Two-day scope; the components are small and their
  states are enumerable by eye. Revisit if the kit grows.
