---
name: inclusive-components
description: Build and review accessible, inclusive web UI components and resilient HTML/CSS layouts using practical patterns distilled from Heydon Pickering's Inclusive Components plus modern layout techniques. Use when implementing or auditing semantic HTML structure, responsive CSS layouts, Flexbox, Grid, container queries, cards, forms, tables, navigation, toggles, menus, tooltips, tabs, accordions, sliders, notifications, dialogs, or similar interactive interface components.
---

# Inclusive Components

## Overview

Use this skill to make common interface components communicate clearly through structure, names, roles, states, keyboard behavior, focus management, visible design, and resilient layout. Favor native HTML, intrinsic CSS, and simple interactions before adding ARIA, custom JavaScript, or layout workarounds.

The component-specific guidance is in `references/component-patterns.md`. Load it when the task involves a named component, an accessibility review, or a decision between native HTML, ARIA, and custom behavior.

The PDF-derived implementation recipes are in `references/component-recipes.md`. Load it when building a component from scratch, converting a visual design into HTML/CSS, or fixing an implementation whose semantics, state, focus, or responsive behavior are unclear.

The layout-specific guidance is in `references/html-css-layout.md`. Load it when the task involves page layout, component layout, responsive behavior, Flexbox, Grid, container queries, sizing, spacing, overflow, source order, or CSS layout debugging.

## Workflow

1. Identify the component's user task, whether it changes state, and whether it creates, removes, reveals, or interrupts content.
2. Start from native HTML semantics. Use buttons for actions, links for navigation, form controls for form state, headings for sections, lists for repeated items, and tables only for tabular data.
3. Define the layout's content model before writing CSS: source order, landmark/section structure, repeated groups, primary axis, wrapping behavior, and expected breakpoints or container states.
4. Define the accessible name, role, state, and relationships before styling. If any one of those is unclear, fix the markup before adding visual polish.
5. Design keyboard and focus behavior explicitly: entry point, tab order, arrow-key behavior where expected, escape behavior, initial focus, and return focus.
6. Communicate changes without stealing context. Use visible text first, live regions only when users need unsolicited status, and focus movement only when the task truly moves.
7. For implementation, apply the relevant recipe from `references/component-recipes.md`.
8. Check the component against `references/component-patterns.md` and the layout against `references/html-css-layout.md`, then verify with the closest available evidence: unit tests, accessibility tests, browser interaction, screenshots, or manual keyboard testing.

## Design Rules

- Prefer boring, robust primitives over custom widgets. Add ARIA only to fill a semantic gap, and do not override native roles unnecessarily.
- Do not hide controls behind hover-only interaction. Every action must be discoverable and operable with keyboard, touch, pointer, and assistive technology.
- Keep labels stable. Let state communicate state; avoid changing both the accessible name and the state at the same time.
- Make structure visible and non-visual: headings, lists, captions, labels, and regions should agree with the visual grouping.
- Avoid announcing everything. Too many live updates are noise, not accessibility.
- Treat responsive behavior as an accessibility concern. Reflow must preserve source order, relationships, labels, focus order, and content tolerance.
- Prefer fluid layout primitives over fixed dimensions. Use fixed sizes only when the format itself is fixed, such as icons, avatars, control targets, or media aspect ratios.
- Do not use CSS visual reordering to change meaning. The DOM order should remain a sensible reading and focus order.

## Output Guidance

When reviewing, lead with issues that can block use: missing accessible names, wrong roles, broken keyboard access, focus loss, hidden controls, inaccessible state changes, and content that is only conveyed visually.

When implementing, keep changes scoped to the component. Match the existing framework and design system, avoid unnecessary dependencies, and include focused tests for the behavior you changed.
