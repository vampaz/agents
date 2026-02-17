---
name: figma-dnl
description: Convert Figma designs to code following project conventions and design system
---

You are a coding agent working with Figma designs to implement UI components.

**IMPORTANT: This project uses a custom Tailwind prefix `dnl:`**
All Tailwind utility classes MUST use the `dnl:` prefix (e.g., `dnl:w-4`, `dnl:flex`, `dnl:bg-blue-500`).

### Pseudo-elements and States

When using pseudo-elements (hover, focus, active, disabled, etc.), the prefix order is:

- **Format**: `[pseudo]:dnl:[class]`
- **Examples**:
  - Hover: `hover:dnl:bg-blue-700` (NOT `dnl:hover:bg-blue-700`)
  - Disabled: `disabled:dnl:opacity-50` (NOT `dnl:disabled:opacity-50`)
  - Focus: `focus:dnl:ring-2` (NOT `dnl:focus:ring-2`)
  - Active: `active:dnl:scale-95` (NOT `dnl:active:scale-95`)

## Project Design System

### Colors

- **Primary color**: Blue
  - Use Tailwind blue variants: `dnl:bg-blue-500`, `dnl:text-blue-600`, etc.
  - When Figma shows a primary color, map it to the appropriate blue shade from Tailwind

### Spacing & Sizing

- **NEVER use pixel values** (e.g., `width: 16px`, `padding: 8px`)
- **ALWAYS use Tailwind's spacing scale** which is based on 4px increments:
  - `dnl:w-1` = 4px
  - `dnl:w-2` = 8px
  - `dnl:w-4` = 16px
  - `dnl:w-8` = 32px
  - `dnl:p-4` = 16px padding
  - And so on...
- Apply this to: width, height, padding, margin, gap, etc.

### Border Radius

- **ALWAYS use Tailwind rounded properties**
- Never use custom border-radius values
- Examples: `dnl:rounded`, `dnl:rounded-md`, `dnl:rounded-lg`, `dnl:rounded-full`

### Component Reuse

- **Prefer existing components over creating new ones**
- Look for and reuse:
  - Shared button components
  - Form input components
  - Card components
  - Layout components
  - Any other reusable UI elements
- **Only modify styles when necessary**
  - If an existing component is close to the design, prefer using it as-is
  - If changes are needed, use Tailwind classes to adjust styling
  - Avoid creating variants unless the design significantly differs

## Workflow

1. **Analyze the Figma design**
   - Identify colors, spacing, typography, and layout patterns
   - Map design colors to project colors (especially primary → blue)

2. **Search for existing components**
   - Check if similar UI elements already exist in the codebase
   - Reuse shared components wherever possible

3. **Implement with Tailwind classes**
   - Use `dnl:` prefix for all Tailwind utilities
   - Convert pixel values to Tailwind spacing scale (divide by 4)
   - Use Tailwind rounded properties for border radius
   - Map colors to Tailwind color palette

4. **Keep it minimal**
   - Only create new components when existing ones can't be adapted
   - Only change styles when the design specifically requires it
   - Avoid over-engineering or premature abstraction

## Examples

### Converting Figma measurements

- Figma: 16px width → Code: `dnl:w-4`
- Figma: 32px height → Code: `dnl:h-8`
- Figma: 12px padding → Code: `dnl:p-3`
- Figma: 8px gap → Code: `dnl:gap-2`

### Using primary color

- Figma: Primary color button background → Code: `dnl:bg-blue-500`
- Figma: Primary color text → Code: `dnl:text-blue-600`

### Border radius

- Figma: 4px border radius → Code: `dnl:rounded`
- Figma: 8px border radius → Code: `dnl:rounded-lg`
- Figma: Fully rounded → Code: `dnl:rounded-full`

## Constraints

- Never write pixel values in CSS or style props
- Never omit the `dnl:` prefix from Tailwind classes
- Always check for existing components before creating new ones
- Keep changes minimal and focused on the design requirements
