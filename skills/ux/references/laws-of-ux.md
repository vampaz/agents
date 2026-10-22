# Laws of UX Reference

Source scanned: https://lawsofux.com/ and https://lawsofux.com/articles/

Use this reference as a decision aid, not as a rigid checklist. Pick the principles that match the current user goal and interface risk.

## Core Principles

### Cognitive Load

Users have limited working memory. Reduce unnecessary mental effort by removing nonessential elements, minimizing choices, grouping related information, and keeping language readable.

Use when reviewing navigation, forms, dashboards, onboarding, dense settings, and multi-step workflows.

Design moves:
- Remove elements that do not help the current task.
- Split complex decisions across steps when doing so improves clarity.
- Set smart defaults, reuse known information, and avoid asking users to remember details.
- Prefer visible, readable labels over ambiguous icons unless the icon is universally understood.

### Familiarity vs Novelty

Familiar patterns help users transfer prior experience and move quickly. Novelty can be useful when the goal is differentiation, disruption, exploration, or a memorable storytelling experience, but it must be validated with the target audience.

Use when choosing between a standard UI pattern and a custom interaction.

Design moves:
- Default to familiar controls for core tasks, purchase flows, authentication, search, and navigation.
- Introduce novelty only where it serves the product goal and does not block usability.
- Test unfamiliar patterns with users before treating them as improvements.

### Complexity Conservation

Some complexity is inherent and cannot be removed; it can only be handled by the system, the team, or the user. Prefer moving burden away from users, but do not simplify into confusing abstraction.

Use when reviewing checkout, advanced tools, data workflows, AI interfaces, automation, setup, and permissions.

Design moves:
- Pre-fill, infer, automate, or suggest values when confidence is high.
- Progressive-disclose advanced controls.
- Keep escape hatches, review states, and explanations where automation affects user trust.

### Active Users and Onboarding

People often start using software immediately instead of reading instructions. Onboarding should let users act quickly while making guidance available in context.

Use when designing first-run experiences, product tours, help, templates, and feature discovery.

Design moves:
- Avoid blocking users with long upfront tours.
- Provide contextual tips, empty-state guidance, checklists, templates, and safe practice environments.
- Reveal features gradually as users gain confidence.

### Peak-End Rule

Users remember emotionally intense moments and endings more strongly than the full average of an experience.

Use when reviewing waits, irreversible actions, errors, checkout, publishing, submission, cancellation, support, and completion states.

Design moves:
- Identify the strongest positive and negative moments in the journey.
- Make completion states clear, reassuring, and useful.
- Improve waits with progress, transparency, and next-step clarity.
- Treat errors and 404 states as recovery moments, not dead ends.

### Scannability and Structure

Interfaces become easier to use when information is chunked, grouped, and visually prioritized. Users scan for signals that match their goals.

Use when reviewing lists, search results, cards, tables, documentation, dashboards, and long-form content.

Design moves:
- Chunk related details into meaningful groups.
- Use hierarchy, proximity, common regions, and connectedness to show relationships.
- Keep repeated items consistent and easy to compare.
- Preserve the user's query, filters, or context when showing results.

### Performance and Responsiveness

Fast feedback helps users stay focused. The Doherty Threshold highlights that interaction feels productive when system and user are not waiting on each other.

Use when reviewing search, loading states, live previews, typeahead, AI responses, and critical interactions.

Design moves:
- Prioritize perceived speed for high-frequency actions.
- Show immediate feedback after input.
- Use skeletons, optimistic UI, streaming, or progress indicators where appropriate.
- Keep slow operations transparent and recoverable.

### Ethics

Psychology should make products more humane, not more manipulative. Consider user wellbeing alongside engagement or conversion metrics.

Use when a recommendation could influence attention, urgency, consent, defaults, notifications, pricing, retention, or habit formation.

Design moves:
- Make choices understandable and reversible.
- Avoid hiding costs, consequences, opt-outs, or destructive actions.
- Question whether success metrics align with user goals.
- Use qualitative evidence when usage data alone cannot explain impact.

## Laws Index

| Law | Apply it when | Practical move |
| --- | --- | --- |
| Aesthetic-Usability Effect | First impressions or credibility matter | Improve visual polish, consistency, and hierarchy without masking usability issues |
| Choice Overload | Users face too many options | Curate, group, recommend, or stage choices |
| Chunking | Content or data feels dense | Break information into meaningful groups |
| Cognitive Bias | Decisions may be distorted by shortcuts | Look for confirmation, complexity, recency, and memory biases |
| Cognitive Load | A task feels mentally heavy | Remove nonessential thought, memory, and decision work |
| Doherty Threshold | Waiting interrupts flow | Make feedback fast and visible |
| Fitts's Law | Targets are hard to click or tap | Increase target size and reduce travel distance for frequent actions |
| Flow | A creative or productivity task requires focus | Minimize interruptions and keep progress continuous |
| Goal-Gradient Effect | Users need motivation near completion | Show progress and make next steps obvious |
| Hick's Law | Decision time is high | Reduce and simplify choices at each moment |
| Jakob's Law | A familiar pattern exists | Match user expectations from products they already know |
| Law of Common Region | Related items need grouping | Place related elements inside a visible boundary or region |
| Law of Proximity | Relationships are unclear | Put related objects closer together and separate unrelated ones |
| Law of Pragnanz | Visuals are complex or ambiguous | Prefer the simplest clear form |
| Law of Similarity | Groups need recognition | Use consistent appearance for related items |
| Law of Uniform Connectedness | Relationship strength matters | Connect related elements visually when proximity is not enough |
| Mental Model | Users misunderstand how the product works | Align UI concepts with user expectations or explicitly teach the difference |
| Miller's Law | Users must remember multiple items | Chunk information rather than relying on raw memory limits |
| Occam's Razor | A solution is getting elaborate | Choose the simplest option that satisfies the user goal |
| Paradox of the Active User | Users skip instructions | Let them start, then teach in context |
| Pareto Principle | Many features compete for attention | Prioritize the few actions that create most value |
| Parkinson's Law | Work expands to fill available time | Use focused flows, constraints, and defaults |
| Peak-End Rule | Memory of the experience matters | Improve high-emotion moments and endings |
| Postel's Law | Users provide imperfect input | Accept flexible input and return clear, conservative output |
| Selective Attention | Users miss non-goal stimuli | Put critical information where attention already is |
| Serial Position Effect | Order affects recall | Put important items first or last |
| Tesler's Law | Complexity cannot be removed | Shift burden to the system without hiding necessary understanding |
| Von Restorff Effect | One item must be remembered | Make the important item distinct, sparingly |
| Working Memory | Users juggle temporary information | Keep needed context visible |
| Zeigarnik Effect | Incomplete tasks affect attention | Preserve progress and make unfinished work easy to resume |

## Article-Derived Heuristics

### Google Search Analysis

Google Search demonstrates a focused landing page, deferred filtering, visible query context, speed, and scannable results. Apply this pattern to search and retrieval interfaces: keep the initial input focused, preserve user context after submission, and make results easy to compare.

### Occam's Razor

Start with the simplest design that allows users to find and understand content. Add complexity only when it clearly improves the task. Use critique to remove decorative or interaction elements that cannot justify their presence.

### Reducing Cognitive Load

Cognitive load often comes from too many choices, too much thought, or lack of clarity. Reduce it through common patterns, fewer tasks, grouped choices, readable typography, and cautious icon use.

### Psychology of Design

Use Hick's Law, Miller's Law, and Jakob's Law as practical defaults: simplify decisions, chunk information, and respect existing mental models. Avoid using psychology to increase addiction, dark patterns, or misaligned engagement.

## Source Links

- Laws index: https://lawsofux.com/
- Articles index: https://lawsofux.com/articles/
- Familiar vs Novel: https://lawsofux.com/articles/2024/familiar-vs-novel/
- Onboarding for Active Users: https://lawsofux.com/articles/2024/onboarding-for-active-users/
- Tesler's Law article: https://lawsofux.com/articles/2024/teslers-law/
- UX Psychology: Google Search: https://lawsofux.com/articles/2020/ux-psychology-google-search/
- Peak-End Rule article: https://lawsofux.com/articles/2020/peak-end-rule/
- The Psychology of Design: https://lawsofux.com/articles/2018/the-psychology-of-design/
- Designing with Occam's Razor: https://lawsofux.com/articles/2017/designing-with-occams-razor/
- Design Principles for Reducing Cognitive Load: https://lawsofux.com/articles/2015/design-principles-for-reducing-cognitive-load/
