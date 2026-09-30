# Implementation Plan: Local Caching & Offline Data Architecture

**Feature Branch**: `003-offline-cache`
**Created**: 2026-09-30
**Status**: Ready
**Specification**: [spec.md](spec.md)

---

## Technical Architecture & File Layout

```text
lib/
├── core/
│   └── network/
│       └── network_info.dart                   # Connectivity monitoring (INetworkInfo)
└── data/
    ├── datasources/
    │   └── local/
    │       ├── cache_manager.dart              # Generic TTL-based persistent cache
    │       └── booking_local_datasource.dart   # Local bookings persistence
    └── repositories/
        └── booking_repository.dart             # Updated with offline fallback logic
```

---

## Detailed Component Design

### 1. `NetworkInfo` (`lib/core/network/network_info.dart`)
- Interface `INetworkInfo`:
  - `Future<bool> get isConnected`
  - `Stream<bool> get onConnectivityChanged`
- Implementation `NetworkInfoImpl` wrapping `Connectivity` from `connectivity_plus`.

### 2. `CacheManager` (`lib/data/datasources/local/cache_manager.dart`)
- Singleton wrapping `SharedPreferences`.
- Wraps cached objects in metadata: `{ "timestamp": "...", "ttlMs": 3600000, "data": ... }`.
- Supports primitives, Maps, and Lists of Maps.

### 3. `BookingLocalDataSource` (`lib/data/datasources/local/booking_local_datasource.dart`)
- Saves and loads `List<Booking>` locally via `CacheManager` with 24-hour default TTL.

### 4. `BookingRepository` Integration
- Checks `_networkInfo.isConnected`.
- When online: queries Firestore, updates local cache, returns fresh data.
- When offline: gracefully reads from `BookingLocalDataSource`, returns cached bookings with offline logging instead of crashing.

---

## Verification
- Run `dart analyze` across all affected directories.
- Confirm zero broken imports and 100% compliance with Fixsy Constitution Principle IV.
