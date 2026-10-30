---
name: review-and-fix
description: Review and repair artifacts changed by the current implementation task until the final revision passes three distinct review passes with no actionable findings. Include rendered UI and interaction checks for web UI changes. Use after workspace-changing tasks and before reporting completion. Do not use as permission to commit, push, deploy, or modify unrelated work.
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

Review the complete task diff and recover the user's requested checks from the task context. Keep explicit UI-review requests in the acceptance criteria.

Check requirements coverage, accidental files, unrelated edits, generated noise, secrets, unused code, unnecessary abstractions, instruction violations, and interference with other contributors' work.

Continue through the complete diff after finding the first issue.

### Pass 2: Correctness and Adversarial Behavior

Reread the changed implementation, tests, call sites, and affected flows.

Check assumptions, edge cases, failure paths, async behavior, stale state, concurrency, types, compatibility, accessibility, security, performance, and whether tests actually prove the requested behavior.

For web UI, also trace the changed user flow and its expected visible states.

### Pass 3: Evidence and Runtime Behavior

Run the relevant targeted and broader validation required by the changed surface and project instructions. Wait for every command to finish.

For web UI changes or an explicit UI-review request, apply the shared `AGENTS.md` UI checks unless the user explicitly limits the scope:

- Open the affected pages for the revision under review in a browser. Visually inspect screenshots or rendered output and exercise the affected interactions. Code, DOM snapshots, and automated tests alone are insufficient.
- Check relevant desktop and narrow/mobile widths, affected layout and scrolling, keyboard/focus behavior, and applicable loading, empty, error, and success states.
- Record the URL, viewports, states/actions checked, observed result, and remaining gaps. Capture screenshots when useful to substantiate findings.
- If browser or app access is blocked, complete independent validation and report the blocker. The completion gate remains incomplete until the required UI review is performed.

Reinspect the final diff after formatting, tests, and generated-file changes.

## Fix and Restart

After any pass with findings:

1. Finish reviewing that entire pass.
2. Apply the smallest safe fixes for all in-scope findings.
3. Add or update regression coverage where behavior changed.
4. Run the affected validation.
5. Restart the review cycle from Pass 1.

The final revision must complete Passes 1, 2, and 3 consecutively without actionable findings. Repeating the same superficial review does not count as three passes.

## Final Result

Report in a few short bullets, ordered by importance:

- whether the final review cycle passed, with any blocker or required user action first;
- material findings fixed;
- validation commands and completed results, including rendered UI evidence when applicable; and
- remaining unverified behavior or risks.

Omit empty categories and routine process narration. Never claim success for a command that did not finish successfully.
