---
name: firebase-patterns
description: Defines Firebase integration patterns for Firestore, Auth, Storage, Messaging, and Crashlytics. Use this skill when implementing Firebase operations, writing queries, or configuring push notifications.
---

# Firebase Integration Patterns

This skill defines how Firebase services are used in the Fixsy project. All Firebase SDK calls are confined to the Data layer per Constitution §VII.

> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md) §I (Clean Architecture) and §VII (Dependency Injection).

## When to use this skill
- When writing Firestore queries or document operations.
- When implementing authentication flows.
- When uploading/downloading files from Firebase Storage.
- When configuring push notifications (FCM).
- When setting up analytics or crashlytics events.

## ⛔ The Golden Rule

```dart
// Firebase SDK calls are ONLY allowed in:
lib/data/datasources/remote/   ← RemoteDataSource classes
lib/data/services/             ← Service wrappers (legacy)

// Firebase SDK calls are PROHIBITED in:
lib/domain/                    ← NEVER (zero external deps)
lib/presentation/              ← NEVER (except AuthProvider for legacy auth stream)
lib/core/                      ← NEVER (except config/firebase_config.dart)
```

## Firebase Services Used

| Service | Package | Purpose |
|---------|---------|---------|
| **Auth** | `firebase_auth: ^6.x` | Email/password, Google sign-in |
| **Firestore** | `cloud_firestore: ^6.x` | Primary database |
| **Storage** | `firebase_storage: ^13.x` | Image/file uploads |
| **Messaging** | `firebase_messaging: ^16.x` | Push notifications |
| **Analytics** | `firebase_analytics: ^12.x` | User behavior tracking |
| **Crashlytics** | `firebase_crashlytics: ^5.x` | Crash reporting |

## Firestore Patterns

### Document CRUD

```dart
class BookingRemoteDataSource {
  final FirebaseFirestore _firestore;

  BookingRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Collection reference (typed) ──
  CollectionReference<Map<String, dynamic>> get _bookingsRef =>
      _firestore.collection('bookings');

  // ── Create ──
  Future<String> createBooking(BookingModel booking) async {
    final docRef = await _bookingsRef.add(booking.toJson());
    return docRef.id;
  }

  // ── Read (single) ──
  Future<BookingModel> getBooking(String id) async {
    final doc = await _bookingsRef.doc(id).get();
    if (!doc.exists) throw NotFoundException('Booking not found');
    return BookingModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  // ── Read (query) ──
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final snapshot = await _bookingsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => BookingModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // ── Update ──
  Future<void> updateBookingStatus(String id, String status) async {
    await _bookingsRef.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Delete ──
  Future<void> deleteBooking(String id) async {
    await _bookingsRef.doc(id).delete();
  }
}
```

### Pagination
```dart
Future<List<BookingModel>> getBookingsPaginated({
  DocumentSnapshot? lastDocument,
  int limit = 20,
}) async {
  Query<Map<String, dynamic>> query = _bookingsRef
      .orderBy('createdAt', descending: true)
      .limit(limit);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }

  final snapshot = await query.get();
  return snapshot.docs
      .map((doc) => BookingModel.fromJson({...doc.data(), 'id': doc.id}))
      .toList();
}
```

### Real-time Listeners
```dart
Stream<List<BookingModel>> watchUserBookings(String userId) {
  return _bookingsRef
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BookingModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
}
```

### Batch Writes (for atomic operations)
```dart
Future<void> acceptBookingAndAssignTech(String bookingId, String techId) async {
  final batch = _firestore.batch();
  batch.update(_bookingsRef.doc(bookingId), {
    'status': 'assigned',
    'technicianId': techId,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  batch.update(_firestore.collection('technicians').doc(techId), {
    'currentBookingId': bookingId,
    'isAvailable': false,
  });
  await batch.commit();
}
```

## Auth Patterns

### Sign-in Flow
```dart
// In AuthRemoteDataSource (NOT in Provider directly)
Future<UserModel?> signInWithEmail(String email, String password) async {
  final credential = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);
  if (credential.user == null) return null;
  return UserModel.fromFirebaseUser(credential.user!);
}

// Google Sign-In
Future<UserModel?> signInWithGoogle() async {
  final googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null;
  final googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  final result = await FirebaseAuth.instance.signInWithCredential(credential);
  return UserModel.fromFirebaseUser(result.user!);
}
```

### Auth State Listener
```dart
Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();
```

## Storage Patterns

```dart
class FileUploadDataSource {
  final FirebaseStorage _storage;

  // Upload with progress tracking
  Future<String> uploadImage(String path, File file) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    // Track progress (optional)
    uploadTask.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      // Report progress to provider
    });

    await uploadTask;
    return await ref.getDownloadURL();
  }

  // Naming convention: users/{userId}/profile.jpg
  String profileImagePath(String userId) => 'users/$userId/profile.jpg';
  String bookingImagePath(String bookingId, int index) =>
      'bookings/$bookingId/image_$index.jpg';
}
```

## FCM Patterns

```dart
// Background handler (top-level function in main.dart)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
}

// Foreground handler (in NotificationService)
void setupForegroundListeners() {
  FirebaseMessaging.onMessage.listen((message) {
    // Show local notification via flutter_local_notifications
  });
}

// Token management
Future<String?> getFCMToken() async {
  return await FirebaseMessaging.instance.getToken();
}
```

## Testing with Firebase Mocks

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late BookingRemoteDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = BookingRemoteDataSource(firestore: fakeFirestore);
  });

  test('should return user bookings', () async {
    // Seed fake data
    await fakeFirestore.collection('bookings').add({
      'userId': 'user123',
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    final bookings = await dataSource.getUserBookings('user123');
    expect(bookings.length, 1);
    expect(bookings.first.status, 'pending');
  });
}
```
