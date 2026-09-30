# Interface Contract: `IBookingLocalDataSource`

**Target File**: `lib/data/datasources/local/booking_local_datasource.dart`  
**Layer**: Data / Local DataSource  
**Enforces**: Fixsy Constitution Principle I (Clean Architecture) & Principle IV (Offline-First)  

---

## 1. Class Interface Definition

```dart
abstract class IBookingLocalDataSource {
  /// Caches a list of bookings associated with a specific user.
  /// Default TTL: 48 hours.
  Future<void> cacheUserBookings(String userId, List<Booking> bookings);

  /// Retrieves cached bookings for a specific user.
  /// Returns empty list if no cache is available.
  /// Uses `ignoreExpired: true` to ensure offline resilience.
  Future<List<Booking>> getCachedUserBookings(String userId);

  /// Caches a single booking record by its unique booking ID.
  Future<void> cacheBooking(Booking booking);

  /// Retrieves a single cached booking by its ID.
  /// Returns `null` if not found in local cache.
  Future<Booking?> getCachedBooking(String bookingId);
}
```

---

## 2. Behavioral Expectations

1. **Serialization**:
   - Must use `Booking.toJson()` when caching and `Booking.fromJson(Map<String, dynamic>)` when deserializing.
2. **Resilience**:
   - `getCachedUserBookings` must return an empty list (`[]`) rather than throwing an exception or returning `null` when cache is absent.
3. **Key Isolation**:
   - Keys must be strictly scoped to avoid cross-user data leakage:
     - `cached_bookings_user_{userId}`
     - `cached_booking_{bookingId}`
