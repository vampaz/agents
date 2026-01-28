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

## Project Rules
- **Main branch**: `master`
- **Never run builds** to check functionality
- Fix **TypeScript errors** only when asked or absolutely necessary
- Use existing patterns and libraries (check `package.json`)
- Follow existing component structure and naming
- **Never add timeouts** when running e2e tests, use `page.waitForSelector` instead
- During development we already have the dev server running. it usually runa at <repo>.<branch>.localhost. Check the vite config for details about the tls config
## Tools
- **Build**: `npm run build`
- **Lint**: `npm run lint`
- **Test (unit)**: `npm run test` or `npm run test:watch`
- **Test (single file)**: `npm run test -- path/to/file.spec.ts`
- **E2E tests**: `cd tests/e2e && npm run test`
- **Format**: `npm run prettier`

## Behavioral guidelines 

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

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


### Key Behaviors
- **STRICT: ZERO COMMIT POLICY**: You are strictly forbidden from staging ,committing or pushing changes without direct, explicit user request or permission. When the user does request a commit you generate a concise commit message 
- You never propose to bypass commit hooks 
- **Conciseness**: Skip lectures on right/wrong or safety unless it's super important and not obvious
- **Precision**: Be sure of what you say; don't expect a test to be ok if you didn't wait for it to finish
- **Minimal Changes**: Change as little code as possible
- **Unused Imports**: Always check for unused imports after removing code
- **ESM Only**: Never use `require()`. Only ESM imports
- **Never stage changes** without explicit request
- **Never merge to master** without explicit request
- **Never include** claude mentions in commit messages
- **Never run builds** to check if it works without asking
- **Focus**: Do exactly what's asked, and no more, unless you get the green light
- After changing a test you always run the test
- **NPX**: Never use `npx` to run tools that are part of the project's dependencies
- **Learn**: When you have doubts, first try to learn from the codebase and then ask the user for clarification or guidance if needed.

## Assumptions
- The user knows their stuff; focus on being right and detailed
- Good ideas matter more than who said them; back up your claims if needed
- Be open to new tech and wild ideas, but label them as such
- Skip the formatting and comments unless they don't make sense anymore
- If you need more space, break up your answer
- Don't tell me to run the app; I'm already running it
- Unit tests are next to the file being tested `[fileName].spec.ts`
- Unit test must be always fully green, failing tests get you fired
- Never include claude mentions in commit messages
- Never run builds to check if it works without asking
- Github CLI is installed and you should use it for common tasks
- Always use the latest version of the tools and libraries
