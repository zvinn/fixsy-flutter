# Implementation Plan: Local Caching & Offline Data Architecture

**Branch**: `003-offline-cache` | **Date**: 2026-09-30 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-offline-cache/spec.md`

---

## Summary

Implement a production-grade local caching and offline fallback architecture adhering to Fixsy Constitution Principle IV. The architecture delivers a real-time connectivity monitor (`INetworkInfo`), a generic persistent cache manager with Time-To-Live envelopes (`CacheManager`), a local booking data source (`IBookingLocalDataSource`), and offline-first fallback resilience in `BookingRepository`.

---

## Technical Context

**Language/Version**: Dart 3.5+ / Flutter 3.24+  
**Primary Dependencies**: `connectivity_plus: ^6.1.4`, `shared_preferences: ^2.5.4`  
**Storage**: `SharedPreferences` (JSON envelope storage with TTL timestamps)  
**Testing**: `flutter_test`, `mockito` (Unit testing for CacheManager, NetworkInfo, and BookingRepository)  
**Target Platform**: Android, iOS, Windows Desktop, Web  
**Project Type**: Mobile & Cross-Platform Application (`fixsy_flutter`)  
**Performance Goals**: < 15ms cache read latency, zero UI thread freezing on network state transitions  
**Constraints**: Zero plain-text credential storage (Principle III), zero third-party dependencies in Domain (Principle I), graceful degradation when offline (Principle IV)  
**Scale/Scope**: ~10 core collections, < 5MB local cache footprint  

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Compliance Assessment | Status |
|---|---|---|
| **I. Strict Clean Architecture** | `INetworkInfo` interface in `lib/core/network/`, data sources and repositories in `lib/data/`, zero UI or framework leaks into Domain layer. | **PASSED** |
| **II. Unified API & Networking** | Offline fallback integrates with remote repositories without bypassing centralized network policies. | **PASSED** |
| **III. Zero-Trust Security & Vault** | User-specific cache keys (`cached_bookings_user_{userId}`); prefix clear (`clearPrefix`) during logout; sensitive tokens stored in `TokenVault`, not cache. | **PASSED** |
| **IV. Offline-First Mindset** | Core requirement. Implements TTL-based local caching, network monitoring, and seamless fallback to cached data when offline. | **PASSED** |
| **V. Unified Error Handling** | All cache read/write errors trapped and logged through `AppLogger`; typed exceptions thrown when offline without cache. | **PASSED** |
| **VI. State Management** | Presentation consumes data through standard providers without direct cache or connectivity coupling. | **PASSED** |
| **VII. Dependency Injection** | All local data sources and network info injected via constructors. | **PASSED** |
| **X. Testing & Quality Assurance** | Unit test suite verifying TTL expiration, envelope encoding, offline fallback, and linter clean checks. | **PASSED** |

---

## Project Structure

### Documentation (this feature)

```text
specs/003-offline-cache/
├── spec.md              # Requirements and user stories
├── plan.md              # This file (/speckit-plan output)
├── research.md          # Phase 0 output: Engine choice, TTL policies, network patterns
├── data-model.md        # Phase 1 output: CacheEnvelope, schemas, state machine
├── quickstart.md        # Phase 1 output: Runnable validation walkthrough
├── contracts/           # Phase 1 output: Interface contracts
│   ├── network_info_contract.md
│   ├── cache_manager_contract.md
│   └── booking_local_datasource_contract.md
└── tasks.md             # Granular implementation checklist
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── network/
│   │   └── network_info.dart                   # INetworkInfo & NetworkInfoImpl
│   └── utils/
│       └── app_logger.dart                     # Centralized logging
└── data/
    ├── datasources/
    │   └── local/
    │       ├── cache_manager.dart              # Generic TTL CacheManager
    │       └── booking_local_datasource.dart   # IBookingLocalDataSource
    ├── models/
    │   └── booking_model.dart                  # Booking entity model
    └── repositories/
        └── booking_repository.dart             # Offline-first fallback integration

test/
└── unit/
    ├── datasources/
    │   └── local/
    │       └── cache_manager_test.dart         # TTL and envelope unit tests
    └── repositories/
        └── booking_repository_test.dart        # Offline fallback repository tests
```

**Structure Decision**: Clean Architecture with modular local data source layering under `lib/data/datasources/local/` and contract abstraction in `lib/core/network/`.

---

## Complexity Tracking

> *No Constitution violations present. Architecture adheres strictly to all 10 principles.*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| None | N/A | N/A |
