# Inclusive Component Recipes

These recipes distill the practical component knowledge from Heydon Pickering's `Inclusive Components` into implementation steps agents can apply. They are paraphrased and generalized. Do not copy source examples from the PDF into product code; use these recipes to build idiomatic code in the current codebase.

## Table of Contents

- [How To Use These Recipes](#how-to-use-these-recipes)
- [Recipe: Binary Setting Toggle](#recipe-binary-setting-toggle)
- [Recipe: Custom Toggle Button](#recipe-custom-toggle-button)
- [Recipe: Settings List With Switches](#recipe-settings-list-with-switches)
- [Recipe: Managed Todo/List Component](#recipe-managed-todolist-component)
- [Recipe: Navigation Menu Button](#recipe-navigation-menu-button)
- [Recipe: Application Command Menu](#recipe-application-command-menu)
- [Recipe: Tooltip](#recipe-tooltip)
- [Recipe: Toggletip](#recipe-toggletip)
- [Recipe: Theme Switcher](#recipe-theme-switcher)
- [Recipe: Tabs](#recipe-tabs)
- [Recipe: Collapsible Section](#recipe-collapsible-section)
- [Recipe: Accordion](#recipe-accordion)
- [Recipe: Content Slider](#recipe-content-slider)
- [Recipe: Notification Or Flash Message](#recipe-notification-or-flash-message)
- [Recipe: Data Table](#recipe-data-table)
- [Recipe: Sortable Data Table](#recipe-sortable-data-table)
- [Recipe: Modal Dialog](#recipe-modal-dialog)
- [Recipe: Card List](#recipe-card-list)
- [Recipe: Whole-Card Link](#recipe-whole-card-link)
- [Verification Matrix](#verification-matrix)

## How To Use These Recipes

1. Choose the least complex recipe that matches the user task.
2. Start from the semantic HTML shape before CSS or JavaScript.
3. Preserve stable accessible names and expose changing state separately.
4. Define focus behavior before implementing DOM insertion, deletion, hiding, or overlay behavior.
5. Use CSS for layout and visual state, JavaScript only for state changes and behavior that HTML cannot provide.
6. Verify with keyboard, screen-reader-oriented semantics, pointer/touch, narrow containers, zoom, and high contrast where relevant.

## Recipe: Binary Setting Toggle

Use when a setting is on/off and a checkbox metaphor is acceptable.

HTML shape:

```html
<label class="setting-toggle">
  <input type="checkbox" name="emailNotifications" />
  <span>Notify by email</span>
</label>
```

Implementation rules:

- Let the checkbox expose role and checked state.
- Keep the label as the setting name, not the current state.
- Style the checkbox if needed, but preserve focus and checked state.
- Use a fieldset and legend when multiple toggles form a settings group.
- If explicit "On" and "Off" choices are clearer, use a radio group instead.

CSS notes:

```css
.setting-toggle {
  display: flex;
  align-items: center;
  gap: .75rem;
}

.setting-toggle input {
  flex: 0 0 auto;
}
```

Verify:

- Tab reaches the checkbox.
- Space toggles it.
- The accessible name remains the setting label.
- State is visible without relying on color alone.

## Recipe: Custom Toggle Button

Use when the control is a button whose pressed state changes the interface, not a submitted form setting.

HTML shape:

```html
<button type="button" aria-pressed="false">
  Bold
</button>
```

Implementation rules:

- Use `button`, not `a`.
- Toggle `aria-pressed` between `true` and `false`.
- Keep the label stable. Do not switch between labels like "Mute" and "Unmute" if that also hides the state change from assistive tech.
- If the component is specifically an on/off switch, use `role="switch"` with `aria-checked`, but only when support and product semantics justify it.

CSS notes:

```css
.toggle-button[aria-pressed='true'] {
  border-color: currentColor;
  box-shadow: inset 0 0 0 2px currentColor;
}
```

Verify:

- Enter and Space activate the button.
- State is visible and programmatically exposed.
- The label still identifies what is controlled.

## Recipe: Settings List With Switches

Use when several related settings each have an on/off control.

HTML shape:

```html
<section aria-labelledby="notification-settings-title">
  <h2 id="notification-settings-title">Notifications</h2>
  <ul class="settings-list">
    <li>
      <span id="email-label">Notify by email</span>
      <button type="button" role="switch" aria-checked="true" aria-labelledby="email-label">
        <span aria-hidden="true">On</span>
      </button>
    </li>
  </ul>
</section>
```

Implementation rules:

- Use list markup so the settings are grouped visually and non-visually.
- Associate each switch with the setting text using a label, `aria-labelledby`, or native label.
- Do not make "On" or "Off" the accessible name; it is the state.
- Keep focus on the switch after toggling.

CSS notes:

```css
.settings-list {
  display: grid;
  gap: .75rem;
  padding: 0;
  list-style: none;
}

.settings-list li {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
}
```

Verify:

- Screen-reader users get group, item, label, role, and state.
- The list still reads sensibly when CSS is disabled.
- Long setting labels wrap without pushing the switch off screen.

## Recipe: Managed Todo/List Component

Use when users add, complete, and delete items.

HTML shape:

```html
<section aria-labelledby="todo-title">
  <h2 id="todo-title">Tasks</h2>

  <form>
    <label for="new-task">New task</label>
    <input id="new-task" name="task" />
    <button type="submit">Add</button>
  </form>

  <p id="task-feedback" role="status"></p>

  <ul>
    <li>
      <label>
        <input type="checkbox" />
        Pick up keys
      </label>
      <button type="button">Delete Pick up keys</button>
    </li>
  </ul>
</section>
```

Implementation rules:

- Give the component a heading.
- Use a real label for the input.
- Use a list for items.
- Use checkboxes for completed/not completed state.
- Make delete controls visible and keyboard reachable.
- When deleting the focused item, move focus to the next item, previous item, or the add input.
- Announce add/delete outcomes through visible status text or `role="status"`.
- Show an empty state when the list has no items.

CSS notes:

```css
.todo-form {
  display: flex;
  flex-wrap: wrap;
  align-items: end;
  gap: .75rem;
}

.todo-form input {
  min-inline-size: min(100%, 16rem);
  flex: 1 1 16rem;
}

.todo-list {
  display: grid;
  gap: .5rem;
  padding: 0;
  list-style: none;
}
```

Verify:

- Add works by pressing Enter in the input.
- Empty submissions are handled visibly.
- Deleted focused items do not leave focus on `body`.
- The delete button name is unique per item.

## Recipe: Navigation Menu Button

Use for showing and hiding a navigation list. Do not use ARIA menu roles for normal navigation.

HTML shape:

```html
<nav aria-label="Primary">
  <button type="button" aria-expanded="false" aria-controls="primary-nav-list">
    Menu
  </button>
  <ul id="primary-nav-list" hidden>
    <li><a href="/products">Products</a></li>
    <li><a href="/pricing">Pricing</a></li>
  </ul>
</nav>
```

Implementation rules:

- Use a button to toggle visibility.
- Update `aria-expanded`.
- Keep the list next in focus order after the button.
- Hide the list with `hidden` or equivalent when closed.
- Support Escape to close if focus is inside the revealed navigation.
- Do not make navigation links act like `menuitem`.

CSS notes:

```css
.nav-list {
  display: flex;
  flex-wrap: wrap;
  gap: .5rem 1rem;
}

@media (max-width: 40rem) {
  .nav-list {
    display: grid;
  }
}
```

Verify:

- Button state matches visibility.
- Links remain normal links.
- Touch and keyboard can both open and close it.

## Recipe: Application Command Menu

Use for command menus in application-like interfaces, not website navigation.

HTML shape:

```html
<button type="button" aria-haspopup="menu" aria-expanded="false" aria-controls="editor-menu">
  More actions
</button>
<div id="editor-menu" role="menu" hidden>
  <button type="button" role="menuitem">Rename</button>
  <button type="button" role="menuitem">Duplicate</button>
  <button type="button" role="menuitem">Delete</button>
</div>
```

Implementation rules:

- Use only when items are commands.
- On open, move focus to the first enabled menu item.
- Arrow keys move among items.
- Home/End move to first/last item.
- Escape closes and returns focus to the menu button.
- Clicking outside closes the menu.
- Disabled items should be exposed consistently and skipped or included according to the product's menu pattern.

CSS notes:

```css
.menu {
  position: absolute;
  z-index: 10;
  min-inline-size: max-content;
}
```

Verify:

- Keyboard behavior matches command-menu expectations.
- Focus never disappears when the menu closes.
- It is not used for ordinary page navigation.

## Recipe: Tooltip

Use for supplemental non-interactive information shown on hover and focus.

HTML shape:

```html
<button type="button" aria-describedby="save-tip">
  Save
</button>
<span id="save-tip" role="tooltip" hidden>
  Saves changes to this draft.
</span>
```

Implementation rules:

- Do not rely on `title`.
- Do not put links, buttons, or form controls inside the tooltip.
- Show on focus and hover; hide on blur, pointer leave, and Escape.
- Use `aria-describedby` when the tooltip is extra description.
- If the tooltip text is the only label, use an accessible label instead of a tooltip.
- Avoid tooltips when visible text can fit.

CSS notes:

```css
.tooltip {
  position: absolute;
  z-index: 20;
  max-inline-size: 20rem;
}
```

Verify:

- Keyboard focus reveals the same help as pointer hover.
- The trigger's accessible name still makes sense without the tooltip.
- Tooltip text wrapping does not cover the trigger or nearby focus.

## Recipe: Toggletip

Use for user-requested short help revealed by a button.

HTML shape:

```html
<button type="button" aria-expanded="false" aria-controls="password-help">
  Password requirements
</button>
<div id="password-help" hidden>
  Use at least 12 characters.
</div>
```

Implementation rules:

- The trigger is a button with an action-oriented accessible name.
- Use `aria-expanded` and `aria-controls`.
- Keep content short and non-interactive.
- If content becomes complex or interactive, use disclosure, popover, or dialog instead.
- Decide whether focus remains on the button or moves into the content; for short static text, keep focus on the button.

Verify:

- Toggle state is exposed.
- The tip can be dismissed.
- The content is available on touch, keyboard, and pointer.

## Recipe: Theme Switcher

Use for optional light/dark or contrast theme switching.

HTML shape:

```html
<button type="button" aria-pressed="false">
  Dark theme
</button>
```

Implementation rules:

- Use a semantic toggle.
- Respect stored user choice and system preference where the product supports it.
- Apply theme with a root attribute or class such as `data-theme`.
- Do not apply image-damaging global filters unless the product accepts the tradeoff.
- Test forced colors and high contrast.
- Keep theme controls visible only when supported.

CSS notes:

```css
:root {
  color-scheme: light;
}

:root[data-theme='dark'] {
  color-scheme: dark;
}
```

Verify:

- State is programmatically exposed.
- Theme persists if persistence is required.
- Icons, focus rings, borders, and disabled states remain visible.

## Recipe: Tabs

Use for switching among peer panels within the same context.

HTML shape:

```html
<div class="tabs">
  <div role="tablist" aria-label="Account sections">
    <button id="tab-profile" type="button" role="tab" aria-selected="true" aria-controls="panel-profile">
      Profile
    </button>
    <button id="tab-security" type="button" role="tab" aria-selected="false" aria-controls="panel-security" tabindex="-1">
      Security
    </button>
  </div>

  <section id="panel-profile" role="tabpanel" aria-labelledby="tab-profile">
    ...
  </section>
  <section id="panel-security" role="tabpanel" aria-labelledby="tab-security" hidden>
    ...
  </section>
</div>
```

Implementation rules:

- Use tabs only when same-page links, sections, or disclosures are not better.
- Only the active tab is in the tab order.
- Arrow keys move between tabs.
- Home/End move to first/last tabs.
- Activate on focus only when panel changes are instant and not disruptive; otherwise activate on Enter/Space.
- Hide inactive panels from visual and accessibility trees.
- Keep panel content in DOM order after the tab list.

CSS notes:

```css
[role='tablist'] {
  display: flex;
  overflow-x: auto;
  gap: .25rem;
}

[role='tab'][aria-selected='true'] {
  border-block-end-color: currentColor;
}
```

Verify:

- Tab key enters the tablist once and then moves to panel content.
- Arrow keys do not scroll the page unexpectedly.
- Inactive panel controls are not focusable.

## Recipe: Collapsible Section

Use for showing and hiding one content section.

HTML shape:

```html
<h2>
  <button type="button" aria-expanded="false" aria-controls="shipping-details">
    Shipping details
  </button>
</h2>
<div id="shipping-details" hidden>
  ...
</div>
```

Implementation rules:

- Put the button inside the heading when the button labels the section.
- Toggle `aria-expanded` and hidden state together.
- Keep the label stable.
- Do not replace the button role.
- Use `details`/`summary` if native behavior is enough.

CSS notes:

```css
.disclosure-button {
  inline-size: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
}
```

Verify:

- Enter and Space toggle.
- Content is not focusable while hidden.
- Icon state works without color alone.

## Recipe: Accordion

Use for a group of related collapsible sections.

HTML shape:

```html
<section class="accordion" aria-label="Frequently asked questions">
  <h3>
    <button type="button" aria-expanded="false" aria-controls="faq-1">
      Can I change my plan?
    </button>
  </h3>
  <div id="faq-1" hidden>
    ...
  </div>
</section>
```

Implementation rules:

- Each panel has its own heading button.
- Multiple panels may stay open unless product requirements demand single-open behavior.
- If only one panel can be open, closing/opening must not lose focus.
- Do not use `role="tablist"` for accordions.
- Avoid overusing `region`; use it only for substantial panels and label it.

Verify:

- All headings are discoverable.
- Expanding one panel does not unexpectedly move focus.
- Keyboard operation is consistent across all panels.

## Recipe: Content Slider

Use for horizontal browsing when a list/grid would not serve the goal better.

HTML shape:

```html
<section aria-labelledby="featured-title">
  <h2 id="featured-title">Featured articles</h2>
  <div class="slider">
    <button type="button">Previous</button>
    <ul class="slides">
      <li>...</li>
      <li>...</li>
    </ul>
    <button type="button">Next</button>
  </div>
</section>
```

Implementation rules:

- Keep slides as list items.
- Provide explicit previous/next buttons.
- Support touch and pointer drag only as enhancements.
- Do not auto-advance unless there is a pause control and a strong reason.
- Do not announce every slide change with a live region.
- Disable previous/next buttons when no movement is possible.
- Preserve links and buttons inside slides.

CSS notes:

```css
.slides {
  display: flex;
  gap: 1rem;
  overflow-x: auto;
  scroll-snap-type: inline mandatory;
  padding: 0;
  list-style: none;
}

.slides > li {
  flex: 0 0 min(100%, 20rem);
  scroll-snap-align: start;
}
```

Verify:

- Keyboard users can reach every slide's interactive content.
- Buttons reflect disabled states.
- Swipe/drag is not the only way to move.

## Recipe: Notification Or Flash Message

Use for status, validation summaries, save confirmations, alerts, and activity events.

HTML shape:

```html
<p role="status">
  Settings saved.
</p>
```

Implementation rules:

- Use visible text when possible.
- Use `role="status"` or `aria-live="polite"` for non-urgent status.
- Use `role="alert"` sparingly for urgent errors that need interruption.
- Do not move focus for ordinary notifications.
- Move focus only when the user must resolve something or the screen changed.
- Connect validation messages to fields with `aria-describedby`.
- Write notification text with outcome and next step where needed.

CSS notes:

```css
.notification {
  display: flex;
  align-items: start;
  gap: .75rem;
  padding: .75rem 1rem;
  border-inline-start: .25rem solid currentColor;
}
```

Verify:

- Status is not repeated excessively.
- User context does not change unexpectedly.
- Visual and announced messages match.

## Recipe: Data Table

Use only for tabular relationships.

HTML shape:

```html
<div class="table-wrap">
  <table>
    <caption>Invoice history</caption>
    <thead>
      <tr>
        <th scope="col">Date</th>
        <th scope="col">Amount</th>
        <th scope="col">Status</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>2026-05-26</td>
        <td>$42.00</td>
        <td>Paid</td>
      </tr>
    </tbody>
  </table>
</div>
```

Implementation rules:

- Use tables only for tabular data.
- Include headers and `scope`.
- Add a caption when it helps identify the data.
- Preserve table semantics at small widths.
- Prefer horizontal scrolling over converting table rows into ambiguous blocks.

CSS notes:

```css
.table-wrap {
  overflow-x: auto;
}

table {
  inline-size: 100%;
  border-collapse: collapse;
}

th,
td {
  padding: .625rem .75rem;
  text-align: start;
  vertical-align: top;
}
```

Verify:

- Header associations remain intact.
- Table is usable at narrow widths.
- Row and column scanning are visually clear.

## Recipe: Sortable Data Table

Use only when sorting helps the data set.

HTML shape:

```html
<th scope="col" aria-sort="ascending">
  <button type="button">
    Date
  </button>
</th>
```

Implementation rules:

- Put sort buttons inside header cells.
- Set `aria-sort` on the currently sorted header cell.
- Only one column should expose active sort state at a time unless the UI truly supports multi-sort.
- Keep button labels concise and unique in context.
- Do not add sorting to tiny tables where it adds noise.

Verify:

- Clicking or pressing Enter/Space changes order.
- Sort direction is visible and programmatically exposed.
- Focus remains on the sorting control after sorting.

## Recipe: Modal Dialog

Use for short, blocking decisions or tasks.

HTML shape:

```html
<dialog aria-labelledby="delete-title">
  <h2 id="delete-title">Delete project?</h2>
  <p>This action cannot be undone.</p>
  <form method="dialog">
    <button value="cancel">Cancel</button>
    <button value="confirm">Delete</button>
  </form>
</dialog>
```

Implementation rules:

- Prefer native `dialog` when it meets project needs.
- Keep the dialog short.
- Use a clear title connected by `aria-labelledby`.
- On open, focus the first meaningful control or the dialog title when content must be read first.
- Trap focus inside custom modals.
- Escape closes unless the task truly cannot be dismissed.
- Return focus to the opener on close.
- Make the background inert for custom modals.

CSS notes:

```css
dialog {
  inline-size: min(100% - 2rem, 32rem);
  max-block-size: min(80dvh, 40rem);
}

dialog::backdrop {
  background: rgb(0 0 0 / .45);
}
```

Verify:

- Keyboard can open, operate, close, and return.
- Focus cannot escape while modal is open.
- Dialog is not used for non-urgent rich content.

## Recipe: Card List

Use for repeated content previews.

HTML shape:

```html
<ul class="card-list">
  <li>
    <article class="card">
      <h2><a href="/article">Readable title</a></h2>
      <p>Summary text.</p>
    </article>
  </li>
</ul>
```

Implementation rules:

- Use list markup for repeated cards.
- Use a heading for each card.
- Keep heading before content in source order.
- Avoid too many controls in one card.
- Make link text unique enough out of context.
- Let cards grow with content.
- Use stable media aspect ratios.

CSS notes:

```css
.card-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 18rem), 1fr));
  gap: 1rem;
  padding: 0;
  list-style: none;
}

.card {
  display: grid;
  gap: .75rem;
  align-content: start;
}
```

Verify:

- Cards survive long titles and missing images.
- Tab order is not exhausting.
- The list still communicates count/grouping.

## Recipe: Whole-Card Link

Use when a card should feel clickable while preserving valid semantic HTML.

HTML shape:

```html
<article class="card">
  <h2>
    <a class="card__link" href="/article">Readable title</a>
  </h2>
  <p>Summary text.</p>
</article>
```

CSS shape:

```css
.card {
  position: relative;
}

.card__link::after {
  content: '';
  position: absolute;
  inset: 0;
}
```

Implementation rules:

- Keep one real primary link.
- Do not nest buttons or links inside a larger link.
- If the card has secondary controls, ensure the overlay does not cover them.
- Preserve visible focus on the actual link.
- Make the link text unique, because screen-reader users may navigate by links.

Verify:

- Secondary actions remain clickable and focusable.
- Focus outline is visible.
- Link target and card click target are the same.

## Verification Matrix

For any recipe, run through this matrix:

- Keyboard: Tab, Shift+Tab, Enter, Space, Escape, arrow keys where expected.
- Pointer: click, hover if relevant, drag only as enhancement.
- Touch: no hover dependency, target sizes remain usable.
- Screen-reader semantics: name, role, state, relationships, live announcements.
- Focus: visible, logical, never lost, returned after close/delete.
- Responsive layout: narrow container, long labels, zoom, wrapping, overflow.
- Visual state: not color-only, high contrast compatible, disabled state clear.
- DOM changes: inserted/removed/hidden content does not create stale focus or inaccessible controls.
