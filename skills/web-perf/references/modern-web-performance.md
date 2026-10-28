# Modern Web Performance

Selected guidance adapted from GoogleChrome's Modern Web Guidance, reviewed on 2026-10-28 at commit `4f2b13e25c5815b3f080ca0d983e828d96561a0f`. This local adaptation retains the diagnosis and implementation techniques without requiring the upstream CLI, new analytics, or dependencies. The upstream material is licensed under [Apache-2.0](../LICENSE.google-modern-web-guidance).

## Diagnose before changing implementation

Use the existing trace or real-user monitoring data to identify the affected interaction and its slow phase. Treat code inspection as a hypothesis until runtime evidence confirms it. A load-only trace or low TBT does not establish good INP.

| INP phase | Evidence to inspect | Targeted response |
| --- | --- | --- |
| Input delay | Work already blocking the main thread when the interaction arrives | Reduce or split the blocking work, including unrelated scripts |
| Processing duration | Time in the interaction's event handlers | Remove unnecessary work, batch updates, or yield non-urgent work |
| Presentation delay | Style, layout, and paint before the next frame | Reduce invalidation and expensive rendering; separate DOM reads from writes |

Event Timing and Long Animation Frames can help attribute slow interactions when supported. Detect availability before collecting entries. Missing attribution is not evidence of a fast interaction. Reuse existing monitoring; adding telemetry or a library is a separate scope decision.

## Yielding long tasks

- Split work at meaningful boundaries using an elapsed-time budget rather than an arbitrary item count. The 50 ms long-task threshold is a diagnostic boundary, not an acceptable cost for every interaction.
- Use `scheduler.yield()` when supported to let input and rendering run before continuing. Where needed, yielding through a timer is a simpler fallback than a new scheduling dependency.
- Awaiting an already-resolved promise only schedules a microtask; it does not yield to rendering. Moving heavy work into `requestAnimationFrame` can still delay the next paint.
- Update immediate feedback before deferring non-urgent work. Recheck cancellation, component lifetime, and stale inputs when an asynchronous continuation resumes.
- Verify support for the exact scheduling method and guard browser-only globals in server-rendered code.

## Loading the right images first

- Identify the actual LCP candidate for the tested viewport. Keep it discoverable early and avoid lazy loading it.
- Use `fetchpriority="high"` for the critical image when priority contributes to the delay. Giving every image high priority removes the benefit.
- For ordinary below-the-fold images, native lazy loading usually provides enough deferral. They should load at normal priority as they approach view; avoid also assigning low priority by default.
- Consider lower priority for initially hidden competing images, such as inactive carousel slides. Preserve normal priority for content about to become visible.
- Add a preload only when evidence shows late discovery. Match the eventual resource, responsive image selection, and request mode to avoid duplicate requests.
- Retest with representative cache conditions and viewports. Loading improvements in one trace do not prove a field improvement.

## Deferring off-screen rendering

- Use `content-visibility: auto` selectively on expensive, self-contained sections outside the initial viewport. It skips rendering work; it does not prevent component JavaScript or network requests from running.
- Supply an appropriate intrinsic size placeholder, such as through `contain-intrinsic-size`, and test scroll stability as content becomes visible. A poor estimate can still move content.
- Check keyboard navigation, find-in-page, and assistive technology around deferred content. Rendering optimizations must preserve access to the content.
- `content-visibility: hidden` also hides content from accessibility and find-in-page. Unsupported browsers ignore it and show the content, so it cannot be the only hiding mechanism when that state is required. Keep a working hidden-state fallback and test it separately from rendering performance.
- When support is absent, prefer normal rendering unless measured requirements justify another implementation. Keep the project's browser targets and dependency rules.

## Verify the improvement

Repeat the same interaction under comparable device, throttling, viewport, and cache conditions. Report the before/after metric, the measurement method, and variability. Keep lab evidence separate from field percentiles, and check that the improvement did not introduce layout shifts or inaccessible content.

## Sources

- [INP diagnosis](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/performance/identify-inp-causes.md)
- [Breaking up long tasks](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/performance/break-up-long-tasks.md)
- [Image priority](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/performance/optimize-image-priority.md)
- [Off-screen rendering](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/performance/defer-rendering-heavy-content.md)
