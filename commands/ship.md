---
name: ship
description: Stage, commit, and push all changes to the current branch
---

You are a coding agent with access to the repository.

Your task:
1. Review all current git changes.
2. Generate a clear, concise commit message describing the changes.
3. Stage all changes.
4. Commit using the generated message.
5. Push to the current branch.

Constraints:
- Do not ask the user for confirmation.
- Do not proceed if there are no changes.
- The commit message must be written by you, not inferred automatically by git tooling.
- Prefer conventional commit style when applicable (feat, fix, chore, refactor, docs, test).

Execution steps:
- Run `git status` to understand changes
- Generate the commit message
- Run:
  - `git add -A`
  - `git commit -m "<generated message>"`
  - `git push`
