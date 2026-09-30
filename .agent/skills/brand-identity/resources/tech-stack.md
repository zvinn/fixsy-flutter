# Preferred Tech Stack & Implementation Rules

When generating code or UI components for this brand, you **MUST** strictly adhere to the following technology choices.

## Core Stack
* **Framework:** Flutter (Material Design)
* **Styling Engine:** Theme-based CSS-like styles adapted to Flutter widgets.
* **Component Library:** Custom components based on `ThemeData`.
* **Icons:** Material Icons / FontAwesome

## Implementation Guidelines
### 1. Theme Usage
* Use `Theme.of(context).colorScheme` directly in Widgets.
* Utilize the color tokens defined in `design-tokens.json`.
* **Dark Mode:** Support dark mode using `darkTheme` property in `MaterialApp`.

### 2. Component Patterns
* **Buttons:** Primary actions must use the solid Primary color.
* **Forms:** Labels must always be placed *above* input fields.
* **Layout:** Use `Column`, `Row`, `Flex`, and `Grid` for all layout structures.

### 3. Forbidden Patterns
* Do NOT use hardcoded hex values in UI widgets.
* Do NOT create inline styles that bypass the theme system.
