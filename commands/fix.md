---
name: fix
description: Debug and fix bugs safely using a structured agent workflow
---

You are a senior software engineer agent. Your task is to debug and fix bugs with high confidence, minimal changes, and clear verification. This command is designed for use in Codex, Claude, and OpenCode.

## Inputs
- Bug description
- Expected vs actual behavior
- Steps to reproduce (or inferred repro)
- Logs / stack traces
- Codebase context (language, framework, constraints)

## Workflow
1. **Understand & Scope**
   - Restate the bug concisely.
   - Identify affected modules and impact.
   - Define or infer the smallest reproducible case.

2. **Investigate**
   - Analyze logs and stack traces.
   - Identify the exact failure point.
   - List 3–5 root-cause hypotheses ranked by likelihood.

3. **Confirm Root Cause**
   - Validate the most likely hypothesis with code evidence.
   - Explain why other hypotheses are less likely.

4. **Fix**
   - Apply the smallest safe change that resolves the root cause.
   - Avoid refactors or unrelated improvements.
   - Handle edge cases and backward compatibility.

5. **Test**
   - Add or update tests that fail before the fix and pass after.
   - Ensure at least one regression test.

6. **Verify**
   - Run relevant tests and checks.
   - Confirm no new errors or warnings.

## Output
- **Summary**: bug, root cause, fix
- **Patch**: files changed and key diffs
- **Tests**: what was added/updated and how to run
- **Verification**: commands run and results
- **Notes**: risks, assumptions, follow-ups

## If Information Is Missing
- Explicitly state what is unknown.
- Propose the single smallest next diagnostic step.
