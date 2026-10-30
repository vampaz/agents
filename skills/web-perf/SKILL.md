---
name: web-perf
description: Audit and improve web performance, using Chrome DevTools MCP for live measurements. Covers Core Web Vitals (LCP, INP, CLS), loading diagnostics, rendering, long tasks, caching, and accessibility gaps. Use when asked to audit, profile, debug, or optimize page loading, interaction responsiveness, Lighthouse scores, or site speed.
---

# Web Performance Audit

Audit web page performance using Chrome DevTools MCP tools. This skill focuses on Core Web Vitals, network optimization, and high-level accessibility gaps.

For implementation guidance adapted from Google's Modern Web Guidance, read [references/modern-web-performance.md](references/modern-web-performance.md) when fixing image loading, long tasks, poor INP, or expensive off-screen rendering. These local references also support code review without a running browser.

## Live Measurement Tools

For a live audit, discover the available Chrome DevTools MCP tools before following the measurement workflow below. Use the actual tool schemas; names and arguments can vary by harness.

If browser measurement tools are unavailable, continue with source analysis when code is available and mark runtime metrics as unmeasured. If neither a browser nor source is available, report the missing evidence. Installing tools or changing harness configuration is a separate task.

For UI changes or requested UI review, missing browser checks also leave UI validation incomplete under the shared instructions.

## Key Guidelines

- **Be assertive**: Verify claims by checking network requests, DOM, or codebase—then state findings definitively.
- **Verify before recommending**: Confirm something is unused before suggesting removal.
- **Quantify impact**: Use estimated savings from insights. Don't prioritize changes with 0ms impact.
- **Skip non-issues**: If render-blocking resources have 0ms estimated impact, note but don't recommend action.
- **Be specific**: Say "compress hero.png (450KB) to WebP" not "optimize images".
- **Assess each metric**: Good loading and layout stability do not establish good responsiveness. Measure interactions before assessing INP.

## Quick Reference

| Task | Tool Call |
|------|-----------|
| Load page | `navigate_page(url: "...")` |
| Start trace | `performance_start_trace(autoStop: true, reload: true)` |
| Analyze insight | `performance_analyze_insight(insightSetId: "...", insightName: "...")` |
| List requests | `list_network_requests(resourceTypes: ["Script", "Stylesheet", ...])` |
| Request details | `get_network_request(reqid: <id>)` |
| A11y snapshot | `take_snapshot(verbose: true)` |

## Workflow

Copy this checklist to track progress:

```
Audit Progress:
- [ ] Phase 1: Performance trace (navigate + record)
- [ ] Phase 2: Core Web Vitals analysis (includes CLS culprits)
- [ ] Phase 3: Network analysis
- [ ] Phase 4: Accessibility snapshot
- [ ] Phase 5: Codebase analysis (skip if third-party site)
```

### Phase 1: Performance Trace

1. Navigate to the target URL:
   ```
   navigate_page(url: "<target-url>")
   ```

2. Start a performance trace with reload to capture page-load metrics. Record cache state, device, and throttling; a reload alone does not establish a cold cache:
   ```
   performance_start_trace(autoStop: true, reload: true)
   ```

3. Wait for trace completion, then retrieve results.

**Troubleshooting:**
- If trace returns empty or fails, verify the page loaded correctly with `navigate_page` first
- If insight names don't match, inspect the trace response to list available insights

### Phase 2: Core Web Vitals Analysis

Use `performance_analyze_insight` to extract key metrics.

Core Web Vitals are LCP, INP, and CLS. FCP, TBT, Speed Index, and TTFB are supporting diagnostics. A page-load trace alone does not measure representative INP: record the affected interactions and separate input delay, event processing, and presentation delay using the local performance reference. Label lab measurements separately from field data; field assessment uses the 75th percentile, segmented by mobile and desktop. See [Web Vitals](https://web.dev/articles/vitals).

**Note:** Insight names may vary across Chrome DevTools versions. If an insight name doesn't work, check the `insightSetId` from the trace response to discover available insights.

Common insight names:

| Metric | Insight Name | What to Look For |
|--------|--------------|------------------|
| LCP | `LCPBreakdown` | Time to largest contentful paint; breakdown of TTFB, resource load, render delay |
| CLS | `CLSCulprits` | Elements causing layout shifts (images without dimensions, injected content, font swaps) |
| Render Blocking | `RenderBlocking` | CSS/JS blocking first paint |
| Document Latency | `DocumentLatency` | Server response time issues |
| Network Dependencies | `NetworkRequestsDepGraph` | Request chains delaying critical resources |

Example:
```
performance_analyze_insight(insightSetId: "<id-from-trace>", insightName: "LCPBreakdown")
```

**Key thresholds (good/needs-improvement/poor):**
- TTFB: < 800ms / < 1.8s / > 1.8s
- FCP: < 1.8s / < 3s / > 3s
- LCP: ≤ 2.5s / > 2.5s and ≤ 4s / > 4s
- INP: ≤ 200ms / > 200ms and ≤ 500ms / > 500ms
- TBT: < 200ms / < 600ms / > 600ms
- CLS: ≤ 0.1 / > 0.1 and ≤ 0.25 / > 0.25
- Speed Index: < 3.4s / < 5.8s / > 5.8s

### Phase 3: Network Analysis

List all network requests to identify optimization opportunities:
```
list_network_requests(resourceTypes: ["Script", "Stylesheet", "Document", "Font", "Image"])
```

**Look for:**

1. **Render-blocking resources**: JS/CSS in `<head>` without `async`/`defer`/`media` attributes
2. **Network chains**: Resources discovered late because they depend on other resources loading first (e.g., CSS imports, JS-loaded fonts)
3. **Late critical resources**: Confirm discovery delays in the waterfall before adding preloads for fonts, hero images, or key scripts; preloading everything creates competition.
4. **Caching issues**: Missing or weak `Cache-Control`, `ETag`, or `Last-Modified` headers
5. **Large payloads**: Uncompressed or oversized JS/CSS bundles
6. **Unused preconnects**: If flagged, verify by checking if ANY requests went to that origin. If zero requests, it's definitively unused—recommend removal. If requests exist but loaded late, the preconnect may still be valuable.

For detailed request info:
```
get_network_request(reqid: <id>)
```

### Phase 4: Accessibility Snapshot

Take an accessibility tree snapshot:
```
take_snapshot(verbose: true)
```

Verify contrast and visible focus in the rendered page, and exercise keyboard navigation to check for focus traps. An accessibility tree snapshot alone does not establish these results.

**Flag high-level gaps:**
- Missing or duplicate ARIA IDs
- Elements with poor contrast ratios (check against WCAG AA: 4.5:1 for normal text, 3:1 for large text)
- Focus traps or missing focus indicators
- Interactive elements without accessible names

## Phase 5: Codebase Analysis

**Skip if auditing a third-party site without codebase access.**

Analyze the codebase to understand where improvements can be made.

### Detect Framework & Bundler

Search for configuration files to identify the stack:

| Tool | Config Files |
|------|--------------|
| Webpack | `webpack.config.js`, `webpack.*.js` |
| Vite | `vite.config.js`, `vite.config.ts` |
| Rollup | `rollup.config.js`, `rollup.config.mjs` |
| esbuild | `esbuild.config.js`, build scripts with `esbuild` |
| Parcel | `.parcelrc`, `package.json` (parcel field) |
| Next.js | `next.config.js`, `next.config.mjs` |
| Nuxt | `nuxt.config.js`, `nuxt.config.ts` |
| SvelteKit | `svelte.config.js` |
| Astro | `astro.config.mjs` |

Also check `package.json` for framework dependencies and build scripts.

### Tree-Shaking & Dead Code

- **Webpack**: Check for `mode: 'production'`, `sideEffects` in package.json, `usedExports` optimization
- **Vite/Rollup**: Tree-shaking enabled by default; check for `treeshake` options
- **Look for**: Barrel files (`index.js` re-exports), large utility libraries imported wholesale (lodash, moment)

### Unused JS/CSS

- Check for CSS-in-JS vs. static CSS extraction
- Look for PurgeCSS/UnCSS configuration (Tailwind's `content` config)
- Identify dynamic imports vs. eager loading

### Polyfills

- Check for `@babel/preset-env` targets and `useBuiltIns` setting
- Look for `core-js` imports (often oversized)
- Check `browserslist` config for overly broad targeting

### Compression & Minification

- Check for `terser`, `esbuild`, or `swc` minification
- Look for gzip/brotli compression in build output or server config
- Check for source maps in production builds (should be external or disabled)

## Output Format

Lead with the conclusion and any required user action. Use short bullets for prioritized issues, each with its impact, evidence, and smallest fix. Include a compact metrics table when useful; label estimates and unmeasured metrics.

Do not repeat findings in separate recommendation and codebase sections. Include code snippets only when needed to make a fix clear, and state any unverified UI behavior.
