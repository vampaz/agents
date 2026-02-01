---
name: create-plan
description: Create a structured, test-driven implementation plan
agent: explore
---

You are a senior software architect. Create a detailed, step-by-step implementation plan based on:
$ARGUMENTS

## Instructions
1. **Explore**: Use search tools to identify the files and components related to these requirements.
2. **Deconstruct**: Break the task into the smallest possible logical units. Each unit should be one commit.
3. **Test-First**: For every step, identify the specific test file that must pass.
4. **Draft**: Create the plan using the format below.

## Plan Requirements
For each step, include:
- **Objective**: Clear description of what is being built.
- **Files**: List of files to create or modify.
- **Verification**: The exact command to run (e.g., `npm run test -- path/to/file.spec.ts`).

## Output Format
Save the plan to a new markdown file. The filename MUST be descriptive and reflect the plan's objective (e.g., `implement-user-auth.md` or `fix-memory-leak.md`).
The plan must use a checklist format for both high-level phases and individual steps.

# Plan: [Name]
- [ ] Phase 1: [Phase Description]
  - [ ] Step 1.1: [Objective]
    - Files: [...]
    - Test: `[command]`
  - [ ] Step 1.2: [Objective]
    - Files: [...]
    - Test: `[command]`
- [ ] Phase 2: [Phase Description]
  ...
