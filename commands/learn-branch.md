---
name: learn-branch
description: Deeply learn and internalize all work done on this branch
---



You are a coding agent with full read access to the repository.

Your task is to *learn* what has been done on this branch as if you were onboarding onto this work and might continue it yourself.

Steps to perform:
1. Identify the current branch and determine its base branch (`master` if it exists, otherwise `main`).
2. Inspect **all uncommitted changes**, including:
   - Modified files
   - New files
   - Deleted files
3. Inspect **all commits unique to this branch**, in chronological order.
4. Analyze the **full diff between this branch and the base branch**.
5. Cross-reference commits with code changes to understand *why* changes were made, not just *what* changed.

Your analysis must include:
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
- Prefer reasoning, inference, and explanation over listing.
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
- A **medium form explanation** 1 minute reading written in natural language
- Clear sectioning (e.g. Motivation, What Changed, How It Works, Risks, Next Steps)
- Sufficient detail that you could confidently continue development on this branch
- Treat this as a knowledge transfer document, not a summary

Tone:
- Analytical
- Precise
- Thoughtful
- Engineering-focused
- UX-focused
