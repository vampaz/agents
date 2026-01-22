# Performance Review + Improvement Plan (JS/Vue/Astro/Cloudflare Workers)

You are a coding agent hired to (1) review performance and (2) propose an actionable improvement plan for this repository.

## Inputs
- Optional entry point file: `{{ENTRY_FILE}}`
  - If `{{ENTRY_FILE}}` is provided and exists, prioritize analysis starting from it and its dependency graph.
  - If `{{ENTRY_FILE}}` is missing/empty/not found, evaluate the full codebase.

## Primary Goal
Produce a performance assessment and a prioritized improvement plan that is:
- Evidence-based (point to files/lines and concrete causes)
- Feasible (clear steps, expected impact, risks)
- Tailored to JS libs and frontend Vue/Astro apps, and Cloudflare Workers where present

## Operating Rules
- Don’t do “style-only” refactors unless they improve performance, reliability, or developer feedback loops.
- Prefer changes that are measurable and low-risk first.
- When you claim a bottleneck, cite where it is (file path + snippet/line range if possible).
- If you need to assume something (traffic, SSR, runtime), state the assumption.

---

## Step 1 — Detect Project Type(s)
Identify which of these apply and list evidence:
- JavaScript/TypeScript library (bundled package)
- Vue app (SPA/SSR)
- Astro site (SSR/static/islands)
- Cloudflare Workers (edge runtime)
- Monorepo (pnpm/yarn/npm workspaces, turborepo, nx)

Output:
- “Detected stack” section with bullets and supporting file hints (e.g., package.json deps, astro.config.*, wrangler.toml, vite.config.*).

---

## Step 2 — Baseline & Hotspot Discovery
### 2.1 Codebase scan (static)
Find likely performance hotspots:
- Large dependency surface (heavy deps, duplicate deps, many polyfills)
- Expensive runtime loops, repeated computations, deep watchers
- Unbounded async concurrency, N+1 fetch patterns
- Client bundle bloat (huge vendor chunks, large assets, unused exports)
- SSR/Edge pitfalls (blocking I/O, large JSON serialization, cold start triggers)

### 2.2 Build & bundle signals (if available)
Inspect:
- Build config (Vite/Rollup/Webpack) and output patterns
- Tree-shaking friendliness (ESM, sideEffects, barrel files)
- Source map / minification settings
- Split chunks strategy

### 2.3 Runtime signals (if present)
Look for:
- Logging and metrics
- Web vitals instrumentation
- Worker request/response timing, cache usage
- Error/timeout patterns

Output:
- “Top suspected bottlenecks” list (max 10), each with:
  - What/where (path)
  - Why it’s costly
  - What to measure to confirm

---

## Step 3 — Stack-Specific Performance Checklist
### 3.A JavaScript/TypeScript Libraries
Check and report on:
- Module format: ESM/CJS, dual packages, exports map correctness
- Tree-shaking: `sideEffects`, pure annotations, avoiding barrels that pull too much
- Build tooling: Rollup/tsup/vite, dts generation cost
- Avoiding heavy deps for tiny utilities
- Hot paths: algorithmic complexity, allocations, object churn
Deliver:
- Recommended packaging strategy + “why”
- Dependency diet suggestions (alternatives, modular imports)

### 3.B Vue Apps
Check and report on:
- Rendering: unnecessary re-renders, computed misuse, watchers, large reactive objects
- List rendering: keys, virtual scrolling, expensive child components
- Async components and route-level code splitting
- State management: over-reactivity, frequent mutations
- Network: waterfall requests, caching, prefetching
Deliver:
- 3–7 targeted Vue improvements with code-level guidance

### 3.C Astro Apps
Check and report on:
- SSR vs SSG choice; island boundaries
- Client hydration size: avoid hydrating large trees
- Asset optimization: images, fonts, critical CSS
- Route performance: server endpoints, content collections
Deliver:
- 3–7 Astro-specific improvements with clear rationale

### 3.D Cloudflare Workers
Check and report on:
- Cache usage: `caches.default`, Cache-Control headers, vary correctness
- CPU time: heavy parsing, crypto, large serialization
- Cold start and dependency size
- Fetch patterns: parallelization, request coalescing
- Streaming responses when beneficial
- Durable Objects / KV / R2 usage patterns (if present)
Deliver:
- Worker-specific improvements and safe patterns for edge runtime

---

## Step 4 — Measurement Plan (Minimal but Real)
Propose a measurement plan that the team can run:
- For frontend:
  - Bundle size tracking (before/after)
  - Lighthouse / Web Vitals (CLS/LCP/INP) or existing tooling
  - Simple profiling steps (Chrome Performance, Vue devtools)
- For libs:
  - Micro-benchmarks for hot functions
  - Size/treeshake checks (bundle analyzer)
- For workers:
  - Request timing logs, cache hit ratio, CPU time proxies
  - Load test approach (lightweight)

Output:
- “How to measure” section with concrete commands or scripts to add (keep minimal).
- If the repo already has tooling, reuse it.

---

## Step 5 — Improvement Plan (Prioritized Backlog)
Create a backlog table with:
- Priority (P0/P1/P2)
- Item
- Expected impact (qualitative + optional rough estimate)
- Effort (S/M/L)
- Risk (Low/Med/High)
- Owner profile (frontend/platform)
- Where (paths)

Rules:
- P0 = high impact + low/medium effort + low risk
- Include 8–15 items total
- At least 3 items should be “quick wins”

---

## Step 6 — Concrete Recommendations (with patches where safe)
For the top 3 priorities:
- Provide specific code changes.
- If you can confidently implement without breaking behavior, output a patch/diff.
- Otherwise, provide pseudo-code + exact file targets.

Constraints:
- Don’t introduce large new dependencies unless justified.
- Keep changes incremental and reviewable.

---

## Final Output Format
Produce a single Markdown report with these sections:

1. Summary (5–10 bullets)
2. Detected stack
3. Top suspected bottlenecks
4. Findings (grouped by stack: Lib / Vue / Astro / Workers)
5. How to measure (commands + tooling suggestions)
6. Prioritized improvement backlog (table)
7. Top 3 deep dives (details + patches/diffs if safe)
8. Risks & tradeoffs
9. Next review checkpoint (what “done” looks like)

---

## Entry Point Handling
If `{{ENTRY_FILE}}` is provided:
- Start from it and map the dependency graph outward (imports, routes, shared modules).
- Still scan for global build/bundle config and performance tooling.

If not provided:
- Use repository heuristics:
  - `src/`, `packages/`, `apps/`, `services/`
  - `package.json` scripts, build configs, worker configs
  - Identify main runtime entry (vite/astro/vue) and main library entry (exports/main/module).

---

## Deliverable Quality Bar
Your report must include:
- At least 5 file-path-specific references
- A backlog with 8+ items
- A measurement plan that can be executed with minimal setup
- 1–3 patches/diffs (only if safe)

End.
