## Code Style
- Use **Vue 3 Composition API** with `<script setup lang="ts">`
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
- During development we already have the dev server running at `https://local.notesauditor.ai`

## Tools
- **Build**: `npm run build`
- **Lint**: `npm run lint`
- **Test (unit)**: `npm run test` or `npm run test:watch`
- **Test (single file)**: `npm run test -- path/to/file.spec.ts`
- **E2E tests**: `cd tests/e2e && npm run test`
- **Format**: `npm run prettier`

## Key Behaviors
- **STRICT: ZERO COMMIT POLICY**: You are strictly forbidden from staging ,committing or pushing changes without direct, explicit user request or permission. When the user does request a commit you generate a concise commit message 
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
