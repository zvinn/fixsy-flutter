# Quickstart & Validation Guide: Local Caching & Offline Architecture

**Feature Branch**: `003-offline-cache`  
**Feature Spec**: [spec.md](spec.md)  
**Data Model**: [data-model.md](data-model.md)  
**Status**: Ready (Phase 1)  

---

## 1. Prerequisites

- Flutter SDK (3.24.x or higher)
- Dependencies installed: `connectivity_plus`, `shared_preferences`
- Working directory: `fixsy_flutter/`

```bash
flutter pub get
```

---

## 2. Automated Test Execution

Run the dedicated offline caching test suite:

```bash
flutter test test/unit/datasources/local/cache_manager_test.dart
flutter test test/unit/repositories/booking_repository_test.dart
```

### Static Analysis & Linter Verification

```bash
dart analyze lib/core/network/ lib/data/datasources/local/ lib/data/repositories/booking_repository.dart
```

**Expected Outcome**: `No issues found!`

---

## 3. Manual & Scenario Validation Walkthrough

### Scenario A: TTL Expiration and Refresh
1. Call `CacheManager().put('test_key', {'name': 'Fixsy Service'}, ttl: Duration(milliseconds: 100))`.
2. Immediate fetch: `CacheManager().get('test_key')` returns `{'name': 'Fixsy Service'}`.
3. Wait `150ms`.
4. Fresh fetch with default policy: `CacheManager().get('test_key', ignoreExpired: false)` returns `null`.
5. Offline fallback fetch: `CacheManager().get('test_key', ignoreExpired: true)` returns `{'name': 'Fixsy Service'}`.

### Scenario B: Offline Bookings Fallback in Repository
1. **Online Phase**:
   - Device connects to internet (`INetworkInfo.isConnected == true`).
   - Call `BookingRepository.getUserBookings('user_123')`.
   - Data is retrieved from Firestore and automatically cached into `cached_bookings_user_user_123`.
2. **Offline Phase**:
   - Turn off Wi-Fi/Mobile data (Airplane mode) or mock `networkInfo.isConnected -> false`.
   - Call `BookingRepository.getUserBookings('user_123')`.
   - Console logs: `[INFO] Device is offline. Loading bookings from local cache.`
   - Bookings list is returned seamlessly to the UI with zero error popups.
3. **Empty Cache Offline Phase**:
   - Clear cache or query a new user ID while offline (`user_456`).
   - Repository catches missing cache and raises a graceful `Exception('خطأ في جلب الحجوزات')` preventing app crash.
