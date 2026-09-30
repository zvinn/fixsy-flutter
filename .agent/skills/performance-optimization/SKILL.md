---
name: performance-optimization
description: Guidelines for maintaining high performance and smooth UI in Flutter. Use this skill when building complex widget trees, handling large datasets, or optimizing startup time.
---

# Performance Optimization Standards

Ensuring a smooth 60fps experience is critical for mobile applications.

> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md) §VI (State Management — selective rebuilding).

## When to use this skill
- When building complex or deeply nested UI.
- When handling lists with many items.
- When optimizing app startup time.
- When dealing with large image assets or heavy animations.
- When profiling and fixing jank or slow frames.

## Widget Performance

### 1. Use `const` constructors aggressively:
```dart
// ✅ CORRECT — Skips rebuild entirely
const SizedBox(height: 16)
const Divider()
const Icon(Icons.check)

// ❌ WRONG — Rebuilds every time parent rebuilds
SizedBox(height: 16)
```

### 2. Extract widgets instead of methods:
```dart
// ✅ CORRECT — Separate widget class gets its own Element
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) => Card(...);
}

// ❌ WRONG — Helper method rebuilds with parent
Widget _buildBookingCard(Booking booking) => Card(...);
```

### 3. Use `RepaintBoundary` for isolated animations:
```dart
RepaintBoundary(
  child: AnimatedWidget(...),  // Won't cause parent to repaint
)
```

### 4. Use `AutomaticKeepAliveClientMixin` for TabBarView pages:
```dart
class BookingsTab extends StatefulWidget { ... }
class _BookingsTabState extends State<BookingsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required
    return ...;
  }
}
```

## List Performance

### Always use `ListView.builder`:
```dart
// ✅ CORRECT — Lazy loading, only builds visible items
ListView.builder(
  itemCount: bookings.length,
  itemExtent: 88, // Fixed height = faster layout
  itemBuilder: (context, index) => BookingCard(booking: bookings[index]),
)

// ❌ WRONG — Builds ALL children upfront
ListView(
  children: bookings.map((b) => BookingCard(booking: b)).toList(),
)
```

### Use `itemExtent` when item height is fixed:
```dart
ListView.builder(
  itemExtent: 72.0, // Skip measuring each item → much faster
  itemBuilder: ...,
)
```

### Pagination for large datasets:
```dart
// Use scroll controller to detect end-of-list
_scrollController.addListener(() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    context.read<BookingsProvider>().loadNextPage();
  }
});
```

## Image Performance

### Use `CachedNetworkImage` (already in pubspec):
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (_, __) => Shimmer.fromColors(...),
  errorWidget: (_, __, ___) => Icon(Icons.broken_image),
  memCacheHeight: 200, // Resize in memory
  memCacheWidth: 200,
)
```

### Precache critical images:
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(AssetImage('assets/images/logo.png'), context);
}
```

### Asset image resolutions:
```
assets/images/
├── logo.png        (1x - baseline)
├── 2.0x/logo.png   (2x)
└── 3.0x/logo.png   (3x)
```

## Provider Performance (Constitution §VI)

### Use `context.select` for targeted reads:
```dart
// ✅ CORRECT — Only rebuilds when isLoading changes
final isLoading = context.select<BookingsProvider, bool>((p) => p.isLoading);

// ❌ WRONG — Rebuilds on ANY state change
final provider = context.watch<BookingsProvider>();
final isLoading = provider.isLoading;
```

### Use `Consumer` with `child` parameter:
```dart
Consumer<BookingsProvider>(
  // child is NOT rebuilt when Provider changes
  child: const ExpensiveStaticWidget(),
  builder: (context, provider, child) {
    return Column(
      children: [
        Text('Count: ${provider.bookings.length}'),
        child!, // Reused, not rebuilt
      ],
    );
  },
)
```

### Batch `notifyListeners()`:
```dart
// ✅ CORRECT — Single notification
_items = newItems;
_isLoading = false;
_error = null;
notifyListeners(); // ONE call

// ❌ WRONG — Three separate rebuilds
_items = newItems;
notifyListeners();
_isLoading = false;
notifyListeners();
_error = null;
notifyListeners();
```

## Startup Performance

### Lazy initialization:
```dart
// ✅ CORRECT — Initialize only when needed
late final HeavyService _service = HeavyService();

// ❌ WRONG — Initialize in constructor even if never used
final HeavyService _service = HeavyService();
```

### Defer non-critical work:
```dart
void main() async {
  // Critical: Firebase, error handling
  await Firebase.initializeApp();
  AppErrorHandler.init();

  // Run app immediately
  runApp(const FixsyApp());

  // Defer: Analytics, FCM token, cache warmup
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AnalyticsService.init();
    NotificationService.requestPermission();
  });
}
```

## Memory Management

### Always dispose resources:
```dart
@override
void dispose() {
  _scrollController.dispose();
  _animationController.dispose();
  _textController.dispose();
  _streamSubscription?.cancel();
  _timer?.cancel();
  super.dispose();
}
```

### Dispose checklist:
- [ ] `ScrollController`
- [ ] `AnimationController`
- [ ] `TextEditingController`
- [ ] `FocusNode`
- [ ] `StreamSubscription`
- [ ] `Timer`
- [ ] Firestore listeners (`StreamSubscription` from `.listen()`)

## Profiling Tools

```bash
# Launch DevTools performance overlay
flutter run --profile

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Key metrics:
- **Frame time**: Must stay under 16ms (60fps)
- **Widget rebuilds**: Use DevTools "Rebuild Stats"
- **Memory**: Watch for leaks in "Memory" tab
