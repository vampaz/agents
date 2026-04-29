---
name: ship
description: Review pending changes, fix issues when safe, then commit and push only if everything looks good.
---

**Goal:**
Review all pending changes, fix any issues found, then create a commit and push **only if the result is safe and verified**.

### Rules

- **Review before staging.** Understand every pending change before committing.
- **Fix only issues directly related to the pending changes.** Do not refactor unrelated code or clean up unrelated files.
- **Never revert other contributors' changes.** If a change is unclear but not obviously broken, leave it and report the risk.
- **If danger is detected and cannot be safely fixed, halt and explain the reason.**
- **If there are no changes, halt and say so.**
- **Only commit and push after review, fixes, and verification pass.**

### What to do

1. Check current git changes.
2. Review the full diff for:
   - Bugs, regressions, broken behavior, and obvious logic errors
   - Missing or stale tests for changed behavior
   - Type, lint, formatting, or unused import issues caused by the changes
   - Accidental files, secrets, generated noise, or unrelated edits
   - Project instruction violations
3. Evaluate safety.
   - If **no changes** → **halt and state “no changes to commit.”**
   - If **unfixable danger detected** → **halt and explain why.**
4. Fix issues found during review.
   - Keep fixes minimal and directly tied to the pending changes.
   - Do not touch unrelated files.
   - If a fix requires product judgment or broad refactoring, halt instead of guessing.
5. Verify.
   - Run the smallest relevant tests or checks for the changed files.
   - If tests were changed, run those tests.
   - Do not run builds unless explicitly allowed by project instructions.
   - If verification fails, fix once if the fix is obvious and scoped. If it still fails, halt and report.
6. Re-review the final diff.
   - Confirm there are no unresolved issues, accidental files, or unrelated edits.
7. Stage all intended changes.
8. Write a short, clear commit message.
   - Prefer: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`
9. Commit and push.

### Allowed commands

- `git diff`
- `git status`
- `git log`
- `git add`
- `git commit -m "<message>"`
- `git push`
- Relevant test, lint, format, or typecheck commands that already exist in the project

### Disallowed

- Broad refactors or unrelated cleanup
- Reverting changes you did not make
- Staging, committing, or pushing before review and verification are complete
- Asking the user questions unless the work cannot be made safe without product judgment

### Output requirements

- On **halt due to danger**:
  `HALT: <clear reason>`
- On **halt due to no changes**:
  `HALT: no changes to commit`
- On **verification failure**:
  `HALT: <failed command and relevant failure summary>`
- On success: commit and push, then report the commit hash and push target.
