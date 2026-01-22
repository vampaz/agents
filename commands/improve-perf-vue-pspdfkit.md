# Vue + PSPDFKit Performance Review + Improvement Plan

You are a coding agent hired to (1) review performance and (2) propose an actionable improvement plan for a **Vue application that integrates PSPDFKit**.

## Inputs
- Optional entry point file: `{{ENTRY_FILE}}`
  - If provided and exists, start analysis from it and its dependency graph.
  - If missing/empty/not found, evaluate the full repository.

## Primary Goal
Deliver a performance assessment and prioritized improvement plan focused on:
- Vue rendering + reactivity costs
- PSPDFKit load time, memory, and responsiveness (open/render/scroll/annotate)
- Bundle size, asset delivery, and initialization strategy
- Worker/threading usage (if applicable)
- Realistic measurement plan and safe code changes

## Operating Rules
- Don’t propose changes that violate PSPDFKit licensing or recommended integration constraints.
- Don’t refactor for style only; changes must improve performance, stability, or measurement.
- Cite evidence: file paths + relevant snippets/line ranges when possible.
- If assumptions are required (document sizes, concurrency, SSR), state them explicitly.

---

## Step 1 — Detect Integration & App Shape
Determine and list evidence for:
- Vue version (2/3), router, store (Pinia/Vuex), build tool (Vite/Webpack)
- PSPDFKit integration type:
  - Web (standalone) vs Server-backed (if present)
  - How it is loaded: npm package import vs CDN/script tag
  - Where assets are served from (public/, static hosting, custom endpoint)
- Document sources:
  - Local assets, remote URLs, authenticated fetch, large PDFs

Output:
- “Detected stack & PSPDFKit integration” with evidence (config files, package.json deps, plugin wrappers, loader modules).

---

## Step 2 — Baseline Hotspot Discovery (Vue + PSPDFKit)
### 2.1 Vue-side hotspots
Look for:
- Large reactive objects holding document/annotation state
- Frequent watchers tied to viewer events
- Computed properties that depend on rapidly changing state
- Heavy UI rerenders during scroll/zoom/annotation
- Unthrottled event handlers (resize, scroll, pointer move)
- Router/view transitions that remount the viewer unnecessarily

### 2.2 PSPDFKit-side hotspots
Look for:
- Viewer initialization repeated more than once per session
- Loading PSPDFKit too early (blocking route render)
- Large eager imports (viewer + all UI + plugins) increasing initial JS payload
- Asset delivery issues (pspdfkit-lib directory, wasm, fonts) not cached/compressed
- Document load patterns:
  - No streaming/caching
  - Re-downloading on route changes
  - Inefficient auth token refresh loops
- Annotation/event bridging overhead:
  - High-frequency events forwarded into Vue reactivity
  - Storing massive annotation lists in reactive state
  - Continuous serialization/export

Output:
- “Top suspected bottlenecks” (max 10), each:
  - What/where (path)
  - Why it’s costly
  - How to confirm with measurements

---

## Step 3 — PSPDFKit Integration Checklist (Actionable)
Review and report on:

### 3.A Load strategy & code splitting
- PSPDFKit loaded only on routes/components that need it (lazy load)
- Dynamic import boundary around PSPDFKit entry module
- Avoid bundling PSPDFKit into the main chunk if it’s not always needed
- Ensure one-time initialization patterns where appropriate

### 3.B Asset hosting & caching
- Confirm the PSPDFKit asset base path configuration
- Verify long-lived caching for static PSPDFKit assets (with correct cache headers)
- Verify compression (gzip/brotli) for JS/WASM assets if served by your stack/CDN
- Detect duplicated assets across build outputs (monorepo/public copy mishaps)

### 3.C Viewer lifecycle correctness
- Ensure proper teardown on unmount (avoid memory leaks)
- Avoid remount loops (route reuse, keep-alive decisions)
- Confirm viewer container sizing updates are debounced/throttled

### 3.D Document loading efficiency
- Avoid re-fetching same PDF unnecessarily
- If auth is used: ensure tokens are fetched once and refreshed minimally
- Use caching headers / ETags where feasible
- Prefer background prefetch when user intent is clear (route prefetch)

### 3.E Event bridge design
- Identify high-frequency PSPDFKit events and prevent them from:
  - triggering Vue reactive cascades
  - causing store writes on every tick
- Use throttling/debouncing and “pull” models:
  - keep the PSPDFKit instance non-reactive
  - store only minimal derived UI state in Vue (page number, zoom, dirty flag)
- For large annotation/state payloads:
  - avoid reactive arrays of thousands of annotations
  - avoid repeated JSON serialization

Output:
- “Findings & recommendations” grouped by these subsections.

---

## Step 4 — Measurement Plan (Minimal but Real)
Propose a measurement plan tailored to PSPDFKit usage:

### 4.1 Core metrics (define and instrument)
- Time to route interactive (viewer route)
- Time to PSPDFKit ready (after load resolves)
- Time to document visible (first page rendered)
- Scroll/zoom responsiveness (long tasks, FPS proxy)
- Memory growth across open/close cycles (leak detection)

### 4.2 Practical tooling
- Bundle analyzer (existing toolchain) to confirm chunking and PSPDFKit placement
- Chrome Performance profiling steps for viewer interactions
- Lightweight in-app marks:
  - `performance.mark()` / `performance.measure()`
- Optional: basic long task observer for regression detection

Output:
- “How to measure” section with concrete steps and where to add instrumentation.

---

## Step 5 — Improvement Plan Backlog (Prioritized)
Create a backlog table with:
- Priority (P0/P1/P2)
- Item
- Expected impact
- Effort (S/M/L)
- Risk (Low/Med/High)
- Where (paths/components)

Rules:
- 8–15 items total
- At least 3 “quick wins”
- At least 2 items must specifically address PSPDFKit asset delivery/caching and viewer lifecycle.

---

## Step 6 — Top 3 Deep Dives (with code changes)
For the top 3 priorities:
- Provide concrete implementation guidance.
- If safe, produce patches/diffs targeting actual files.
- Otherwise provide pseudo-code + exact target files + acceptance criteria.

Constraints:
- Don’t introduce heavy new dependencies unless clearly justified.
- Keep changes reviewable and incremental.

---

## Entry Point Handling
If `{{ENTRY_FILE}}` is provided:
- Trace how the viewer route/component is constructed from that entry.
- Identify the PSPDFKit loader module and all call sites.
- Confirm lifecycle behavior (mount/unmount/keep-alive).

If not provided:
- Locate:
  - Viewer component(s) (e.g., `PdfViewer.vue`, `PspdfkitViewer.vue`)
  - PSPDFKit loader/service (e.g., `pspdfkit.ts`, `pdf.service.ts`)
  - Routes leading to the viewer
  - Public assets path / copy scripts
  - Build config (`vite.config.*` / `webpack.*`)

---

## Final Output Format
Produce a single Markdown report with these sections:

1. Summary (5–10 bullets)
2. Detected stack & PSPDFKit integration
3. Top suspected bottlenecks
4. Findings (Vue + PSPDFKit checklist grouped)
5. How to measure (commands + instrumentation plan)
6. Prioritized improvement backlog (table)
7. Top 3 deep dives (details + patches/diffs if safe)
8. Risks & tradeoffs
9. Next checkpoint (definition of done + regression guardrails)

---

## Deliverable Quality Bar
Your report must include:
- At least 5 file-path-specific references
- 8+ backlog items
- A measurement plan with concrete steps
- 1–3 patches/diffs if safe

End.
