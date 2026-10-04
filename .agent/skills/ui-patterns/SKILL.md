---
name: ui-patterns
description: Defines UI design patterns for responsive layouts, RTL support, theming, forms, and loading states. Use this skill when building screens, creating reusable widgets, or implementing animations.
---

# UI Design Patterns

This skill defines the visual and interaction standards for the Fixsy Flutter app.

> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md) §IX (Localization) and the [Brand Identity](file:///.agent/skills/brand-identity/SKILL.md) skill for colors/fonts.

## When to use this skill
- When creating a new screen or page.
- When building reusable widgets or components.
- When implementing responsive layouts.
- When adding animations or transitions.
- When handling form validation and input.

## Premium UI & Aesthetics (CRITICAL)

To ensure Fixsy feels like a high-end, premium application, strictly adhere to these aesthetic rules:

### 1. Glassmorphism & Blurs
- Use `BackdropFilter` with `ImageFilter.blur(sigmaX: 10, sigmaY: 10)` for floating elements, bottom nav bars, and dialogs.
- Combine with a semi-transparent background color (e.g., `Colors.white.withOpacity(0.1)` or `0.8` depending on dark/light mode) and a subtle border.

### 2. Smooth Gradients
- Avoid flat, harsh colors for primary backgrounds or large prominent buttons.
- Use `LinearGradient` or `RadialGradient`.
- Example: `LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)], begin: Alignment.topLeft, end: Alignment.bottomRight)`

### 3. Soft Shadows (Neumorphic touch)
- Buttons and cards should have soft, dispersed shadows instead of harsh drop shadows.
- Example: `BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: Offset(0, 10))`

### 4. Spacing & Border Radius
- Use generous padding (`24.0` or `32.0` around main content blocks).
- Use smooth, rounded corners for cards and buttons (e.g., `BorderRadius.circular(16)` or `BorderRadius.circular(24)`).

### 5. Typography & Icons
- Always use modern fonts from `google_fonts` (e.g., `GoogleFonts.inter()` or `GoogleFonts.outfit()`).
- Use modern, lightweight icons from `lucide_icons`.

## RTL Support (Mandatory — Constitution §IX)

### ✅ Use directional-aware properties:
```dart
// ✅ CORRECT — Works in both LTR and RTL
Padding(
  padding: EdgeInsetsDirectional.only(start: 16, end: 8),
  child: ...
)

Container(
  alignment: AlignmentDirectional.centerStart,
  child: ...
)

Positioned.directional(
  textDirection: Directionality.of(context),
  start: 16,
  child: ...
)
```

### ⛔ Never use hardcoded left/right:
```dart
// ❌ WRONG — Breaks in Arabic (RTL)
Padding(padding: EdgeInsets.only(left: 16, right: 8))
Container(alignment: Alignment.centerLeft)
Positioned(left: 16)
```

### Icon direction awareness:
```dart
// Flip icons that imply direction (arrows, back buttons)
Transform.flip(
  flipX: Directionality.of(context) == TextDirection.rtl,
  child: Icon(Icons.arrow_forward),
)
```

## Loading / Error / Empty States

Every screen MUST handle these 3 states:

### Standard State Widget:
```dart
Widget buildStateContent<T>({
  required bool isLoading,
  required String? error,
  required T? data,
  required Widget Function(T data) onSuccess,
  Widget? loadingWidget,
  Widget? emptyWidget,
}) {
  if (isLoading) {
    return loadingWidget ?? const ShimmerList();
  }
  if (error != null) {
    return ErrorStateWidget(
      message: error,
      onRetry: () => /* retry action */,
    );
  }
  if (data == null || (data is List && data.isEmpty)) {
    return emptyWidget ?? const EmptyStateWidget();
  }
  return onSuccess(data);
}
```

### Shimmer Loading (using `shimmer` package):
```dart
Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Container(
    height: 80,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

## Responsive Design

### Use `MediaQuery` breakpoints:
```dart
class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;
}
```

### Use `LayoutBuilder` for adaptive layouts:
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return _buildWideLayout();
    }
    return _buildNarrowLayout();
  },
)
```

## Theme Usage

### Always use theme values (never hardcode colors/fonts):
```dart
// ✅ CORRECT
Text(
  'Title',
  style: Theme.of(context).textTheme.headlineMedium,
)
Container(color: Theme.of(context).colorScheme.primary)

// ❌ WRONG
Text('Title', style: TextStyle(fontSize: 24, color: Colors.blue))
Container(color: Color(0xFF1A73E8))
```

### Refer to `brand-identity` skill for design tokens:
- Colors → `resources/design-tokens.json`
- Fonts → `google_fonts` package
- Spacing → Consistent 4/8/12/16/24/32 px scale

## Form Patterns

### Validation:
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: AppLocalizations.of(context).translate('email'),
    errorText: _emailError,
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).translate('field_required');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppLocalizations.of(context).translate('invalid_email');
    }
    return null;
  },
)
```

### Form submission:
```dart
if (_formKey.currentState!.validate()) {
  _formKey.currentState!.save();
  await context.read<AuthProvider>().signIn(_email, _password);
}
```

## Animation Standards

### Use `flutter_animate` for declarative animations:
```dart
import 'package:flutter_animate/flutter_animate.dart';

// Fade + slide on appear
widget
  .animate()
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.1, end: 0);

// Staggered list animation
ListView.builder(
  itemBuilder: (context, index) => ListTile(...)
      .animate()
      .fadeIn(delay: (index * 100).ms)
      .slideX(begin: 0.1),
)
```

### Use `Shimmer` for loading placeholders:
```dart
// Already covered in Loading States section above
```

### Performance rules:
- Use `AnimatedBuilder` / `AnimatedWidget` instead of rebuilding entire widget tree
- Wrap heavy animations in `RepaintBoundary`
- Avoid animating in `build()` — use controllers initialized in `initState()`

## Navigation in Screens

### Always use `AppRoutes` constants:
```dart
// ✅ CORRECT
Navigator.pushNamed(context, AppRoutes.bookingDetails, arguments: bookingId);

// ❌ WRONG
Navigator.pushNamed(context, '/booking-details');
```

## Accessibility

- All `Image` widgets must have `semanticLabel`
- All buttons must have `tooltip` or meaningful `semanticsLabel`
- Minimum tap target: 48x48 dp
- Sufficient color contrast for text on backgrounds
