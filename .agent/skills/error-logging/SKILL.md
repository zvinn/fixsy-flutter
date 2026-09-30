---
name: error-logging
description: Standardizes error handling and logging patterns across the codebase. Use this skill when implementing try-catch blocks, handling asynchronous failures, or setting up global error boundaries.
---

# Error Logging & Handling

This skill provides the standard patterns and rules for managing errors in the Fixsy project. Consistent error handling ensures better debuggability and a safer user experience.

> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md). Refer to Constitution §V (Unified Error Handling & Observability) for governing principles.

## When to use this skill
- When wrapping code in `try-catch` blocks.
- When handling `Future` errors in Dart/Flutter.
- When logging events to external services (Crashlytics).
- When a user reports a crash and you are implementing a fix.

## Workflow
- [ ] Identify the potential point of failure.
- [ ] Check if the error should be caught locally or bubbled up.
- [ ] Apply standard patterns from `resources/standard-patterns.md`.
- [ ] Consult `resources/logging-rules.md` to ensure safe logging.
- [ ] Verify that errors are logged correctly with the necessary context.

## Key Components (Already Built)

### 1. `AppErrorHandler` — `lib/core/error/app_error_handler.dart`
Global error handler that catches uncaught Flutter and Dart errors. Configured in `main.dart`.

### 2. `ErrorLogger` — `lib/core/error/error_logger.dart`
Centralized logging utility that dispatches to `firebase_crashlytics` in production and console in debug mode.

### 3. `AppLogger` — `lib/core/utils/app_logger.dart`
Developer-facing logger using the `logger` package for structured console output.

### 4. Exception Classes — `lib/core/error/exceptions.dart`
Typed exceptions: `ApiException`, `CacheException`, `AuthException`, etc.

### 5. Failure Classes — `lib/core/error/failures.dart`
Domain-level failure representations returned from repositories.

## Error Flow

```
Exception (Data Layer)
    ↓ catch in RepositoryImpl
Failure (Domain Layer)
    ↓ returned to Provider
User-Friendly Error Message (Presentation Layer)
    ↓ displayed via localized strings
ErrorLogger.log() ← called at every catch point
```

## Standard Patterns

### Data Layer (Repository)
```dart
@override
Future<Either<Failure, Booking>> getBooking(String id) async {
  try {
    final result = await remoteDataSource.getBooking(id);
    return Right(result.toEntity());
  } on ApiException catch (e, stackTrace) {
    ErrorLogger.log('Failed to get booking', error: e, stack: stackTrace);
    return Left(ServerFailure(e.message));
  } on CacheException catch (e, stackTrace) {
    ErrorLogger.log('Cache miss for booking', error: e, stack: stackTrace);
    return Left(CacheFailure(e.message));
  }
}
```

### Presentation Layer (Provider)
```dart
Future<void> loadBookings() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  final result = await repository.getBookings();
  result.fold(
    (failure) {
      _errorMessage = failure.message;
      ErrorLogger.log('Bookings load failed', error: failure);
    },
    (bookings) => _bookings = bookings,
  );

  _isLoading = false;
  notifyListeners();
}
```

### ⛔ Prohibited Patterns
```dart
// ❌ WRONG — Empty catch block (Constitution §V)
try { await riskyOperation(); } catch (_) {}

// ❌ WRONG — Catching without logging
try { await riskyOperation(); } catch (e) { print(e); }

// ❌ WRONG — Generic catch without type
try { await riskyOperation(); } catch (e) { /* no type, no stack */ }
```

### ✅ Required Pattern
```dart
// ✅ CORRECT — Typed catch with logging and stack trace
try {
  await riskyOperation();
} on SpecificException catch (e, stackTrace) {
  ErrorLogger.log('Operation context', error: e, stack: stackTrace);
  rethrow; // Or handle and return Failure
}
```

## Resources
- [Standard Patterns](resources/standard-patterns.md)
- [Logging Rules](resources/logging-rules.md)
