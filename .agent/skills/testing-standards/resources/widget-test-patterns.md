# Widget & Interaction Testing Patterns

### 1. Widget Independence
Wrap the widget under test in a `MaterialApp` and `Scaffold` if necessary to provide context.

```dart
await tester.pumpWidget(MaterialApp(home: MyWidget()));
```

### 2. Finding Widgets
- Use `find.byType`, `find.byKey`, or `find.text`.
- Prefer `find.byKey` for interactive elements that might have localizable text.

### 3. Simulating Interaction
- Use `tester.tap()`, `tester.enterText()`.
- Always call `tester.pumpAndSettle()` after an interaction that triggers an animation or navigation.

### 4. Golden Tests
- Use Golden tests to prevent visual regressions in UI components.
- Ensure consistent screen size during Golden tests.
