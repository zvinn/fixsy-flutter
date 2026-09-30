---
name: clean-architecture
description: Formalizes the project's architectural standards using Clean Architecture principles. Use this skill when creating new features, refactoring existing code, or organizing file structures.
---

# Clean Architecture & Code Standards

This skill defines how the Fixsy project is structured to ensure maintainability, testability, and scalability. It follows the principles of Clean Architecture, adapted for Flutter.

> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md). Refer to Constitution §I (Strict Clean Architecture) and §VII (Dependency Injection) for governing principles.

## When to use this skill
- When creating a new feature directory.
- When deciding where to place a new class or file.
- When reviewing code for architectural consistency.
- When refactoring large files into smaller components.

## Workflow
- [ ] Determine which layer the new component belongs to (Domain, Data, or Presentation).
- [ ] Verify that imports follow the dependency rule (Inside-out).
- [ ] Follow naming conventions from `resources/naming-conventions.md`.
- [ ] Check layer-specific rules in `resources/layer-rules.md`.

## Core Project Structure

The project is divided into three main layers:

### 1. Domain Layer (`lib/domain/`)
The heart of the application. **Zero external dependencies**.
- **Entities** (`entities/`): Pure Dart classes representing business objects (e.g., `Booking`, `UserProfile`).
- **Repository Interfaces** (`repositories/`): Abstract contracts prefixed with `I` (e.g., `IBookingRepository`, `IAuthRepository`).
- **Use Cases** (when needed): Single-responsibility classes encapsulating business rules.
- ⛔ **Prohibited imports**: No `firebase_*`, `dio`, `http`, `flutter/material.dart`, `provider`, or any Data/Presentation layer code.

### 2. Data Layer (`lib/data/`)
Handles data retrieval, persistence, and external communication.
- **Models** (`models/`): JSON-serializable classes with `Model` suffix (e.g., `BookingModel`). Always implement `fromJson`/`toJson`.
- **Repositories** (`repositories/`): Concrete implementations suffixed with `Impl` (e.g., `BookingRepositoryImpl`). Implement Domain interfaces.
- **DataSources** (`datasources/`):
  - `remote/`: API calls via `ApiClient`, Firebase SDK calls. Suffixed with `RemoteDataSource`.
  - `local/`: Cache, Secure Storage, SharedPreferences. Suffixed with `LocalDataSource`.
- **Services** (`services/`): Wrappers for platform services (Analytics, Notifications, etc.).

### 3. Presentation Layer (`lib/presentation/`)
UI and state management. **Never talks directly to Firebase/APIs**.
- **Screens** (`screens/`): Organized by feature (e.g., `screens/auth/`, `screens/bookings/`). Suffixed with `Screen`.
- **Providers** (`providers/`): `ChangeNotifierProvider` classes managing state. Suffixed with `Provider`.
- **Widgets** (`widgets/`): Reusable UI components.
- **Layouts** (`layouts/`): Shared layout shells (e.g., `MainLayout`).

### 4. Core Layer (`lib/core/`)
Shared infrastructure used across all layers.
- `config/` — Environment and Firebase configuration.
- `constants/` — App-wide constant values.
- `error/` — `AppErrorHandler`, `ErrorLogger`, `Exceptions`, `Failures`.
- `l10n/` — `AppLocalizations` and translation files.
- `network/` — `ApiClient`, `ApiInterceptors`, `NetworkInfo`.
- `security/` — `TokenVault` for encrypted token storage.
- `theme/` — `AppTheme`, colors, typography.
- `utils/` — Shared utilities, `AppLogger`.

## Dependency Rule (Visual)

```
┌─────────────────────────────────┐
│       Presentation Layer        │
│  (Screens, Providers, Widgets)  │
│         ↓ depends on ↓         │
├─────────────────────────────────┤
│         Domain Layer            │
│  (Entities, IRepositories)      │
│         ↑ depends on ↑         │
├─────────────────────────────────┤
│          Data Layer             │
│  (Models, Repos, DataSources)   │
└─────────────────────────────────┘
```

**Rule**: Dependencies always point **inward** toward Domain. Domain never imports from Data or Presentation.

## Resources
- [Layer Rules](resources/layer-rules.md)
- [Naming Conventions](resources/naming-conventions.md)
