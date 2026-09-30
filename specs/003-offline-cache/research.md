# Research: Local Caching & Offline Data Architecture

**Feature Branch**: `003-offline-cache`  
**Feature Spec**: [spec.md](spec.md)  
**Status**: Completed (Phase 0)  

---

## 1. Local Storage Engine Selection

### Decision
Use `SharedPreferences` wrapped in an abstract, generic `CacheManager` with JSON-serialized metadata envelopes (`cachedAt`, `expiresAt`, `data`).

### Rationale
- **Zero Native Build Overhead**: `SharedPreferences` works out-of-the-box across Android, iOS, Windows, macOS, Linux, and Web without needing native SQLite compilation, FFI bindings, or custom platform channels.
- **Payload Suitability**: The Fixsy mobile client caches small-to-medium datasets (user bookings lists, active profile metadata, category list, service items) which total < 3 MB. Key-value JSON storage has near-instant I/O in memory backed by disk.
- **Layer Decoupling (Principle I)**: All data persistence is abstracted behind `ICacheManager` and `IBookingLocalDataSource`. If high-volume relational offline storage is later required (e.g., offline full text search or 10,000+ cached items), the underlying engine can be swapped to Sembast or SQLite without modifying Domain Use Cases or UI.

### Alternatives Considered
- **sqflite / sqlite3**: Rejected for this phase due to Windows desktop FFI library linking requirements and the excessive schema migration boilerplate needed for simple JSON caching.
- **Hive / Isar**: Rejected because Hive v2 is largely unmaintained, and Isar v3 has binary compatibility hurdles across Flutter 3.x on Windows desktop without custom toolchains.
- **Sembast**: Pure Dart NoSQL database. Evaluated as an excellent candidate for the future background mutation sync queue, but `SharedPreferences` with metadata envelopes satisfies Story 2 and Story 3 with zero extra dependencies.

---

## 2. Real-Time Network Connectivity & Awareness

### Decision
Use `connectivity_plus` (version `^6.1.4`) abstracted behind the domain-clean `INetworkInfo` interface in `lib/core/network/network_info.dart`.

### Rationale
- **Clean Architecture Boundary**: Domain and Repositories only depend on `INetworkInfo` contract (`Future<bool> get isConnected`, `Stream<bool> get onConnectivityChanged`), never on the third-party `connectivity_plus` package directly.
- **Multiple Connectivity Results**: Modern versions of `connectivity_plus` return `List<ConnectivityResult>` (e.g., wifi + vpn active simultaneously). The helper method `_hasConnection` correctly inspects whether any active interface is non-none and routes through internet-capable mediums (`wifi`, `mobile`, `ethernet`, `vpn`).
- **Reactive UI & Background State**: Exposing both a one-shot `Future<bool>` and a continuous `Stream<bool>` allows providers (`ConnectivityProvider` or repositories) to adapt immediately upon reconnecting (triggering background refresh).

### Alternatives Considered
- **Periodic HTTP ping (e.g. pinging 8.8.8.8 or fixsy.app)**: High battery consumption, latency penalty on every query, and potential false negatives when cellular data has high latency.
- **Ad-hoc `InternetAddress.lookup`**: Blocks on DNS lookup and does not work seamlessly in Flutter Web or restricted sandbox environments.

---

## 3. Cache Eviction & Time-To-Live (TTL) Strategy

### Decision
Implement **Time-To-Live (TTL) Enveloping** with a dual retrieval mode:
1. **Strict Valid Mode (`ignoreExpired: false`)**: Returns `null` if `DateTime.now().isAfter(expiresAt)`. Used for fresh queries and stale checks.
2. **Offline Fallback Mode (`ignoreExpired: true`)**: Returns cached data even if expired, provided the network is offline or remote API fails.

### Default TTL Configurations
| Data Category | Key Pattern | Default TTL | Offline Fallback Permitted |
|---|---|---|---|
| User Bookings List | `cached_bookings_user_{userId}` | 48 Hours | Yes (Stale data is better than blank screen) |
| Single Booking Details | `cached_booking_{bookingId}` | 48 Hours | Yes |
| Service Catalog | `cached_services_catalog` | 7 Days | Yes |
| User Profile | `cached_user_profile_{userId}` | 24 Hours | Yes |

### Invalidation Policies
- **Explicit Invalidation**: Calling `cacheManager.remove(key)` on local mutation (e.g., when a user cancels or creates a booking).
- **Prefix Invalidation**: Calling `cacheManager.clearPrefix('cached_bookings_')` on user sign-out to guarantee Zero-Trust compliance (Principle III).

---

## 4. Repository Integration Pattern (Offline-First)

### Decision
Adopt the **Network-Aware Cache Fallback** pattern in `BookingRepository`:
1. Check `networkInfo.isConnected`.
2. **If Online**:
   - Fetch from `FirestoreService` / Remote API.
   - Update `BookingLocalDataSource` with fresh results in the background.
   - Return fresh data.
   - If remote fetch fails unexpectedly (network glitch / 500 error), catch failure, log warning via `AppLogger.warn`, and fall back to local cache if present.
3. **If Offline**:
   - Log informational notice via `AppLogger.info`.
   - Read directly from `BookingLocalDataSource.getCachedUserBookings(userId)`.
   - If cache is empty, throw typed `NoInternetException` with localized Arabic/English guidance.

### Alternatives Considered
- **Cache-Then-Network (Stream-based)**: Emitting cache first then emitting network result. While powerful, the current UI is based on `Future`-driven repository calls inside `ChangeNotifier` providers. A stream-based rewrite across all screens would require breaking UI changes. The chosen pattern achieves 100% offline availability with zero UI disruption.
