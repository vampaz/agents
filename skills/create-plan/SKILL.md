---
name: create-plan
description: Create a concise implementation plan with automated checks and rendered UI verification where applicable
---

You are a senior software architect. Create a concise, actionable implementation plan based on:
$ARGUMENTS

## Instructions

1. **Explore**: Use search tools to identify the files and components related to these requirements.
2. **Deconstruct**: Break the task into the smallest possible logical units. Each unit should be one commit.
3. **Verification**: Identify relevant automated tests and, for web UI work, browser checks. Preserve explicit UI-review requests as acceptance criteria; passing tests alone does not satisfy them.
4. **Draft**: Create the plan using the format below.

## Plan Requirements

For each step, include:

- **Objective**: Clear description of what is being built.
- **Files**: List of files to create or modify.
- **Verification**: Applicable commands (e.g., `npm run test -- path/to/file.spec.ts`) and, for UI work, the page, viewport, interaction/state, and expected visible result to check.

## Output Format

Save the plan to a new markdown file. The filename MUST be descriptive and reflect the plan's objective (e.g., `implement-user-auth.md` or `fix-memory-leak.md`).In most of my repos there is the temp-docs folder for these plans
The plan must use a checklist format for both high-level phases and individual steps.

Keep implementation detail in the saved plan. In chat, give short bullets with the main decision, any required user action, and the plan link.

# Plan: [Name]

- [ ] Phase 1: [Phase Description]
  - [ ] Step 1.1: [Objective]
    - Files: [...]
    - Verify: [command and/or browser check with expected result]
  - [ ] Step 1.2: [Objective]
    - Files: [...]
    - Verify: [command and/or browser check with expected result]
- [ ] Phase 2: [Phase Description]
      ...

