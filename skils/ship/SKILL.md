---
name: ship
description: Reuse a valid completed review or review pending changes when needed, then commit and push only if everything looks good.
---

**Goal:**
Ensure all pending changes have a current successful `review-and-fix` result, reusing the task's completed review when the content is unchanged. Then create a commit and push **only if the result is safe, verified, and allowed by the repository's protected branch policy**.

### Rules

- **Do not duplicate review.** If the exact current task changes already passed the completion review and their content has not changed, reuse that result instead of running the skill again. Staging unchanged content does not invalidate the review.
- **Review when needed.** Use the `review-and-fix` skill when no valid prior review is known or the content changed after review.
- **Protect `master`.** Never create a commit on local `master` or push to remote `master` unless the user explicitly instructs that specific action on `master`. Only perform the action or actions explicitly authorized.
- **Allow non-master autonomy.** On every branch other than `master`, no additional permission is required to stage, commit, or push after review and verification succeed.
- **Never revert other contributors' changes.** If a change is unclear but not obviously broken, leave it and report the risk.
- **If danger is detected and cannot be safely fixed, halt and explain the reason.**
- **If there are no changes, halt and say so.**
- **Only commit and push when a current successful `review-and-fix` result exists with no actionable findings and successful validation.**

### What to do

1. Check the current branch, intended push target, and git changes.
2. Evaluate safety.
   - If **no changes** → **halt and state “no changes to commit.”**
   - If creating the commit on local **`master`** or pushing to remote **`master`** lacks explicit authorization for that specific action → **halt before staging and explain that `master` is protected.**
   - If **unfixable danger detected** → **halt and explain why.**
3. Determine from the current task context whether the exact pending changes already completed the `review-and-fix` cycle successfully.
   - If they did and their content is unchanged, reuse that result. Do not repeat the review merely because shipping has started.
   - If they did not, the prior result is unknown, or the content changed afterward, use the `review-and-fix` skill before staging.
   - If the skill is unavailable when review is needed, perform its equivalent review-and-fix cycle manually and disclose that fallback.
   - If review reports a blocker, unresolved finding, or failed validation, halt and report the exact reason.
4. Confirm the intended diff has not changed since the successful final review cycle.
5. Stage all intended changes.
6. Write a short, clear commit message.
   - Prefer: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`
7. Commit and push.

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
