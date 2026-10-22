# Inclusive Component Patterns

Source distilled from Heydon Pickering's `Inclusive Components` PDF. Use this as practical implementation guidance, not as a substitute for checking current WCAG, ARIA Authoring Practices, browser behavior, or the product's design system.

For direct build recipes, load `component-recipes.md`.

## Table of Contents

- [Universal Checks](#universal-checks)
- [Toggle Buttons](#toggle-buttons)
- [Managed Lists and Todo Items](#managed-lists-and-todo-items)
- [Menus and Menu Buttons](#menus-and-menu-buttons)
- [Tooltips and Toggletips](#tooltips-and-toggletips)
- [Theme Switchers](#theme-switchers)
- [Tabbed Interfaces](#tabbed-interfaces)
- [Collapsible Sections](#collapsible-sections)
- [Content Sliders](#content-sliders)
- [Notifications](#notifications)
- [Data Tables](#data-tables)
- [Modal Dialogs](#modal-dialogs)
- [Cards](#cards)

## Universal Checks

- Name: every control has a clear, stable accessible name.
- Role: the element's semantic role matches the user's expectation.
- State: current state is exposed through native state or ARIA state, not just text color, icon shape, or animation.
- Relationships: labels, descriptions, headings, regions, controls, panels, rows, columns, and grouped items are programmatically connected where needed.
- Keyboard: all actions are reachable, operable, and predictable without a pointer.
- Focus: focus is visible, never lost, and moved only when the user's task context changes.
- Feedback: additions, removals, errors, saves, and destructive outcomes are visible and announced only when useful.
- Content tolerance: layouts survive wrapping text, missing images, long labels, zoom, narrow screens, and high contrast modes.

## Toggle Buttons

Use for binary settings and pressed/unpressed controls.

- Prefer native checkboxes for simple on/off settings when users will understand the setting as form-like.
- Use radio groups when the explicit lexical choices, such as on/off or yes/no, are clearer than a single checked state.
- For custom toggle buttons, use `button` with `aria-pressed`, or `role="switch"` with `aria-checked` when the on/off metaphor is central.
- Do not use links for state-changing toggles.
- Keep the accessible label stable. For example, the label identifies the setting and `aria-pressed`, `checked`, or `aria-checked` conveys the state.
- If the visual design includes "on" and "off" text, ensure the accessible name still identifies the controlled setting.
- Do not rely on color alone for state. Provide shape, text, icon, or position as a redundant cue.
- Preserve visible focus and meet contrast requirements for text, icons, and active states.

## Managed Lists and Todo Items

Use for interfaces that create, complete, edit, or delete repeated items.

- Give the component a visible heading at the correct document level.
- Use list markup for repeated items so users can understand item count and move through the group.
- Label inputs with real labels. Placeholder text is not a label.
- Keep destructive controls visible or otherwise discoverable; do not reveal delete actions only on hover.
- When removing the focused item from the DOM, move focus to a nearby meaningful target such as the next item, previous item, or add field.
- Announce additions, removals, and empty states with concise visible text or a live region when the update happens away from focus.
- Write empty states as useful onboarding copy: what the list is for and what the user can do next.
- For icon-only buttons, provide a unique accessible name such as "Delete Pick up keys", not just "Delete".

## Menus and Menu Buttons

Use menu semantics only for true application command menus.

- Do not apply ARIA menu roles to normal site navigation. Navigation is usually a list of links, optionally revealed by a button.
- For navigation menu buttons, use a real `button`, expose open state with `aria-expanded`, and place the revealed navigation next in focus order.
- Avoid hover-only menus. Support touch, keyboard, pointer, and reduced precision input.
- If opening a menu moves focus, define where focus goes and how Escape returns focus to the opener.
- Use true `menu`, `menuitem`, and related roles only when the component behaves like an application menu with command-like items and expected arrow-key behavior.
- Do not sacrifice usability to avoid JavaScript. A fragile no-JavaScript trick is worse than a small, well-scoped script.
- On content-heavy sites, avoid hiding important structure behind deep nested menus.

## Tooltips and Toggletips

Use sparingly. Inline labels and helper text are usually better.

- If there is room for persistent explanatory text, use it instead of a tooltip.
- Do not depend on the `title` attribute. It is not reliably keyboard, touch, or screen-reader accessible.
- Treat a tooltip as supplemental content shown on hover and focus. It should not contain interactive controls.
- Decide whether the content is the control's label or description. Use the label when it names the control; use a description when it adds extra context.
- Treat a toggletip as button-triggered information. The trigger's accessible name should describe the action, not merely repeat the hidden content.
- Do not put links, close buttons, confirmation buttons, or forms inside tooltip-like surfaces. Use a menu, popover, disclosure, or dialog instead.
- Make dismissal and persistence rules predictable across pointer, keyboard, and touch.

## Theme Switchers

Use for optional visual theme changes, such as light/dark mode.

- Keep theme switching as a progressive enhancement. Do not add it if it creates meaningful performance, complexity, or readability costs.
- Use feature detection for browser capabilities before exposing controls that depend on them.
- Use a semantic toggle control with a stable label and exposed state.
- Respect user and system preferences where available, including color scheme, contrast, and forced-colors modes.
- Avoid blanket visual filters that damage images, video, logos, charts, or user content.
- Test focus indicators, icons, borders, and state cues in high contrast and forced-colors environments.

## Tabbed Interfaces

Use only when users benefit from switching between peer panels in the same context.

- Ask whether same-page links, a table of contents, normal sections, or disclosures would be simpler and more robust.
- Do not make an entire single-page application behave like a tab widget. App routes and views are navigation, not tabs.
- If it looks and behaves like tabs, provide tab semantics: `tablist`, `tab`, `tabpanel`, `aria-selected`, `aria-controls`, and panel labelling.
- Implement expected keyboard behavior: Tab enters/leaves the widget, arrow keys move between tabs, and Home/End jump to first/last where supported by local patterns.
- Keep tab labels short and distinct.
- Make hidden panels truly unavailable to keyboard and screen-reader traversal.
- For narrow screens, prefer a simpler pattern only when it preserves semantics and expectations. Do not silently turn tabs into an unrelated control.

## Collapsible Sections

Use for optional sections, accordions, and progressive disclosure.

- Use a real `button` to expand and collapse content.
- Expose state with `aria-expanded`; connect the button and content with `aria-controls` when helpful.
- Do not override native roles on headings, buttons, or sections.
- Keep the trigger label stable and place state in `aria-expanded`, icon state, or adjacent text.
- Use `details` and `summary` when their native behavior fits the product and browser support expectations.
- Use `region` only for content substantial enough to deserve region navigation, and always label it.
- Ensure expand/collapse icons work in high contrast modes. Prefer `currentColor` for SVG strokes/fills.
- Progressive enhancement is a good fit when the content should remain available without JavaScript.

## Content Sliders

Use for horizontal browsing only when the interaction adds value.

- Consider whether a normal list or grid would be more usable.
- Mark slides as a list so users can understand grouping and count.
- Support multiple input modes: pointer dragging, touch swiping, keyboard operation, and explicit previous/next buttons.
- Do not auto-advance content unless there is a strong product reason and the user can pause it.
- Do not announce every slide change as unsolicited live-region output.
- Disable or hide previous/next controls when they cannot act, and expose that disabled state.
- Preserve linked content inside slides; do not make the slider controls interfere with links.
- Use lazy loading carefully so images do not cause layout jumps or empty inaccessible content.

## Notifications

Use for status updates, alerts, flash messages, and conversational events.

- Prefer visible notifications that are also available to assistive technology. Visually hidden live regions are a last resort, not the default.
- Use polite live regions for non-urgent status and assertive alerts only for urgent, interruptive information.
- Do not use `aria-atomic` broadly unless users truly need the whole region announced after each change.
- Do not move focus for ordinary notifications. Move focus only when the user must resolve a new task or when navigation actually changed.
- Do not announce every DOM change. Announce the user's meaningful outcome.
- Make notifications descriptive enough to answer: what happened, where am I, and what can I do next?
- Be cautious with desktop notifications; they are intrusive and need a strong user-facing reason.
- For validation and flash messages, connect errors to the relevant fields or section and provide a heading or summary when useful.

## Data Tables

Use tables only for data that has meaningful row and column relationships.

- Do not use tables for layout.
- Include column headers or row headers, and use `scope` where it clarifies associations.
- Add a caption when users need a concise table title or purpose.
- Keep table semantics intact on small screens. Horizontal scrolling is often safer than transforming rows into unrelated blocks.
- Make visual divisions, headers, and row scanning clear without relying only on color.
- Add sorting only when it helps the data set. Do not add it to tiny or obvious tables.
- Put sort controls inside header cells and expose sort direction on the sorted column.
- Do not use ARIA grid unless users need spreadsheet-like cell navigation and editing.

## Modal Dialogs

Use dialogs for critical, blocking questions or short tasks.

- Avoid dialogs for routine information. If content is rich, multi-step, or non-urgent, use a page or screen instead.
- Avoid non-modal dialogs; they are often confusing because they appear important without actually blocking the page.
- Prefer native dialog behavior when available and appropriate.
- A custom modal must handle initial focus, focus trapping, Escape, close controls, background inertness, scroll behavior, and return focus.
- Keep dialog copy brief and action choices clear.
- Ask questions in dialogs; do not use them merely to state something that already happened.
- Test with keyboard only: open, read title/content, choose action, close, and return to the original task.

## Cards

Use cards for repeated content previews, not miniature pages.

- Group card collections with list markup when cards are repeated items.
- Give each card a heading and keep the source order logical: heading first, then content that belongs to it.
- Avoid too many interactive elements inside one card. Too many tab stops make card lists tedious.
- Prefer one primary link per card, with link text that is unique out of context.
- If the whole card appears clickable, preserve semantic links and avoid invalid nested interactive elements.
- Ensure long titles, missing metadata, and unusual image aspect ratios do not break the layout.
- Write alternative text based on the image's purpose in that card, not the filename or generic subject.
- Make calls to action specific enough to distinguish repeated cards.
