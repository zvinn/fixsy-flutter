---
name: api-standards
description: Defines standards for API integration, networking with Dio, and handling backend responses. Use this skill when implementing new data sources or modifying API service logic.
---

# API & Networking Standards

This skill ensures that all remote data communication is handled consistently, efficiently, and with proper error handling.

> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md). Refer to Constitution §II (Unified API & Networking Standards) for governing principles.

## When to use this skill
- When creating a new API Service or Data Source.
- When adding a new endpoint to an existing service.
- When defining Backend-to-Frontend response models.
- When debugging network-related failures.

## Workflow
- [ ] Define the endpoint path in the relevant constants file.
- [ ] Use `ApiClient.safeRequest()` — never call `dio.get()`/`dio.post()` directly.
- [ ] Map raw JSON responses to Models immediately in the DataSource.
- [ ] Ensure proper error mapping (HTTP codes → `ApiException` → Domain `Failure`).
- [ ] Verify the `AuthInterceptor` attaches tokens automatically.

## Architecture

```
┌──────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Provider   │ ──→ │  RepositoryImpl  │ ──→ │ RemoteDataSource │
│ (Presentation)│     │   (Data Layer)   │     │   (Data Layer)   │
└──────────────┘     └──────────────────┘     └────────┬────────┘
                                                       │
                                              ┌────────▼────────┐
                                              │    ApiClient     │
                                              │  (safeRequest)   │
                                              └────────┬────────┘
                                                       │
                                              ┌────────▼────────┐
                                              │   Interceptors   │
                                              │ Auth│Log│Refresh │
                                              └─────────────────┘
```

## Key Components (Already Built)

### 1. `ApiClient` — `lib/core/network/api_client.dart`
Centralized Dio wrapper. All requests go through `safeRequest()`:

```dart
// ✅ CORRECT — Use safeRequest
final response = await apiClient.safeRequest(
  () => dio.get('/bookings'),
);
return (response.data as List).map((e) => BookingModel.fromJson(e)).toList();

// ❌ WRONG — Direct Dio calls
final response = await dio.get('/bookings'); // PROHIBITED
```

### 2. Interceptors — `lib/core/network/api_interceptors.dart`
Three mandatory interceptors (Constitution §II):
- **`AuthInterceptor`**: Attaches Bearer token from `TokenVault`.
- **`LoggingInterceptor`**: Logs requests/responses in debug mode. Redacts sensitive headers.
- **`TokenRefreshInterceptor`**: Catches 401, attempts refresh, retries original request. Triggers logout on failure.

### 3. Error Mapping
All `DioException` types must be caught in `safeRequest` and converted:

```dart
DioException → ApiException.fromDio(e) → Domain Failure
```

The `ApiException` class at `lib/core/error/exceptions.dart` maps HTTP status codes to typed exceptions (e.g., `UnauthorizedException`, `ServerException`, `NetworkException`).

### 4. `NetworkInfo` — `lib/core/network/network_info.dart`
Monitors connectivity status via `connectivity_plus`. Repositories must check `NetworkInfo.isConnected` before deciding to use remote or cached data (Offline-First pattern per Constitution §IV).

## Response Mapping Rules
- Always use the `Model` suffix for data layer objects.
- `fromJson` must be a `factory` constructor.
- Map immediately at the DataSource level — never pass raw `Map<String, dynamic>` to repositories.

```dart
// ✅ CORRECT
class BookingModel {
  factory BookingModel.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
}

// In RemoteDataSource:
final response = await apiClient.safeRequest(() => dio.get('/bookings/$id'));
return BookingModel.fromJson(response.data);
```
