---
name: testing-standards
description: Enforces quality assurance standards for Flutter apps. Use this skill when writing unit tests, widget tests, or integration tests to ensure code reliability and prevent regressions.
---

# Testing & QA Standards

This skill defines how to verify code correctness in the Fixsy project.

> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md) §X (Testing & Quality Assurance).

## When to use this skill
- When creating a new repository, service, or feature.
- When writing a test file in the `test/` directory.
- When refactoring code to ensure existing functionality is preserved.
- When a bug is fixed — a regression test must be added.

## Workflow
- [ ] Determine the type of test needed (Unit, Widget, or Integration).
- [ ] Isolate the component under test using mocks.
- [ ] Follow the "Given-When-Then" structure for test readability.
- [ ] Verify that the test covers both success and failure paths.
- [ ] Run the tests locally using `flutter test`.

## Test Coverage Matrix

| Layer | Component | Must Test? | Tool |
|-------|-----------|-----------|------|
| Data | Repository | ✅ YES | `mockito` + `fake_cloud_firestore` |
| Data | RemoteDataSource | ✅ YES | `fake_cloud_firestore`, `firebase_auth_mocks` |
| Data | Model (fromJson/toJson) | ✅ YES | Standard `test` |
| Presentation | Provider | ✅ YES | `mockito` (mock repository) |
| Presentation | Screen | 🟡 Optional | `flutter_test` widget tests |
| Presentation | Widget (reusable) | 🟡 Optional | `flutter_test` |
| Domain | Entity | ⚪ Rarely | Only if it has logic |
| Domain | UseCase | ✅ YES (when exists) | `mockito` |

## Test File Organization

Tests MUST mirror the `lib/` folder structure:
```
test/
├── data/
│   ├── models/
│   │   └── booking_model_test.dart
│   ├── repositories/
│   │   └── booking_repository_test.dart
│   └── datasources/
│       └── booking_remote_datasource_test.dart
├── presentation/
│   └── providers/
│       └── bookings_provider_test.dart
└── core/
    └── network/
        └── api_client_test.dart
```

## Test Naming Convention

```dart
test('should [expected behavior] when [condition]', () { ... });
```

Examples:
- `'should return list of bookings when user has active bookings'`
- `'should throw ServerFailure when API returns 500'`
- `'should set isLoading to false when operation completes'`

## Standard Test Structure (Given-When-Then)

```dart
void main() {
  group('BookingsProvider', () {
    late BookingsProvider provider;
    late MockBookingRepository mockRepository;

    setUp(() {
      mockRepository = MockBookingRepository();
      provider = BookingsProvider(repository: mockRepository);
    });

    test('should return bookings when loadUserBookings succeeds', () async {
      // Given (Arrange)
      final testBookings = [Booking(id: '1', status: 'pending')];
      when(mockRepository.getUserBookings('user123'))
          .thenAnswer((_) async => testBookings);

      // When (Act)
      await provider.loadUserBookings('user123');

      // Then (Assert)
      expect(provider.bookings, testBookings);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('should set error when loadUserBookings fails', () async {
      // Given
      when(mockRepository.getUserBookings('user123'))
          .thenThrow(ServerException('Server error'));

      // When
      await provider.loadUserBookings('user123');

      // Then
      expect(provider.hasError, true);
      expect(provider.isLoading, false);
    });
  });
}
```

## Mockito Setup

### 1. Create mock file with `@GenerateMocks`:
```dart
// test/mocks.dart
import 'package:mockito/annotations.dart';
import 'package:fixsy_flutter/data/repositories/booking_repository.dart';

@GenerateMocks([BookingRepository])
void main() {}
```

### 2. Generate mocks:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Use generated mocks:
```dart
import 'mocks.mocks.dart';

late MockBookingRepository mockRepo;

setUp(() {
  mockRepo = MockBookingRepository();
});
```

## Firebase Testing

### Firestore (using `fake_cloud_firestore`):
```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  test('should query bookings by userId', () async {
    // Seed
    await fakeFirestore.collection('bookings').add({
      'userId': 'user123',
      'status': 'pending',
    });

    // Query
    final snapshot = await fakeFirestore
        .collection('bookings')
        .where('userId', isEqualTo: 'user123')
        .get();

    expect(snapshot.docs.length, 1);
  });
}
```

### Auth (using `firebase_auth_mocks`):
```dart
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  test('should sign in user', () async {
    final mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@fixsy.com',
    );
    final auth = MockFirebaseAuth(mockUser: mockUser);

    final result = await auth.signInWithEmailAndPassword(
      email: 'test@fixsy.com',
      password: 'password123',
    );

    expect(result.user?.uid, 'user123');
  });
}
```

## Provider Testing Pattern

```dart
void main() {
  group('AuthProvider', () {
    late AuthProvider provider;
    late MockAuthRepository mockAuthRepo;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      provider = AuthProvider(repository: mockAuthRepo);
    });

    test('should notify listeners on state change', () async {
      bool notified = false;
      provider.addListener(() => notified = true);

      when(mockAuthRepo.signIn(any, any))
          .thenAnswer((_) async => User(id: '123'));

      await provider.signIn('email', 'pass');

      expect(notified, true);
      expect(provider.isAuthenticated, true);
    });
  });
}
```

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/data/repositories/booking_repository_test.dart

# Run with coverage
flutter test --coverage

# Run with verbose output
flutter test --reporter expanded
```

## Resources
- [Mocking Rules](resources/mocking-rules.md)
- [Widget Test Patterns](resources/widget-test-patterns.md)
