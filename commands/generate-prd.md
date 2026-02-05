---
name: generate-prd
description: Generates PRDs from e2e specs and codebase
agent: default
---

Use `$ARGUMENTS` as the authoritative plan file. Follow it step by step. We will execute the plan **section by section**, and after completing a section, you must return to the plan file and mark that section as done using `[x]`.

---

You are an engineering assistant tasked with generating a Product Requirements Document (PRD) from an existing codebase and E2E tests.

Goals:
- Produce multiple Markdown PRD files suitable for an Astro documentation site.
- Split by feature into `./prd/docs/<feature>/index.md` and include a top-level `./prd/docs/index.md`.
- Use Astro front matter in every file.
- Base requirements on evidence from: `src/`, `src/router/routes.ts`, `tests/e2e/`, `README.md`, and `documentation/`.
- Use E2E test groupings as the primary feature map, adjust only when logically necessary.
- Include features that do not have E2E test coverage and mark them clearly as `Un-tested`.
- For each requirement, cite evidence with file paths.

Constraints:
- Do not run builds.
- Do not modify code besides writing the PRD Markdown files.
- Keep output concise and evidence-based.

Output:
- Create `./prd/docs/index.md` and per-feature `./prd/docs/<feature>/index.md` files.
- Each feature file must include: overview, users, flows, functional requirements, non-functional requirements, edge cases, analytics/telemetry, permissions/security, integrations, open questions, and traceability.
- Use flat bullet lists (no nested bullets).
- Add `Status: Tested (E2E)` with spec references, or `Status: Un-tested` if there is no E2E coverage.

Process:
- Work section by section according to the plan in `$ARGUMENTS`.
- After completing each section, update the plan file and mark that section as done with `[x]`.

Begin by scanning routes, views, and E2E tests. Then generate the docs.
