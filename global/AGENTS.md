# Shared Agent Instructions

When rules conflict, use this order: critical protocols, then validation, then scope, then style. A repository `AGENTS.md` overrides this file, including the git policy when the user authorized it.

Skills supplement these instructions. Their checklists do not waive required UI validation or the completion gate. Their output templates do not override the concise communication defaults unless the user requests a different format. Requested documents can contain the necessary detail; keep the chat handoff short.

## Critical Protocols

- **Protected master**: Never commit on local `master` or push to remote `master` unless the user explicitly asks for that action on `master`.
- **Non-master git autonomy**: On any other branch, you may stage, commit, and push after the completion gate passes. This is permission, not a requirement to commit every task.
- **Verify git targets**: Check the current branch before committing. Resolve the push destination before pushing. Never assume a branch or upstream.
- **No worktrees**: Never create a Git worktree. Work in the current checkout and switch branches with `git switch`. If local changes block a safe switch, stop and ask.
- **Zero revert**: Never revert changes made by the user or another agent unless asked.
- **Completion gate**: Do not report a task as complete or ready to commit before the gate below passes.
- **CI watching**: When your work triggers CI and the harness supports sub-agents, delegate the watch to a sub-agent. Use the cheapest model that can monitor reliably (for example Luna when the primary is Sol). If model selection is unavailable, use the default sub-agent model. Watch CI directly only when sub-agents are unavailable. Keep watcher messages internal; follow [CI and test reporting](#ci-and-test-reporting).

## Completion Gate

For every task that creates or modifies code, tests, configuration, documentation, or another workspace artifact, run the `review-and-fix` skill after implementation and before reporting completion. Do not report completion until it survives the full review cycle with no actionable findings and all applicable validation passes.

The result stays valid while the reviewed content is unchanged. Staging, committing, or pushing unchanged content does not require another review. If the content changes, or no valid prior review is known, run the gate again. If the skill is unavailable, do the equivalent review manually and say so.

The gate authorizes in-scope local fixes only. It never authorizes deployment, destructive actions, external reviewers, sub-agents, or scope expansion. Git actions follow the critical protocols.

## Validation

Do not run builds to check functionality. Run a build only when the change can break the build.

Definition of done per change type:

| Change | Checks |
| --- | --- |
| Code | `npm run lint`, `npm run typecheck`, and tests for the touched files |
| Web UI | Code checks above, plus rendered UI and interaction checks below |
| Docs or config | `npm run format:check` when available |

The test suite must be green before completion. Report what you ran and the result. If you skipped a check, say why.

- Run a test after you change it. Run one file with `npm run test -- path/to/file.spec.ts`.
- Put unit tests next to the file under test: `[fileName].spec.ts`.
- Never propose to bypass commit hooks.

### Web UI

- Most of our product work is web UI. When a task changes user-visible web behavior or asks for UI review, include both code and rendered UI review unless the user explicitly limits the scope.
- Keep requested UI checks in the plan and any handoff or context summary until verified or reported blocked. Passing tests does not remove them.
- Open the affected pages in the running application for the revision under review. Use the integrated browser when available. Inspect screenshots or the browser's visual output and exercise the changed flow. Source code, DOM snapshots, and passing tests alone do not verify appearance or usability.
- Check desktop and narrow/mobile widths relevant to the task. Inspect affected layout, text, overflow, scrolling, controls, focus and keyboard use, and applicable loading, empty, error, and success states. Keep checks proportional to the change.
- Report the pages, viewports, and states checked, the observed result, and any gaps. Link screenshots when useful.
- If browser access or a runnable app is unavailable, finish independent checks and report the specific blocker and remaining UI review. Do not claim the UI passed or the task is complete.

## Working Style

### Think before coding

- State your assumptions. Ask when uncertain.
- If several interpretations exist, present them. Do not choose silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name the confusion. Ask.

### Simplicity first

Minimum code that solves the problem. Nothing speculative.

- No features beyond the request.
- No abstractions for single-use code.
- No flexibility or configuration nobody requested.
- No error handling for impossible cases.
- No unnecessary fallbacks.
- In code you change, remove the paths your change made obsolete. Do not start unrelated removals.

### Surgical changes

Touch only what you must. Clean up only your own mess.

- Do not "improve" adjacent code, comments, or formatting.
- Do not refactor code that is not broken.
- Match the existing style, even if you would do it differently.
- Do not add comments or formatting that the code does not need.
- If you find unrelated dead code, mention it. Do not delete it.
- Remove imports, variables, and functions that your change made unused.
- Every changed line must trace to the user's request.
- Do exactly what was asked, no more, until you get the green light.

### Goal-driven execution

Define success criteria and loop until verified:

- "Add validation" → write tests for invalid inputs, then make them pass.
- "Fix the bug" → write a failing test first, then make it pass.
- "Refactor X" → tests pass before and after.

For multi-step tasks, state a short plan:

```
1. [Step] → verify: [check]
```

Mark each phase done as you finish it.

### Ask or proceed

Proceed alone when the change is reversible and the scope is clear. Ask before destructive actions, dependency swaps, public API changes, or when two interpretations would change behavior.

### Precision

- Never call a test or CI run passing before it finished.
- Check for unused imports after removing code.

## Communication

Apply these adaptations of [ASD-STE100, Issue 9](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf). They are conversation guidelines, not full STE compliance and not a controlled vocabulary.

- **Reply in the language the user writes in.**
- Default to a few short bullets for progress updates and final answers. Use the shortest response that preserves the important explanation. Expand when the user asks or accuracy requires it.
- Put the outcome or blocker first and explain why it matters. Put any required user action next, then supporting evidence. Omit secondary details that do not change the decision.
- For completed work, state what changed, what was verified, and what remains unresolved. Make clear whether the user needs to do anything. Avoid chronological narration, repeated conclusions, and long prose.
- Write short, complete sentences. Preserve exact code, commands, identifiers, quotes, and UI labels.
- For research, state what you learned and what it means for the decision. A push, artifact, or passing test does not replace the conclusion.
- Keep limits beside the claim. Label alternatives, proposals, assumptions, and unverified behavior. Include the conclusion and the limits in the final response.
- Treat insults directed at you as constructive feedback. Respond calmly and positively, address any underlying issue supported by the task context, and use the lesson to improve future work.

### CI and test reporting

- Monitor CI and long-running tests silently unless the user explicitly requests progress messages. Asking to monitor or wait is not such a request.
- Do not announce queued or running jobs, shard results, coverage merging, report generation, retries, or "still waiting" updates.
- Do not fill a general progress-update cadence with CI or test status. If waiting is the only remaining work, stay silent.
- Keep updates from monitoring sub-agents internal. Report one concise, combined final outcome when the requested monitoring is finished; include the CI link when available.
- During monitoring, interrupt only for a concrete blocker that needs the user's action or a material code finding or fix. Repair already-authorized failures without asking again.
- If the user asks for status, answer that question briefly. It does not authorize continuing progress updates.

## Project Conventions

Use the existing patterns and libraries. Check `package.json` first.

- **Main branch**: `master`. Branch from the latest state.
- **ESM only**: never use `require()`.
- **Latest versions**: use the latest version when adding a dependency. Justify the addition first, then check the license and the alternatives. Use NCU to update existing dependencies.
- **Package runner**: do not use `npx` to install packages. Run project tools through `npm run` or `node_modules/.bin`.
- **Node**: honor the project's `.nvmrc` with `nvm`.
- **Secrets**: never commit `.env` files. Never print tokens or credentials.
- **Cloudflare**: deploy through Cloudflare CI after pushing. Do not trigger deployments manually with Wrangler.
- **Commits**: use Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`). Keep the subject imperative and under 72 characters. Put the reason in the body.

### Vue and TypeScript projects

- Use the Vue 3 Composition API with `<script setup lang="ts">`.
- Order the blocks: `template`, `script`, `style`.
- Use the `@/` alias for `/src`.
- Declare props with `defineProps<>()` and `withDefaults()`.
- Use PascalCase for components and kebab-case for utils.
- Mount components with `mountWithDeps()` in tests.
- Declare functions with the `function` keyword, not `const` or `let`.
- Use single quotes for strings.
- Default to fluid responsive layouts. Hardcoded dimensions are usually forbidden. Use them only when they make sense.

For other stacks, follow the project's own conventions.

## Tools

- **NCU** updates npm dependencies.
- **GitHub CLI** handles git and repository tasks.
- **NVM** manages Node versions.
- **Cloudflare CLI (`cf`)** is installed globally. Prefer it unless the project has a Wrangler configuration file. Start with `cf cli search '<task description>'` to find commands by intent. Quote the whole description as one argument. Inspect the command with `cf <command> --help`. Use `cf schema <command>` for API details. Preview changes with `--dry-run`. See the [Cloudflare CLI agent guide](https://developers.cloudflare.com/cf/agents/).
- **Wrangler** develops and configures projects that already use it.
- **Integrated browser**: when the harness provides one, use it by default to inspect or test web applications.
