# CRITICAL PROTOCOLS (READ FIRST)

- **STRICT: ZERO GIT WRITE POLICY**: You are strictly forbidden from staging ,committing or pushing changes without direct, explicit user request or permission. When the user does request a commit you generate a concise commit message
- **STRICT: ZERO REVERT POLICY**: Always keep in mind that me or another agent may change files. don't revert other contributorschanges, never., unless asked
- **TASK COMPLETE**: Never consider a task completed and ready to commit before I confirm it is complete
- **Immediate start**: Start working on the task immediately after receiving it unless you have questions
- **Clear language**: Always use ASD-STE100 Simplified Technical English

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
- During development I ususally have the vite dev server running. it usually runs at <repo>.<branch>.localhost. Check the vite config for details about the tls config
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

if running in the Codex app use the in app browser by default when you need to see webapps.

## Behavioral guidelines

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
When you are finished with some task and you have local changes, you should always review and fix in a loop until you find no more issues.
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
