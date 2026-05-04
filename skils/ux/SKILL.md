---
name: ux
description: Apply UX psychology and Laws of UX heuristics to product design, interface implementation, frontend reviews, user flows, onboarding, forms, navigation, empty/error states, and conversion or retention work. Use when an agent needs to critique or improve usability, reduce cognitive load, choose familiar versus novel patterns, manage complexity, or make UI recommendations grounded in human behavior.
---

# UX

## Overview

Use this skill to turn UX psychology into practical product decisions across Codex, OpenCode, Claude, Pi, and other Markdown-based skill harnesses. Favor small, testable interface improvements that reduce user effort, preserve clarity, and respect user goals.

The detailed Laws of UX reference is in `references/laws-of-ux.md`. Load it when evaluating a real interface, writing UX recommendations, or making UI implementation choices.

## Workflow

1. Identify the user goal, product surface, target audience, and task stage.
2. Inspect the existing product or code patterns before recommending changes.
3. Map the experience moments that create effort: first use, navigation, choices, input, waiting, errors, completion, and return visits.
4. Apply the smallest relevant set of laws from `references/laws-of-ux.md`.
5. Recommend or implement changes that make the desired path easier without hiding necessary complexity.
6. Validate with the closest available evidence: tests, screenshots, interaction checks, analytics context, user research, or explicit assumptions.

## Review Checklist

- Reduce cognitive load: remove unnecessary elements, split complex flows, group related information, and keep the next action obvious.
- Preserve familiarity: use established patterns unless novelty directly supports differentiation, exploration, or memorability.
- Manage inherent complexity: move burden to the system where possible, but avoid abstracting so much that users lose control or understanding.
- Design for active users: let people start quickly, then provide contextual guidance, progressive disclosure, and recoverable learning.
- Make key moments count: improve emotional peaks, endings, waits, error states, and confirmation moments.
- Optimize scannability: use hierarchy, spacing, grouping, labels, and readable typography so users can decide quickly.
- Respect ethics: use psychology to support user goals and wellbeing, not to trap attention, obscure choices, or manipulate behavior.

## Output Guidance

When reviewing UX, lead with the highest-impact issues first. For each issue, state:

- The user risk or friction.
- The relevant UX principle.
- The smallest concrete change.
- How to verify the improvement.

When implementing UI, keep edits scoped and align with the existing design system. Prefer familiar controls, visible labels where ambiguity is likely, responsive layouts, and accessible interaction states.
