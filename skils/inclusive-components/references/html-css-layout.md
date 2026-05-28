# HTML and CSS Layout Techniques

Use this reference when implementing or reviewing layouts. It focuses on resilient, semantic, responsive layout: layouts that survive real content, zoom, localization, high contrast, narrow screens, and assistive technology.

Modern CSS reference baseline:

- MDN CSS layout overview: https://developer.mozilla.org/docs/Learn_web_development/Core/CSS_layout
- MDN Flexbox: https://developer.mozilla.org/docs/Web/CSS/CSS_flexible_box_layout
- MDN Grid: https://developer.mozilla.org/docs/Web/CSS/CSS_grid_layout
- MDN Container queries: https://developer.mozilla.org/docs/Web/CSS/CSS_containment/Container_queries
- MDN Logical properties: https://developer.mozilla.org/docs/Web/CSS/CSS_logical_properties_and_values
- MDN Box alignment: https://developer.mozilla.org/docs/Web/CSS/CSS_box_alignment

## Table of Contents

- [Layout Mindset](#layout-mindset)
- [HTML Structure First](#html-structure-first)
- [Decision Tree](#decision-tree)
- [Sizing Primitives](#sizing-primitives)
- [Spacing Primitives](#spacing-primitives)
- [Normal Flow](#normal-flow)
- [Flexbox](#flexbox)
- [Grid](#grid)
- [Subgrid](#subgrid)
- [Container Queries](#container-queries)
- [Media Queries](#media-queries)
- [Logical Properties](#logical-properties)
- [Alignment](#alignment)
- [Positioning](#positioning)
- [Overflow and Scrolling](#overflow-and-scrolling)
- [Intrinsic Media](#intrinsic-media)
- [Responsive Type](#responsive-type)
- [Forms](#forms)
- [Tables](#tables)
- [Cards and Collections](#cards-and-collections)
- [Application Shells](#application-shells)
- [Common Recipes](#common-recipes)
- [Anti-Patterns](#anti-patterns)
- [Review Checklist](#review-checklist)

## Layout Mindset

- Let content define layout pressure. Start from real labels, long words, empty states, images with odd aspect ratios, validation text, and translated strings.
- Preserve source order. CSS may change placement, but reading order and focus order should still make sense without CSS.
- Prefer intrinsic layout. Use `auto`, `min-content`, `max-content`, `fit-content`, `fr`, `minmax()`, `clamp()`, `aspect-ratio`, and wrapping before hard-coded dimensions.
- Design components around available space, not only viewport width. Use container queries for reusable components.
- Use layout primitives intentionally: flow for documents, flex for one axis, grid for two axes, positioning for exceptions.
- Make overflow a first-class state. Decide whether content wraps, scrolls, truncates, clips, or expands.
- Avoid "pixel-perfect" expectations for text-heavy UI. Good layout defines constraints and relationships, not fixed coordinates.

## HTML Structure First

Use semantic HTML to define the content model before CSS.

- Use landmarks for page regions: `header`, `nav`, `main`, `aside`, `footer`.
- Use headings to introduce sections. Do not choose heading levels based on visual size.
- Use lists for repeated peer items such as cards, nav links, todos, menu options, search results, and slides.
- Use `button` for actions and `a` for navigation.
- Use `form`, `fieldset`, `legend`, `label`, `input`, `select`, and `textarea` for forms. Do not build form layout from generic divs if native grouping exists.
- Use `table`, `caption`, `thead`, `tbody`, `th`, `td`, and `scope` for tabular data.
- Add wrapper elements only when they solve layout, styling, grouping, or containment needs. Avoid wrapper chains without a job.
- Keep DOM order aligned with reading order. Avoid using `order`, `grid-area`, or absolute positioning to create a different logical order.

## Decision Tree

Use this when choosing the layout technique.

1. Is the content mostly normal document flow?
   - Use block flow, inline flow, margins, `max-inline-size`, and `display: flow-root` where needed.
2. Is alignment or distribution along one axis the main problem?
   - Use Flexbox.
3. Do rows and columns both matter?
   - Use Grid.
4. Does a child need to align to an ancestor's tracks?
   - Use subgrid if supported by the target browsers.
5. Should a component change based on its own width rather than the viewport?
   - Use container queries.
6. Does the page need broad changes at viewport, input, preference, or capability boundaries?
   - Use media queries.
7. Is an element placed relative to another element or viewport state?
   - Use positioning, sticky positioning, popover/dialog primitives, or anchored positioning if supported and appropriate.
8. Does content exceed available space?
   - Choose wrapping, scrolling, truncation, or expansion deliberately.

## Sizing Primitives

Prefer constraints over fixed sizes.

- `inline-size` and `block-size`: logical width and height.
- `min-inline-size` and `max-inline-size`: fluid width bounds.
- `min-block-size`: useful for hero regions and empty states that need minimum height without clipping content.
- `max-inline-size: none`: use only when inherited max width is incorrectly constraining a layout.
- `width: 100%`: useful for replaced elements and controls, but avoid as a reflex on everything.
- `min-width: 0`: often needed on flex/grid children so text can shrink instead of forcing overflow.
- `min-height: 0`: often needed inside nested grid/flex app shells so scroll containers can actually shrink.
- `fit-content`: cap size at content while respecting available space.
- `min-content`: size to the longest unbreakable content.
- `max-content`: size to all content without wrapping; use cautiously.
- `clamp(min, preferred, max)`: fluid sizes with hard bounds.
- `aspect-ratio`: reserve stable media and card image space without fixed heights.

Useful patterns:

```css
.container {
  inline-size: min(100% - 2rem, 72rem);
  margin-inline: auto;
}

.content {
  max-inline-size: 65ch;
}

.fluid-panel {
  inline-size: clamp(18rem, 50vw, 42rem);
}

.media {
  aspect-ratio: 16 / 9;
  inline-size: 100%;
  object-fit: cover;
}
```

## Spacing Primitives

- Prefer `gap` for spacing between flex/grid items.
- Prefer margins for spacing between independent flow sections.
- Use logical properties: `margin-block`, `margin-inline`, `padding-block`, `padding-inline`.
- Use a spacing scale where the project has one. Do not invent arbitrary one-off values unless solving a real local problem.
- Avoid margin collapse surprises by using `display: flow-root`, padding, borders, or parent `gap`.
- Use `scroll-margin-block-start` for anchor targets under sticky headers.
- Keep tap targets comfortable without forcing text into fixed boxes.

Stack pattern:

```css
.stack {
  display: flex;
  flex-direction: column;
  gap: var(--space, 1rem);
}
```

Cluster pattern:

```css
.cluster {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: .75rem;
}
```

## Normal Flow

Normal flow is the default and should carry most text-heavy layouts.

- Use block elements for vertical document structure.
- Use inline elements for text-level semantics.
- Use `max-inline-size` on readable prose instead of fixed page widths.
- Use `display: flow-root` to contain floats or prevent margin-collapsing issues when needed.
- Use CSS multi-column only for content where fragmented reading is acceptable. Avoid it for forms and interactive controls.
- Use `:where()` or low-specificity selectors for layout utilities if the codebase uses utility classes.

## Flexbox

Use Flexbox for one-dimensional layout: a row or a column.

Best fits:

- nav bars
- toolbars
- button groups
- media object rows
- form rows
- chip lists
- card footer actions
- center alignment
- wrapping clusters

Core rules:

- Set `flex-wrap: wrap` when content may exceed the row.
- Set `min-width: 0` on children with text to prevent overflow.
- Use `gap`, not child margins, for item spacing.
- Use `justify-content` for main-axis distribution and `align-items` for cross-axis alignment.
- Prefer `flex: 1 1 auto` for flexible content and explicit `flex-basis` when there is a real preferred width.
- Avoid using `order` to change meaningful reading or focus order.
- Avoid `flex: 1` on items with very different content unless equal distribution is desired.

Common patterns:

```css
.toolbar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: .5rem;
}

.media-object {
  display: flex;
  align-items: start;
  gap: 1rem;
}

.media-object__body {
  min-inline-size: 0;
  flex: 1 1 auto;
}

.split {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.split > :first-child {
  flex: 1 1 24rem;
}

.split > :last-child {
  flex: 0 1 18rem;
}
```

## Grid

Use Grid for two-dimensional layout: rows and columns together.

Best fits:

- page shells
- dashboards
- card collections
- form layouts with label/control alignment
- media galleries
- pricing/feature comparison
- components that need equal tracks
- layouts where items span rows or columns

Core rules:

- Use `fr` for leftover space, not percentages by default.
- Use `minmax(0, 1fr)` when tracks must be allowed to shrink without overflow.
- Use `repeat(auto-fit, minmax(min(100%, 18rem), 1fr))` for responsive grids without fixed breakpoints.
- Use named grid areas only when they clarify the layout and do not obscure source order.
- Avoid dense packing if it changes the visual order in a confusing way.
- Keep grid item source order meaningful.
- Prefer `gap` for gutters.

Common patterns:

```css
.responsive-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 18rem), 1fr));
  gap: 1rem;
}

.sidebar-layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 1.5rem;
}

@media (min-width: 48rem) {
  .sidebar-layout {
    grid-template-columns: minmax(0, 1fr) minmax(16rem, 24rem);
    align-items: start;
  }
}

.app-shell {
  min-block-size: 100dvh;
  display: grid;
  grid-template-rows: auto minmax(0, 1fr);
}
```

## Subgrid

Use subgrid when nested content should align to a parent grid's tracks.

Best fits:

- cards whose internal titles, content, and actions align across a collection
- forms where nested field groups align with outer label/control columns
- comparison layouts with nested rows

Rules:

- Use `grid-template-columns: subgrid` or `grid-template-rows: subgrid` only when the parent grid already defines useful tracks.
- Keep fallback acceptable if the project supports browsers without subgrid.
- Do not use subgrid when a simple local grid or flex layout is enough.

Pattern:

```css
.card-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 18rem), 1fr));
  gap: 1rem;
}

.card {
  display: grid;
  grid-template-rows: subgrid;
  grid-row: span 3;
  gap: .75rem;
}
```

## Container Queries

Use container queries when a component should respond to the space it receives.

Best fits:

- cards used in multiple page regions
- side panels
- reusable form sections
- widgets in dashboards
- components inside resizable panes

Rules:

- Establish a query container with `container-type: inline-size`.
- Query component size with `@container`, not viewport width.
- Keep container-query changes local to the component.
- Avoid circular dependencies where queried styles change the container size in unstable ways.
- Name containers only when a component needs to query a specific ancestor.

Pattern:

```css
.profile-card {
  container-type: inline-size;
}

.profile-card__body {
  display: grid;
  gap: 1rem;
}

@container (min-width: 32rem) {
  .profile-card__body {
    grid-template-columns: auto minmax(0, 1fr);
    align-items: center;
  }
}
```

## Media Queries

Use media queries for viewport, user preference, input, and capability changes.

Good uses:

- page-level layout changes
- navigation changes at broad viewport thresholds
- `prefers-reduced-motion`
- `prefers-color-scheme`
- `prefers-contrast`
- `forced-colors`
- pointer and hover capability
- print layout

Rules:

- Prefer content-based breakpoints: change layout when content needs it, not at device names.
- Use `rem` breakpoints when changes relate to readable text and page composition.
- Do not remove content at small widths unless it is genuinely redundant.
- Do not make hover capability required for access.

Pattern:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: .01ms !important;
    animation-iteration-count: 1 !important;
    scroll-behavior: auto !important;
    transition-duration: .01ms !important;
  }
}

@media (forced-colors: active) {
  .button {
    border: 1px solid ButtonText;
  }
}
```

## Logical Properties

Use logical properties so layouts work across writing modes and directions.

- Prefer `inline-size` over `width` when referring to text direction.
- Prefer `block-size` over `height` when referring to block flow.
- Prefer `margin-inline`, `padding-inline`, `border-inline`, `inset-inline`.
- Prefer `margin-block`, `padding-block`, `border-block`, `inset-block`.
- Use physical properties only when the layout is inherently physical, such as a map, canvas, or viewport edge.

Pattern:

```css
.notice {
  padding-block: .75rem;
  padding-inline: 1rem;
  border-inline-start: .25rem solid currentColor;
}
```

## Alignment

Box alignment works across Grid and Flexbox, but axes differ.

- `justify-*` aligns on the inline/main axis depending on layout mode.
- `align-*` aligns on the block/cross axis depending on layout mode.
- Use `place-items` and `place-content` only when both axes should share a value.
- Use `baseline` alignment for rows with text and controls.
- Use `start` and `end` instead of `left` and `right`.
- Avoid vertical centering large text blocks in small containers where content may overflow.

## Positioning

Use positioning for exceptions, overlays, and stateful affordances, not page layout.

- `position: relative`: create containing block or small offsets.
- `position: absolute`: badges, icons, decorative layers, local overlays.
- `position: fixed`: viewport overlays, persistent global controls.
- `position: sticky`: section headers, table headers, sidebars that remain within their parent.
- Avoid absolute positioning primary content. It tends to break with zoom, localization, and dynamic content.
- Ensure positioned overlays do not cover focus, labels, form controls, or error text.
- Use `inset-*` logical properties where possible.

Sticky pattern:

```css
.section-heading {
  position: sticky;
  inset-block-start: 0;
  z-index: 1;
}
```

## Overflow and Scrolling

Decide overflow behavior intentionally.

- Prefer wrapping for text and controls.
- Use horizontal scrolling for data tables when preserving table semantics matters.
- Use `overflow: clip` only when clipped content is decorative or otherwise available.
- Use `overflow: auto`, not `scroll`, unless persistent scrollbars are desired.
- Use `overscroll-behavior` to prevent nested scroll traps when appropriate.
- Use `scroll-padding` on containers with sticky headers.
- Use `scroll-margin` on targets that receive focus or anchor navigation.
- Avoid nested scroll areas unless the app shell genuinely needs them.
- Ensure keyboard users can reach and operate scrollable regions.

Text overflow:

```css
.truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.wrap-anywhere {
  overflow-wrap: anywhere;
}
```

## Intrinsic Media

- Always reserve space for predictable media with `aspect-ratio`.
- Use `object-fit: cover` for decorative crops and `object-fit: contain` when the whole image matters.
- Do not crop informative images unless the crop is deliberate and safe.
- Use `max-inline-size: 100%` and `block-size: auto` for responsive images.
- Keep images out of fixed-height boxes unless the content model requires a crop.
- For icon buttons, set stable control dimensions and center the icon with grid or flex.

Pattern:

```css
img,
svg,
video {
  max-inline-size: 100%;
  block-size: auto;
}

.icon-button {
  inline-size: 2.5rem;
  block-size: 2.5rem;
  display: grid;
  place-items: center;
}
```

## Responsive Type

- Do not scale body text directly with viewport width.
- Use readable defaults and adjust type by component context.
- Use `clamp()` for display headings only when the minimum and maximum are tested.
- Keep line length readable with `max-inline-size` in `ch`.
- Use `line-height` unitless for text.
- Avoid negative letter spacing.

Pattern:

```css
.headline {
  font-size: clamp(2rem, 5vw, 4rem);
  line-height: 1.05;
}

.prose {
  max-inline-size: 65ch;
  line-height: 1.6;
}
```

## Forms

- Use native labels and field grouping before layout.
- Keep labels close to controls.
- Do not rely on placeholder text as labels.
- Use grid for aligned form rows and flex for compact control groups.
- Let controls fill available inline space with `inline-size: 100%`.
- Avoid fixed heights for text inputs with variable fonts, zoom, or validation icons.
- Reserve space or allow wrapping for help text and errors.
- Connect help and error text with `aria-describedby`.

Pattern:

```css
.form-grid {
  display: grid;
  gap: 1rem;
}

.field {
  display: grid;
  gap: .375rem;
}

.field input,
.field select,
.field textarea {
  inline-size: 100%;
}

@container (min-width: 36rem) {
  .field--inline {
    grid-template-columns: 12rem minmax(0, 1fr);
    align-items: baseline;
  }
}
```

## Tables

- Use real tables for tabular data.
- Preserve header associations.
- Prefer horizontal scrolling over destroying table semantics.
- Use sticky headers only when they do not obscure focused cells or captions.
- Use `caption-side`, padding, borders, and background carefully for scanability.
- For responsive alternatives, provide an equivalent semantic structure if the data is no longer a table.

Pattern:

```css
.table-wrap {
  overflow-x: auto;
}

.table-wrap table {
  inline-size: 100%;
  border-collapse: collapse;
}

.table-wrap th,
.table-wrap td {
  padding-block: .625rem;
  padding-inline: .75rem;
  text-align: start;
  vertical-align: top;
}
```

## Cards and Collections

- Mark repeated cards as list items.
- Use a grid for the collection and normal flow or subgrid inside cards.
- Do not fix card heights. Let content define height.
- Use aspect ratios for media slots, not fixed pixel heights.
- Keep card action areas predictable and avoid nested interactive controls.
- Test long headings, missing images, multiple lines of metadata, and uneven card content.

Pattern:

```css
.card-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 18rem), 1fr));
  gap: 1rem;
}

.card {
  display: grid;
  gap: .75rem;
  align-content: start;
}

.card__media {
  aspect-ratio: 4 / 3;
  overflow: hidden;
}
```

## Application Shells

- Use Grid for app shells with header/sidebar/content regions.
- Use `100dvh` for viewport-height app shells where mobile browser UI matters.
- Use `minmax(0, 1fr)` for the main content track so nested scrolling works.
- Set `min-height: 0` or `min-block-size: 0` on grid/flex children that contain scroll areas.
- Keep skip links and main landmarks intact.
- Avoid trapping the whole page in nested scroll containers unless the product is truly app-like.

Pattern:

```css
.app {
  min-block-size: 100dvh;
  display: grid;
  grid-template-rows: auto minmax(0, 1fr);
}

.app__body {
  min-block-size: 0;
  display: grid;
  grid-template-columns: minmax(0, 1fr);
}

@media (min-width: 64rem) {
  .app__body {
    grid-template-columns: 16rem minmax(0, 1fr);
  }
}

.app__main {
  min-block-size: 0;
  overflow: auto;
}
```

## Common Recipes

### Centered Page Container

```css
.page {
  inline-size: min(100% - 2rem, 76rem);
  margin-inline: auto;
}
```

### Sidebar With Wrapping Fallback

```css
.with-sidebar {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
}

.with-sidebar > :first-child {
  flex: 1 1 36rem;
  min-inline-size: 0;
}

.with-sidebar > :last-child {
  flex: 1 1 18rem;
}
```

### Auto-Fit Card Grid

```css
.auto-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 16rem), 1fr));
  gap: 1rem;
}
```

### Split Header

```css
.section-header {
  display: flex;
  flex-wrap: wrap;
  align-items: end;
  justify-content: space-between;
  gap: .75rem 1rem;
}
```

### Sticky Footer Page

```css
body {
  min-block-size: 100dvh;
  display: grid;
  grid-template-rows: auto 1fr auto;
}
```

### Full-Bleed Section Inside Constrained Content

```css
.full-bleed {
  inline-size: 100vw;
  margin-inline-start: 50%;
  transform: translateX(-50%);
}
```

### Safe Visually Hidden Content

Use only for text that must be available to assistive technology but not visible. Do not use this to hide focusable controls.

```css
.visually-hidden {
  position: absolute;
  inline-size: 1px;
  block-size: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
  white-space: nowrap;
  border: 0;
}
```

## Anti-Patterns

- Fixed heights on cards, buttons, form rows, modals, or text containers that can receive dynamic content.
- `width: 100vw` on normal page sections, which often creates horizontal overflow when scrollbars exist.
- CSS reordering that changes the visual order away from DOM order.
- Absolute positioning primary content.
- Hover-only reveal for important controls.
- Hiding overflow to mask broken layout when content is still meaningful.
- Icon-only controls without accessible names.
- Breakpoints copied from device sizes instead of content needs.
- Nesting cards inside cards for page layout.
- Using tables for layout or divs for tabular data.
- Assuming English-length strings, one-line labels, or fixed image ratios.

## Review Checklist

- The DOM order reads correctly with CSS disabled.
- Every visible group has a semantic structure: heading, list, table, fieldset, region, or landmark where appropriate.
- The layout works at 320px wide, 200% zoom, long labels, and translated text.
- There is no unexpected horizontal page overflow.
- Flex/grid children that contain text can shrink because `min-width: 0` or an equivalent constraint is present.
- Scroll containers are intentional, reachable, and do not trap keyboard users.
- Focus indicators remain visible and are not clipped by overflow.
- Source order and focus order match the visual task order.
- Components adapt inside narrow containers, not only narrow viewports.
- CSS uses logical properties where direction or writing mode could matter.
- Media has stable aspect ratios and does not create layout shift.
- Tables remain semantically tables unless a genuine equivalent is provided.
- Print, reduced motion, forced colors, and high contrast modes are not broken by layout choices.
