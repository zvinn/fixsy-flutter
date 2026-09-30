<!--
## Sync Impact Report
- Version change: 1.0.0 → 2.0.0
- Modified principles: None (all original principles preserved verbatim)
- Added sections:
  - VI. State Management (Provider-Based)
  - VII. Dependency Injection & Service Location
  - VIII. Navigation & Routing
  - IX. Localization & Internationalization
  - X. Testing & Quality Assurance
  - Architecture & Code Standards: expanded with File Organization, Folder Structure
- Removed sections: None
- Follow-up TODOs: None
-->

# Fixsy Constitution

This constitution serves as the single source of truth and the supreme architectural and engineering governance standard for the Fixsy project (`fixsy_flutter` & `fixsy-web-app`). Every specification, plan, task, and code implementation must strictly comply with these core principles.

---

## Core Principles

### I. Strict Clean Architecture
* **Layer Independence**: The application is divided into three distinct layers:
  1. **Domain Layer**: The heart of the application containing `Entities`, `UseCases`, and repository interfaces (`IRepository`). It has **zero dependencies** on external frameworks, databases, or UI libraries (no `firebase`, no `dio`, no Flutter UI code in Domain).
  2. **Data Layer**: Responsible for data retrieval and persistence. Contains `Models` (with JSON serialization), `Repositories Implementations`, and `DataSources` split into `remote` (APIs, Firebase) and `local` (Cache, Secure Storage, Database).
  3. **Presentation Layer**: UI Widgets, Screens, and State Management. The UI must never directly talk to external services, Firebase, or APIs; all operations must flow through Domain Use Cases or Controllers/Providers.
* **Dependency Rule**: Dependencies always point inward toward the Domain layer.

### II. Unified API & Networking Standards
* **Centralized API Client**: Direct ad-hoc calls to `http` or raw `dio` instances across the app are strictly prohibited.
* **Resilient Request Execution**: All network operations must go through a unified `safeRequest` wrapper that intercepts, standardizes, and maps HTTP status codes and network exceptions into typed domain failures.
* **Mandatory Interceptors**:
  * **Auth Interceptor**: Automatically attaches the Bearer token to outgoing authorized requests.
  * **Token Refresh & 401 Interceptor**: Handles session expiration gracefully by attempting token renewal or triggering a clean user logout.
  * **Logging Interceptor**: Logs requests and responses in development environments without leaking sensitive credentials.

### III. Zero-Trust Security & Token Vault
* **No Hardcoded Credentials**: API keys, secrets, admin email addresses, and environment credentials must never be committed to source code or hardcoded in services. Use environment configurations (`.env` via `flutter_dotenv`) and backend claims.
* **Encrypted Storage**: Sensitive data (JWTs, refresh tokens, auth credentials) must be stored in encrypted storage (`flutter_secure_storage` via `TokenVault`) and never in plain-text storage (e.g., standard `SharedPreferences`).
* **Session Lifecycle**: On user logout or security breach detection, all sensitive in-memory and local session data must be completely purged.

### IV. Offline-First Mindset & Caching
* **Data Resilience**: Core user flows (viewing active bookings, cached profile data, service catalog) must provide offline availability via local caching through `CacheManager`.
* **Network Awareness**: The app must monitor real-time connectivity status via `NetworkInfo` (backed by `connectivity_plus`) and gracefully notify the user or retry pending sync operations without freezing the UI or crashing.

### V. Unified Error Handling & Observability
* **No Silent Swallowing**: Empty `catch` blocks or raw uncaught exceptions are strictly prohibited.
* **Domain Failure Mapping**: All exceptions (network, auth, server, validation) must be mapped into user-friendly localized messages and properly logged through the centralized `AppErrorHandler` and `ErrorLogger`.
* **Crash Reporting**: Production crashes must be reported to `firebase_crashlytics` automatically through the global error handler.

### VI. State Management (Provider-Based)
* **Primary Tool**: `Provider` (package `provider: ^6.x`) is the sole state management solution. `flutter_riverpod` is available in the dependency tree but must NOT be used in new features until an explicit migration is ratified as an amendment to this constitution.
* **Provider Per Feature**: Each feature must have its own `ChangeNotifierProvider` (e.g., `AuthProvider`, `BookingsProvider`, `ServicesProvider`). Global state (theme, locale, connectivity) uses dedicated providers.
* **Separation of Concerns**: Providers must contain business logic and state orchestration only. They must delegate data operations to repositories/use cases and must never import `dart:io`, `firebase_*`, or `dio` directly.
* **Selective Rebuilding**: Use `context.select<T, R>()` or `Consumer` widgets instead of `context.watch<T>()` in large widget trees to minimize unnecessary rebuilds.
* **State Pattern**: Every asynchronous state must follow the **Loading → Success → Error** pattern. Providers must expose explicit `isLoading`, `errorMessage`, and data fields.

### VII. Dependency Injection & Service Location
* **Manual DI via Provider Tree**: Dependencies are injected through the Flutter widget tree using `MultiProvider` at the app root. No third-party DI container (`get_it`, `injectable`) is used unless ratified by amendment.
* **Constructor Injection**: Repositories and services must receive their dependencies through constructors. Hard-coding concrete implementations inside classes is prohibited.
* **Repository Pattern**: All data access must be abstracted behind interfaces (`IRepository` in Domain). The concrete implementation is instantiated once and provided to the widget tree.
* **Firebase Isolation**: Firebase SDK calls (`FirebaseAuth`, `CloudFirestore`, `FirebaseStorage`) must be confined exclusively to `RemoteDataSource` classes in the Data layer. No Firebase import is permitted in Domain or Presentation layers.

### VIII. Navigation & Routing
* **Named Routes**: The app uses Flutter's built-in named routes via `MaterialApp.onGenerateRoute` with a centralized `AppRoutes` class in `lib/routes/app_routes.dart`.
* **Single Source of Route Definitions**: All route names must be defined as `static const String` fields in `AppRoutes`. Hardcoded route strings anywhere else are prohibited.
* **Route Arguments**: Complex data must be passed via typed route arguments using `settings.arguments`. Direct widget constructor passing is prohibited for cross-screen navigation.
* **Authentication Guard**: Protected routes must check authentication state before rendering. Unauthenticated users must be redirected to the login screen.

### IX. Localization & Internationalization
* **Supported Languages**: Arabic (`ar`) and English (`en`). Arabic is the primary locale.
* **Custom Localization System**: The app uses a custom `AppLocalizations` class with `LocalizationsDelegate` at `lib/core/l10n/app_localizations.dart`. Translation strings are stored in `translations_ar.dart` and `translations_en.dart`.
* **No Hardcoded User-Facing Strings**: Every user-visible string (labels, messages, errors, button text) must be defined in both translation files and accessed via `AppLocalizations.of(context).translate('key')`.
* **RTL Support**: All layouts must support Right-to-Left (RTL) rendering for Arabic. Use `Directionality`-aware widgets and avoid hardcoded `padding` or `margin` with `left`/`right` — use `start`/`end` instead.
* **Date & Number Formatting**: Use the `intl` package for locale-aware date, time, and number formatting. Never use hardcoded date formats.

### X. Testing & Quality Assurance
* **Minimum Test Coverage**: Every new feature must include unit tests for its Repository and Provider/UseCase layers at minimum.
* **Testing Tools**: `mockito` for mocking, `fake_cloud_firestore` and `firebase_auth_mocks` for Firebase testing, Flutter's built-in `flutter_test` for widget tests.
* **Test Organization**: Tests must mirror the `lib/` folder structure under `test/` (e.g., `lib/data/repositories/` → `test/data/repositories/`).
* **Test Independence**: Each test must be self-contained and must not depend on the execution order of other tests. Shared setup must use `setUp()` and `tearDown()`.
* **No Untested Business Logic**: Providers and repositories containing business logic must have corresponding test files. UI-only widgets (purely presentational) may be excluded.

---

## Architecture & Code Standards

### Naming Conventions
* **Entities**: PascalCase nouns representing domain objects (e.g., `Booking`, `UserProfile`).
* **Models**: PascalCase with `Model` suffix (e.g., `BookingModel`, `UserModel`).
* **Repositories**: Interfaces prefixed with `I` in Domain (e.g., `IBookingRepository`), implementations suffixed with `Impl` in Data (e.g., `BookingRepositoryImpl`).
* **DataSources**: Suffixed with `RemoteDataSource` or `LocalDataSource` (e.g., `BookingRemoteDataSource`).
* **Providers**: Suffixed with `Provider` (e.g., `AuthProvider`, `BookingsProvider`).
* **Screens**: Suffixed with `Screen` (e.g., `LoginScreen`, `BookingsScreen`).
* **Widgets**: Descriptive PascalCase names (e.g., `BookingCard`, `ServiceTile`).

### Folder Structure
```
lib/
├── core/           # Shared infrastructure
│   ├── config/     # Environment, Firebase config
│   ├── constants/  # App-wide constants
│   ├── error/      # AppErrorHandler, ErrorLogger, Exceptions, Failures
│   ├── l10n/       # Localization (AppLocalizations, translations)
│   ├── network/    # ApiClient, Interceptors, NetworkInfo
│   ├── security/   # TokenVault
│   ├── theme/      # AppTheme, colors, typography
│   └── utils/      # Shared utilities, AppLogger
├── data/           # Data layer
│   ├── datasources/  # remote/ and local/ data sources
│   ├── models/       # JSON-serializable models
│   ├── repositories/ # Repository implementations
│   └── services/     # External service wrappers
├── domain/         # Domain layer (zero external deps)
│   ├── entities/   # Pure domain objects
│   └── repositories/ # Repository interfaces (IRepository)
├── presentation/   # Presentation layer
│   ├── layouts/    # Shared layout shells
│   ├── providers/  # State management (ChangeNotifier)
│   ├── screens/    # Feature screens organized by feature/
│   └── widgets/    # Reusable UI components
├── routes/         # Centralized route definitions
└── main.dart       # App entry point
```

### State Management Pattern
* Unify state management conventions across modules, minimizing UI rebuilds by using selective rebuilding (selectors / `Consumer`) and separating business logic from view layout.

---

## Governance & Compliance

1. **Supremacy**: This Constitution supersedes all ad-hoc conventions. Code that violates these principles must be refactored before merging.
2. **Quality Gates**: Every feature workflow must proceed through:
   `Specify` (Specification) → `Plan` (Architecture Plan) → `Tasks` (Granular Tasks) → `Implement` (Code & Tests).
3. **Amendments**: Changes to this constitution require explicit documentation, justification, and ratification. Version must follow semantic versioning (MAJOR.MINOR.PATCH).

**Version**: 2.0.0 | **Ratified**: 2026-09-30 | **Last Amended**: 2026-09-30 | **Status**: Active
