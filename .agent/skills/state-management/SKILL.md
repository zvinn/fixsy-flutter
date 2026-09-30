---
name: state-management
description: Defines Provider-based state management patterns, async state handling, and Provider communication rules. Use this skill when creating new Providers, managing async operations, or debugging state issues.
---

# State Management Standards

This skill defines how state is managed across the Fixsy project using the `Provider` package.

> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md) §VI (State Management).

## When to use this skill
- When creating a new `ChangeNotifierProvider`.
- When managing async operations (Loading/Success/Error).
- When one Provider needs data from another.
- When debugging excessive rebuilds or stale state.
- When deciding whether to split a large Provider.

## Provider Registry (Current)

The app has **16 Providers** registered in `MultiProvider` at `lib/main.dart`:

| Provider | Responsibility | Layer |
|----------|---------------|-------|
| `AuthProvider` | Auth state, sign-in/out, user session | Global |
| `LanguageProvider` | Locale switching (ar/en) | Global |
| `ConnectivityProvider` | Network status monitoring | Global |
| `ServicesProvider` | Service catalog browsing | Feature |
| `BookingsProvider` | Booking CRUD + filtering | Feature |
| `ServiceRequestProvider` | New service request flow | Feature |
| `RatingProvider` | Technician rating/review | Feature |
| `NotificationProvider` | Push notification state | Feature |
| `ChatProvider` | In-app messaging | Feature |
| `LoyaltyProvider` | Gamification/points | Feature |
| `WalletProvider` | Wallet balance & transactions | Feature |
| `CommunityProvider` | Community hub content | Feature |
| `TechDashboardProvider` | Technician dashboard | Feature |
| `JobMarketProvider` | Job listings for technicians | Feature |
| `AddressProvider` | User address management | Feature |
| `AdminProvider` | Admin panel operations | Feature |

## Standard Provider Template

Every new Provider MUST follow this structure:

```dart
import 'package:flutter/material.dart';
import '../../core/error/error_logger.dart';

class FeatureProvider extends ChangeNotifier {
  // ── Dependencies (injected or instantiated) ──
  final FeatureRepository _repository;

  FeatureProvider({required FeatureRepository repository})
      : _repository = repository;

  // ── State Fields ──
  List<FeatureItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters (public API) ──
  List<FeatureItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // ── Actions ──
  Future<void> loadItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getAll();
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      ErrorLogger.log('Failed to load items', error: e, stack: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Cleanup ──
  @override
  void dispose() {
    // Cancel streams, timers, etc.
    super.dispose();
  }
}
```

## Async State Pattern (Loading → Success → Error)

**Every** async operation MUST follow this pattern:

```dart
Future<void> doSomething() async {
  // 1. Set loading + clear previous error
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    // 2. Execute operation
    final result = await _repository.doSomething();
    _data = result;                    // 3. Success
  } catch (e, stackTrace) {
    _errorMessage = e.toString();       // 4. Error
    ErrorLogger.log('context', error: e, stack: stackTrace);
  } finally {
    _isLoading = false;                 // 5. Always stop loading
    notifyListeners();                  // 6. Single notify at end
  }
}
```

### ⛔ Anti-Patterns

```dart
// ❌ WRONG — Multiple notifyListeners in try/catch
try {
  _data = await repo.get();
  _isLoading = false;
  notifyListeners();     // notify here
} catch (e) {
  _error = e.toString();
  _isLoading = false;
  notifyListeners();     // AND here — use finally instead
}

// ❌ WRONG — No error handling
Future<void> load() async {
  _items = await _repository.getAll();  // Unhandled exception!
  notifyListeners();
}

// ❌ WRONG — Calling notifyListeners in build
Widget build(BuildContext context) {
  provider.loadItems(); // Triggers rebuild loop!
}
```

## Reading State in UI

### ✅ Use `Consumer` for targeted rebuilds:
```dart
Consumer<BookingsProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return const ShimmerList();
    if (provider.hasError) return ErrorWidget(provider.errorMessage!);
    return BookingsList(bookings: provider.bookings);
  },
)
```

### ✅ Use `context.select` for single-field reads:
```dart
// Only rebuilds when isLoading changes
final isLoading = context.select<AuthProvider, bool>((p) => p.isLoading);
```

### ✅ Use `context.read` for one-shot actions (never in build):
```dart
ElevatedButton(
  onPressed: () => context.read<AuthProvider>().signOut(),
  child: Text('Logout'),
)
```

### ⛔ Avoid `context.watch` in large trees:
```dart
// ❌ Rebuilds entire widget on ANY change
final provider = context.watch<BookingsProvider>();
```

## Provider Communication

When Provider A needs data from Provider B:

### Option 1: Pass data via method argument (Preferred)
```dart
// In UI:
final userId = context.read<AuthProvider>().currentUser?.id;
if (userId != null) {
  context.read<BookingsProvider>().loadUserBookings(userId);
}
```

### Option 2: ProxyProvider (for dependency injection)
```dart
ChangeNotifierProxyProvider<AuthProvider, BookingsProvider>(
  create: (_) => BookingsProvider(),
  update: (_, auth, bookings) => bookings!..updateAuth(auth),
)
```

## When to Split a Provider

Split when **3 or more** of these are true:
- [ ] The Provider has > 200 lines of code
- [ ] It manages > 2 unrelated state domains
- [ ] Different screens use completely different subsets of its state
- [ ] Adding a feature requires modifying unrelated methods
- [ ] Tests are hard to write because of tangled state
