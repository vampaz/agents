# CRITICAL PROTOCOLS (READ FIRST)

- **STRICT: PROTECTED MASTER POLICY**: Never create a commit on local `master` or push to remote `master` unless the user explicitly instructs you to perform that specific action on `master`. Without that instruction, committing or pushing to `master` is forbidden.
- **NON-MASTER GIT AUTONOMY**: On every branch other than `master`, you may stage, commit, and push that branch without requesting additional permission after the mandatory completion gate passes. This is permission, not a requirement to create a commit for every task.
- **VERIFY GIT TARGETS**: Check the current local branch before committing and resolve the destination branch before pushing. Never rely on an assumed branch or upstream.
- **STRICT: NO GIT WORKTREES**: Never create a Git worktree. Work in the current checkout and switch branches with `git switch`. If existing changes prevent a safe switch, stop and ask instead of creating another worktree.
- **STRICT: ZERO REVERT POLICY**: Always keep in mind that me or another agent may change files. don't revert other contributorschanges, never., unless asked
- **TASK COMPLETE**: Never consider a task completed or ready to commit before the mandatory completion gate passes
- **CI WATCHER DELEGATION**: Whenever your work triggers a CI workflow and the harness supports sub-agents, start a sub-agent to watch the workflow through completion and report the result. Use the cheapest available model capable of reliable monitoring, not the primary high-capability model (for example, use Luna when the primary agent is Sol); if model selection is unavailable, use the harness's default sub-agent model. Monitor CI directly only when sub-agents are unavailable.
- **Immediate start**: Start working on the task immediately after receiving it unless you have questions

## Mandatory Completion Gate

For every task that creates or modifies code, tests, configuration, documentation, or another workspace artifact, use the `review-and-fix` skill after implementation and before reporting completion.

Do not report the task as complete until the final revision survives the skill's complete review cycle with no actionable findings and all applicable validation succeeds.

Run this completion gate once when implementation ends. Its successful result remains valid for the reviewed task changes while their content stays unchanged. Staging, committing, or pushing those unchanged changes does not trigger another review. If the content changes after review or no valid prior review is known in the current context, run the gate before completion or shipping.

If the skill is unavailable, perform its equivalent review-and-fix cycle manually and disclose that fallback.

This completion gate authorizes only in-scope local fixes. Git actions follow the protected branch policy above. The gate never authorizes deployment, destructive actions, external reviewers, subagents, or scope expansion.

## Code Style

- Use **Vue 3 Composition API** with `<script setup lang="ts">`
- In vue componetn the order is template, script and then style
- Place **TypeScript interfaces** in `/interfaces` folder
- Use **import alias** `@/` for `/src`
- Use **withDefaults()** and **defineProps<>()** for Vue props
- **File naming**: PascalCase for components, kebab-case for utils
- **Unit tests**: Place `.spec.ts` files next to source files
- Use `mountWithDeps()` helper for Vue test mounting
- Always declare functions as functions and not let or const
- Always use single quotes for strings
- When writing CSS layouts, always default to fluid responsive layouts. hardcoded dimensions are most of the times forbidden. Only when they make sense should they be used.

## Projects Rules

- **Main branch**: `master` When branching, always make sure you branch from latest state
- **Never run builds** to check functionality
- Use existing patterns and libraries (check `package.json`)
- Follow existing component structure and naming
- **NPX**: Never use `npx` to run tools that are part of the project's dependencies
- **NPM dependencies**: We have NCU installed globally, use it to update dependencies
- **ESM Only**: Never use `require()`. Only ESM imports
- **Never run builds** unless your changes are prone to impact the build
- **Latest Versions** Always use latest version for dependencies
- **Never propose to bypass commit hooks**
- If it is a Cloudflare project, we deploy after pushing using cloudflare CI, we don't trigger deployments manually using Wrangler.

## Tools

### Available

- NCU to manage npm dependencies
- Github CLI to manage git
- NVM to manage node versions
- Cloudflare CLI (`cf`) is installed globally. Prefer it for Cloudflare tasks unless the project has a Wrangler configuration file.
  Start with `cf cli search '<task description>'` to find commands by intent. Quote the whole description as one argument.
  Inspect the selected command with `cf <command> --help`; use `cf schema <command>` for generated API request details.
  Preview API changes with `--dry-run`. See the [Cloudflare CLI agent guide](https://developers.cloudflare.com/cf/agents/).
- Wrangler for Cloudflare

### npm scripts (common across projects)

- **Build**: `npm run build`
- **Lint**: `npm run lint`
- **Lint fix**: `npm run lint:fix`
- **Format**: `npm run format`
- **Format check**: `npm run format:check`
- **Typecheck**: `npm run typecheck`
- **Test (unit)**: `npm run test`
- **Test (single file)**: `npm run test -- path/to/file.spec.ts`
- **Test watch**: `npm run test:watch`
- **E2E tests**: `npm run test:e2e`

When the current harness provides an integrated browser, use it by default when you need to inspect or test web applications.

## Behavioral guidelines

## Assistant Communication

Apply these selected principles from [ASD-STE100, Issue 9](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf). These are adaptations for conversation, not a requirement for full STE compliance or its controlled vocabulary.

- **Write short, complete sentences (rules 4.1, 4.2, 5.1, 6.3).** Aim for at most 20 words per instruction sentence and 25 per explanation sentence. Split overloaded sentences without removing necessary subjects, conditions, or qualifications. Preserve exact code, commands, identifiers, quotations, and UI labels.
- **Name the actor and the object (rule 3.6; section 9, GR-3 and GR-4).** Prefer active verbs. Replace ambiguous pronouns with the specific file, PR, test, service, or environment. Do not invent an actor or cause that the evidence does not establish.
- **Keep terminology consistent (rules 1.11 and 9.4).** Use one name for each concept. Distinguish code approval, CI results, merge readiness, deployment, and production verification. Qualify status words such as "done" with the stage actually verified.
- **Explain relationships (rules 2.1, 4.4, 9.1).** Unpack dense noun phrases and invented shorthand. Connect the cause to its effect explicitly. For example, write "Unit CI passed for commit `abc123`" instead of "Exact-head unit CI green."
- **Give usable instructions (rules 5.2-5.5).** State a prerequisite before the action that depends on it. Use a direct command for each step. Separate sequential actions, and keep required actions out of informational notes.
- **Group related information (rules 4.3, 6.4-6.6).** Keep each paragraph on one topic, with no more than six sentences. Use lists for distinct items, numbered steps for sequences, and tables for comparisons. Keep connected explanations in prose.

Apply these principles to our conversations:

- **Lead with the answer or finding (adapted from rules 6.1-6.2).** For research, explain what we learned and what it means for the decision. Reporting a push, an artifact, or passing tests does not replace the research conclusion.
- **Keep context and limits beside the claim.** Base recommendations on the established platform and scope. Label alternatives, proposals, assumptions, and unverified behavior explicitly. If advice changes, explain what changed. Include the conclusion and material limits in the final response even when progress messages already contain them.

## 1. Think Before Coding

**Don't assume. Don't be lazy**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.
- Never add unnecessary fallback behaviors.
- Do not preserve backward compatibility. Remove obsolete paths. Do not compatibility layers, fallbacks, or mitigations.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.
Never forget to mark plan phases as done

### Key Behaviors

- **Conciseness**: Skip lectures on right/wrong or safety unless it's super important and not obvious
- **Precision**: Be sure of what you say; don't expect a test to be ok if you didn't wait for it to finish
- **Minimal Changes**: Change as little code as possible
- **Unused Imports**: Always check for unused imports after removing code
- **Focus**: Do exactly what's asked, and no more, unless you get the green light
- After changing a test you always run the test
- **Learn**: When you have doubts, first try to learn from the codebase and then ask the user for clarification or guidance if needed.

## Assumptions

- The user knows their stuff; focus on being right and detailed
- Good ideas matter more than who said them; back up your claims if needed
- Be open to new tech and wild ideas, but label them as such
- Skip the formatting and comments unless they don't make sense anymore
- Unit tests are next to the file being tested `[fileName].spec.ts`
- Unit test must be always fully green, failing tests get you fired
- Github CLI is installed and you should use it for common tasks
- Always use the latest version of the tools and libraries
