---
name: review-and-fix
description: Review and repair artifacts changed by the current implementation task until the final revision passes three distinct review passes with no actionable findings. Use after workspace-changing tasks and before reporting completion. Do not use as permission to commit, push, deploy, or modify unrelated work.
---

# Review and Fix

Exit successfully only when the final revision has no actionable findings after all three review passes and the applicable validation has completed successfully.

## Boundaries

- Read all applicable `AGENTS.md` instructions.
- Review only the current task's changes and their affected behavior.
- Preserve unrelated, pre-existing, and concurrent changes.
- Fix only findings covered by the user's existing implementation authorization.
- Never stage, commit, push, deploy, invoke external reviewers or subagents, or expand scope.
- If a finding requires product judgment or broader authorization, report it as a blocker rather than guessing.

## Actionable Findings

A finding qualifies only when it:

- is concrete and demonstrable;
- meaningfully affects correctness, security, performance, accessibility, maintainability, requirements, or runtime behavior;
- was introduced or exposed by the current task; and
- has a clear in-scope repair the user would probably want.

Do not manufacture findings, pursue subjective style preferences, or repair unrelated existing problems.

## Review Cycle

### Pass 1: Scope and Diff Integrity

Review the complete task diff.

Check requirements coverage, accidental files, unrelated edits, generated noise, secrets, unused code, unnecessary abstractions, instruction violations, and interference with other contributors' work.

Continue through the complete diff after finding the first issue.

### Pass 2: Correctness and Adversarial Behavior

Reread the changed implementation, tests, call sites, and affected flows.

Check assumptions, edge cases, failure paths, async behavior, stale state, concurrency, types, compatibility, accessibility, security, performance, and whether tests actually prove the requested behavior.

### Pass 3: Evidence and Runtime Behavior

Run the relevant targeted and broader validation required by the changed surface and project instructions. Wait for every command to finish.

For user-visible work, inspect the real rendered application and relevant states in the browser. Reinspect the final diff after formatting, tests, and generated-file changes.

## Fix and Restart

After any pass with findings:

1. Finish reviewing that entire pass.
2. Apply the smallest safe fixes for all in-scope findings.
3. Add or update regression coverage where behavior changed.
4. Run the affected validation.
5. Restart the review cycle from Pass 1.

The final revision must complete Passes 1, 2, and 3 consecutively without actionable findings. Repeating the same superficial review does not count as three passes.

## Final Result

Report:

- whether the final review cycle produced no findings;
- findings discovered and fixed;
- validation commands and completed results;
- runtime or visual checks performed; and
- unresolved blockers, unverified behavior, and residual risks.

Never claim success for a command that did not finish successfully.
