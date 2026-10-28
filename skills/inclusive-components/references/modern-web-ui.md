# Modern Web UI

Selected guidance adapted from GoogleChrome's Modern Web Guidance, reviewed on 2026-10-28 at commit `4f2b13e25c5815b3f080ca0d983e828d96561a0f`. This local adaptation keeps the UI techniques and omits the upstream installer, mandatory CLI calls, and reporting format. The upstream material is licensed under [Apache-2.0](../LICENSE.google-modern-web-guidance).

## Browser support and existing components

- Check the project's browser policy, Browserslist, and embedded runtime before choosing an API. A JavaScript build target does not establish support for DOM APIs or CSS.
- Verify current support for the exact feature being used. Support for `dialog` does not establish support for `closedby`, invoker commands, or popovers.
- When no target is defined, use Baseline Widely available as a conservative working assumption and state it when it affects the solution. Baseline describes interoperability; it does not replace testing the required browser or assistive technology.
- Start with a usable baseline. New CSS can enhance presentation without a polyfill when its absence preserves the task. Core interactions need a working path in every supported browser.
- Use `@supports` or JavaScript feature detection when a branch is necessary, and load an approved polyfill only where needed. Preserve the project's components, framework lifecycle, and types; a newer API alone is not a reason to replace them or add a dependency.

## Dialogs and popovers

| User task | Native option | Behavior to preserve |
| --- | --- | --- |
| A short task that must block the page | `dialog.showModal()` | Modal focus containment, background inertness, accessible title, explicit close action |
| A parallel task such as an inspector or find panel | Non-modal `dialog`; `dialog popover` when top-layer presentation is supported and needed | Page remains interactive; visible close action and a clear route between panel and page |
| A disclosure, menu, or tooltip | Appropriate semantic markup, optionally using `popover` | The component's own keyboard behavior and accessible relationships |

- Native modal dialogs already provide modal semantics and focus containment. Avoid duplicating them with `role="dialog"`, `aria-modal`, or another focus trap. Verify initial focus and return focus, including when the opener has been removed.
- `show()` and the `open` attribute do not create a modal. A popover does not supply menu semantics or arrow-key navigation; those still depend on the component's task.
- Keep closed dialogs hidden. Scope display overrides to an open state, such as `dialog[open]`.
- Preserve the requested dismissal behavior. `closedby="any"` adds light dismissal, which is a product choice. Unsupported browsers ignore it; keep an explicit close control and implement required behavior only for affected targets.
- For an existing unsaved-change guard, handle cancellation as well as explicit close controls. `closedby="none"` alone cannot protect data in browsers that ignore the attribute.
- If actions depend on `dialog.returnValue`, reset it between openings or after handling closure. Escape can otherwise leave a previous action value in place.

## Forms

- Use `:user-invalid` for native validation styling after interaction or a submit attempt, avoiding errors on untouched required fields. Keep visible error text associated with the field; CSS alone does not announce an error or update `aria-invalid` for custom validation.
- Retain the application's validation rules and server-side checks. A styling change does not justify new password requirements or stricter email rules.
- Prefer native form submission. In a custom Enter handler, check `event.isComposing` before submitting so confirming an IME candidate does not send the form. After choosing to handle submission, prevent the default action and use `requestSubmit()` to retain validation and submit events. Test the target browsers' composition event ordering.
- Some Safari versions dispatch `compositionend` before the confirming Enter handler, making `isComposing` insufficient. For affected targets, use a tested workaround such as checking `keyCode === 229` inside the Enter-key branch, as described in the source guide; avoid arbitrary delays that swallow a subsequent deliberate Enter.
- Treat `field-sizing: content` as an enhancement for growing inputs and textareas. Bound growth with suitable minimum and maximum sizes, and check explicit width/height and grid/flex stretching when sizing fails.
- A standard scrollable field is usually a sufficient sizing fallback. Add mirrored-content or measurement code only when automatic growth is required on unsupported targets.

## Intrinsic size and state transitions

- For an existing expand/collapse interaction, consider `interpolate-size: allow-keywords` before measuring content in JavaScript. Scope the inherited opt-in to the affected component. Interpolation needs a numeric endpoint; two intrinsic keywords cannot interpolate directly.
- Give `calc-size()` a valid preceding size declaration for browsers that ignore it. Unsupported animation can fall back to an immediate state change.
- Reduced motion must preserve opening, closing, and focus behavior. Do not rely solely on `transitionend` to complete a state change; no event is guaranteed when animation is disabled or absent.
- Collapsing height or opacity does not remove focusable descendants or accessible content. Coordinate hidden/inert state, focus, and expanded state with the component's actual visibility.

## Verification

Exercise keyboard opening and dismissal, focus return, IME confirmation, invalid submission, long field values, narrow layouts, and reduced motion for the behavior changed. Verify the required fallback in the target browser; a successful feature-detection check does not prove the complete interaction works.

## Sources

- [Browser policy and Baseline](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/SKILL.md)
- [Dialogs](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/ui-components/dialog.md)
- [Validation after interaction](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/forms/validate-input-after-interaction.md)
- [IME-safe submission](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/forms/ime-safe-enter-submit.md)
- [Automatic field sizing](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/forms/form-fields-automatically-fit-contents.md)
- [Intrinsic size animation](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/css/animate-to-intrinsic-sizes.md)
