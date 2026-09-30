# Interface Contract: `CacheManager`

**Target File**: `lib/data/datasources/local/cache_manager.dart`  
**Layer**: Data / Local DataSource  
**Enforces**: Fixsy Constitution Principle IV (Offline-First Mindset & Caching)  

---

## 1. Class Interface Definition

```dart
class CacheManager {
  /// Singleton factory accessor
  factory CacheManager();

  /// Persists JSON-encodable data under a unique key wrapped in a TTL envelope.
  /// 
  /// Parameters:
  /// - `key`: Non-empty unique cache key.
  /// - `data`: Primitive, Map<String, dynamic>, or List<dynamic> (must be JSON-encodable).
  /// - `ttl`: Time-To-Live duration. Defaults to 24 hours.
  Future<void> put(
    String key,
    dynamic data, {
    Duration ttl = const Duration(hours: 24),
  });

  /// Retrieves data associated with the key.
  /// 
  /// Parameters:
  /// - `key`: The target cache key.
  /// - `ignoreExpired`: When `false` (default), returns `null` if current time exceeds `expiresAt`.
  ///                    When `true`, returns stale data even if TTL has elapsed (offline fallback).
  /// 
  /// Returns decoded JSON payload or `null` if missing or expired.
  Future<dynamic> get(
    String key, {
    bool ignoreExpired = false,
  });

  /// Evaluates whether a valid (unexpired) cache entry exists for `key`.
  Future<bool> hasValid(String key);

  /// Removes the specified key from storage immediately.
  Future<void> remove(String key);

  /// Invalidates and removes all keys matching the provided string prefix.
  /// Used during user logout or domain cache purge.
  Future<void> clearPrefix(String prefix);
}
```

---

## 2. Envelope Specification

Every entry saved via `put()` must be stored as a serialized JSON string conforming to:

```json
{
  "cachedAt": "<ISO-8601-STRING>",
  "expiresAt": "<ISO-8601-STRING>",
  "data": "<SERIALIZED-PAYLOAD>"
}
```

## 3. Error Handling

- All `CacheManager` operations must catch internal `PlatformException` or JSON encode/decode failures.
- Errors must be recorded through `AppLogger.error` and must never crash the calling application thread.
- If storage corruption occurs on a key, `get()` must log the error and return `null`.
