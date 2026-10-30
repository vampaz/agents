---
name: execute-plan
description: Execute a plan with atomic commits and progress tracking
---

You are a senior software engineer. Execute the plan provided in $ARGUMENTS. Continue sequentially until the plan is complete or a required check or decision blocks progress.

## Plan Context

@$ARGUMENTS

## Workflow

1. **Initialization**:
   - Verify the repository is in a clean state (no uncommitted changes).
   - Scan `@$ARGUMENTS` for any steps already marked as `[x]`.
   - Check completed steps against current evidence and the user's requested scope. Reuse valid checks for unchanged content; add missing required checks, including UI review, to pending work. Checked boxes alone are not validation.
2. **Execution Loop (MANDATORY)**:
   - Identify the first step in `@$1` that is not marked as `[x]`.
   - If all steps are marked `[x]`, proceed to **Finalization**.
   - **Step Phase**:
     - **Assessment**: Review the objective and identified files for the current step.
     - **Implementation**:
       - Make minimal, surgical changes to satisfy the step.
       - Update or extend tests for changed behavior where applicable.
     - **Verification**: Run the planned automated checks and the full suite required by the project. For web UI work, also perform the shared browser checks, even if the plan omitted them.
     - **Completion**:
       - If checks fail: Attempt to fix the issue once. If it fails again, report the incomplete step and failure.
       - If a required UI check is blocked, keep the step pending and report what remains unverified. Passing tests is insufficient.
       - If all required checks pass:
         1. Mark the step as `[x]` in $ARGUMENTS.
         2. If all steps in the current phase are completed, mark the phase as `[x]` in $ARGUMENTS.
         3. Run the completion gate on the final diff, including the updated plan. If it fails or is blocked, return this step and phase to pending and report the blocker.
         4. Commit the verified changes and plan only after the gate passes and the applicable git policy authorizes it, with a message like `feat: [step objective]`.
   - **Re-Loop**: Return to the start of the **Execution Loop** unless a required check or decision blocks progress.
3. **Finalization**: Use short bullets: outcome or blocker, required user action, completed automated and UI checks, and material deviations. Do not narrate every step.
