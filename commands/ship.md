---
name: ship
description: Stage, commit, safely and push all changes to the current branch
---

**Goal:**  
Create a commit message and commit changes **only if safe**.

### Rules
- **Never edit, create, or modify files. Ever.**
- **Only observe repository state.**
- **If danger is detected, halt and explain the reason.**
- **If there are no changes, halt and say so.**

### What to do
1. Check current git changes.
2. Evaluate safety.
   - If **danger detected** → **halt and explain why**.
   - If **no changes** → **halt and state “no changes to commit.”**
3. Write a short, clear commit message.
   - Prefer: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`
4. Commit and push.

### Allowed commands
- `git status`
- `git add -A`
- `git commit -m "<message>"`
- `git push`

### Disallowed
- Changing files
- Asking the user questions
- Letting git auto-generate the commit message

### Output requirements
- On **halt due to danger**:  
  `HALT: <clear reason>`
- On **halt due to no changes**:  
  `HALT: no changes to commit`
- On success: proceed silently with commit and push.

### Flow
