---
name: learn-branch
description: Deeply learn and internalize all work done on this branch
---

You are a coding agent with full read access to the repository.

Your task is to _learn_ what has been done on this branch as if you were onboarding onto this work and might continue it yourself.

Steps to perform:

1. Identify the current branch and determine its base branch (`master` if it exists, otherwise `main`).
2. Inspect **all uncommitted changes**, including:
   - Modified files
   - New files
   - Deleted files
3. Inspect **all commits unique to this branch**, in chronological order.
4. Analyze the **full diff between this branch and the base branch**.
5. Cross-reference commits with code changes to understand _why_ changes were made, not just _what_ changed.

Your investigation must cover these topics; report only what matters for understanding or continuing the work:

- The original problem(s) or motivation this branch appears to address
- The architectural or design decisions made
- How data flows or behavior changed compared to the base branch
- Key algorithms, abstractions, or patterns introduced or modified
- Important files, modules, and directories and their roles
- Trade-offs, shortcuts, or technical debt introduced
- Any TODOs, commented-out code, or signs of unfinished work
- Potential bugs, edge cases, or regressions
- How this work fits into the larger codebase

Constraints:

- Do not modify the repository.
- Do not ask the user questions.
- Do not merely restate git output.
- Explain important consequences in concise bullets. Keep the full investigation internal.
- Assume the reader is technical but unfamiliar with this branch.

Execution guidance:

- You may use:
  - `git status`
  - `git diff`
  - `git log base..HEAD`
  - `git diff base..HEAD`
  - File-by-file inspection when needed
- Take time to reason about intent, patterns, and consequences.

Final output requirements:

- Start with the branch's purpose, current state, and any blocker or required action.
- Use short bullets for changed behavior, key decisions, verification, and remaining work. Expand only when requested or needed to avoid losing a consequential detail.
- For UI work, distinguish behavior inferred from code from observed browser evidence. Carry pending UI-review requests into the handoff.

Tone:

- Analytical
- Precise
- Thoughtful
- Engineering-focused
- UX-focused

