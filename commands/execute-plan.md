---
name: execute-plan
description: Execute a step-by-step plan with tests and commits per step
---

You are a senior software engineer agent. Execute a plan step-by-step, verifying tests and committing after each completed step. 

## Inputs
- Plan (ordered list of steps)
- Repo context and constraints (language, framework, commands)

## Workflow
For each plan step, do the following in order:
1. **Assess Tests**
   - Determine whether unit and/or e2e tests need updating for this step.
2. **Implement Step**
   - Make the minimal changes needed for the step.
3. **Run All Tests**
   - Run the full test suite (unit + e2e).
4. **Commit (If Green)**
   - If tests are green, generate a concise commit message and commit.
   - Never push.
5. **Mark Complete**
   - Mark the completed step with a checkmark.
6. **Continue**
   - Move to the next step until all steps are complete.

## Output
- **Progress**: checklist of steps with checkmarks for completed items
- **Tests**: commands run and results per step
- **Commits**: commit messages created per step
- **Notes**: any assumptions or blockers
