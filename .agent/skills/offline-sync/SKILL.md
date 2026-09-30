---
name: offline-sync
description: Defines offline-first data patterns including caching strategies, network awareness, and sync queue management. Use this skill when implementing data persistence, cache policies, or offline user flows.
---

# Offline-First & Data Sync Patterns

This skill defines how Fixsy handles data when the device is offline or has intermittent connectivity.

> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md) §IV (Offline-First Mindset & Caching).

## When to use this skill
- When implementing data fetching that should work offline.
- When deciding cache duration (TTL) for a data type.
- When handling user actions while offline (queue pattern).
- When implementing connectivity-aware UI.

## Key Components (Already Built)

| Component | Location | Purpose |
|-----------|----------|---------|
| `NetworkInfo` | `lib/core/network/network_info.dart` | Real-time connectivity status via `connectivity_plus` |
| `ConnectivityProvider` | `lib/presentation/providers/connectivity_provider.dart` | Exposes network state to UI |
| `CacheManager` | `lib/core/utils/cache_manager.dart` (if exists) | Local data persistence |
| `SharedPreferences` | via `shared_preferences` package | Non-sensitive cached data |

## Caching Strategies

### Strategy 1: Cache-First (for slow-changing data)
Use when data doesn't change often and stale data is acceptable.

```dart
Future<List<ServiceModel>> getServices() async {
  // 1. Try cache first
  final cached = await localDataSource.getCachedServices();
  if (cached != null && !cached.isExpired) {
    return cached.data;
  }

  // 2. If online, fetch fresh data and update cache
  if (await networkInfo.isConnected) {
    try {
      final fresh = await remoteDataSource.getServices();
      await localDataSource.cacheServices(fresh);
      return fresh;
    } catch (e) {
      // Network error — return stale cache if available
      if (cached != null) return cached.data;
      rethrow;
    }
  }

  // 3. Offline + no cache = error
  if (cached != null) return cached.data;
  throw CacheException('No cached data and device is offline');
}
```

**Use for**: Service catalog, categories, FAQs, app configuration

### Strategy 2: Network-First (for frequently-changing data)
Use when freshness is important but offline fallback is still needed.

```dart
Future<List<BookingModel>> getUserBookings(String userId) async {
  // 1. Try network first
  if (await networkInfo.isConnected) {
    try {
      final bookings = await remoteDataSource.getUserBookings(userId);
      await localDataSource.cacheUserBookings(userId, bookings);
      return bookings;
    } catch (e) {
      // Network error — fall through to cache
    }
  }

  // 2. Fallback to cache
  final cached = await localDataSource.getCachedUserBookings(userId);
  if (cached != null) return cached;

  throw CacheException('Cannot load bookings offline');
}
```

**Use for**: Active bookings, user profile, wallet balance

### Strategy 3: Network-Only (for real-time data)
Use when stale data is dangerous or meaningless.

```dart
Future<TechnicianLocation> getTechnicianLocation(String techId) async {
  if (!await networkInfo.isConnected) {
    throw NetworkException('Real-time location requires internet');
  }
  return await remoteDataSource.getTechnicianLocation(techId);
}
```

**Use for**: Live tracking, payment processing, real-time chat

## TTL (Time-To-Live) Guidelines

| Data Type | TTL | Strategy | Rationale |
|-----------|-----|----------|-----------|
| Service catalog | 24 hours | Cache-First | Rarely changes |
| App configuration | 12 hours | Cache-First | Static settings |
| User profile | 1 hour | Network-First | May change from other devices |
| Active bookings | 5 minutes | Network-First | Status changes frequently |
| Wallet balance | 2 minutes | Network-First | Financial accuracy |
| Chat messages | 0 (real-time) | Network-Only | Must be current |
| Technician location | 0 (real-time) | Network-Only | Must be current |
| Notification list | 30 minutes | Network-First | Not time-critical |

## Cache Storage Implementation

```dart
class CachedData<T> {
  final T data;
  final DateTime cachedAt;
  final Duration ttl;

  CachedData({required this.data, required this.cachedAt, required this.ttl});

  bool get isExpired => DateTime.now().difference(cachedAt) > ttl;
}
```

### Storage decisions:
| Data | Storage | Why |
|------|---------|-----|
| Auth tokens | `flutter_secure_storage` (TokenVault) | Encrypted — Constitution §III |
| User preferences | `SharedPreferences` | Simple key-value, non-sensitive |
| Cached API data | `SharedPreferences` (JSON) | Quick access, auto-cleared |
| Cached images | `CachedNetworkImage` disk cache | Automatic management |

## Offline Queue Pattern

For actions the user performs while offline:

```dart
class OfflineActionQueue {
  static const _queueKey = 'offline_action_queue';

  // Enqueue action when offline
  Future<void> enqueue(OfflineAction action) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey) ?? [];
    queue.add(jsonEncode(action.toJson()));
    await prefs.setStringList(_queueKey, queue);
  }

  // Process queue when back online
  Future<void> processQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey) ?? [];

    final failed = <String>[];
    for (final item in queue) {
      try {
        final action = OfflineAction.fromJson(jsonDecode(item));
        await action.execute();
      } catch (e) {
        failed.add(item);
        ErrorLogger.log('Offline action failed', error: e);
      }
    }

    await prefs.setStringList(_queueKey, failed);
  }
}
```

**Queueable actions**: Rating submission, booking cancellation, profile update

**Non-queueable actions**: Payment, live chat, new booking (requires server validation)

## Connectivity-Aware UI

### Using `ConnectivityProvider`:
```dart
Consumer<ConnectivityProvider>(
  builder: (context, connectivity, child) {
    if (!connectivity.isConnected) {
      return const OfflineBanner(
        message: 'You are offline. Some features may be limited.',
      );
    }
    return const SizedBox.shrink();
  },
)
```

### Auto-retry on reconnection:
```dart
// In Provider
void onConnectivityChanged(bool isConnected) {
  if (isConnected && _hasStaleData) {
    loadData(); // Auto-refresh when back online
  }
  if (isConnected) {
    OfflineActionQueue().processQueue(); // Flush pending actions
  }
}
```

## Conflict Resolution

When data changed both locally (offline) and remotely:

| Strategy | When |
|----------|------|
| **Server wins** | Financial data, booking status |
| **Client wins** | Draft forms, user preferences |
| **Merge** | Profile fields (merge non-conflicting) |
| **Prompt user** | Rare — only for destructive conflicts |

Default rule: **Server wins** unless explicitly specified otherwise.
