# Implementation Plan: Unified API Client & Interceptors

**Feature Branch**: `001-unified-api-client`
**Created**: 2026-09-30
**Status**: Ready
**Specification**: [spec.md](spec.md)

---

## Technical Architecture & File Layout

```text
lib/core/network/
├── api_endpoints.dart        # Base URLs, timeouts, headers, and route constants
├── api_exceptions.dart       # Structured exceptions mapped from DioException
├── api_interceptors.dart     # Auth token injection, logging, and 401 handling
└── api_client.dart           # Unified Dio wrapper with safeRequest & HTTP verbs
```

---

## Detailed Component Design

### 1. `api_endpoints.dart`
- `static const String baseUrl`: Points to backend or Firebase Cloud Functions API.
- `static const Duration connectTimeout = Duration(seconds: 15)`
- `static const Duration receiveTimeout = Duration(seconds: 15)`
- Common headers: `{'Content-Type': 'application/json', 'Accept': 'application/json'}`

### 2. `api_exceptions.dart`
- `ApiException` implementing `Exception`:
  - `NetworkException` (no internet, timeout)
  - `UnauthorizedException` (401 / session expired)
  - `ForbiddenException` (403)
  - `NotFoundException` (404)
  - `ServerException` (500+)
  - Factory constructor `ApiException.fromDio(DioException error)` for clean mapping.

### 3. `api_interceptors.dart`
- `AuthInterceptor`: Reads token via callback (e.g., token provider or secure storage) and attaches `Authorization: Bearer <token>`.
- `LoggingInterceptor`: Intercepts requests, responses, and errors, writing to `ErrorLogger` in debug mode with masked headers.
- `UnauthorizedInterceptor`: Detects 401 and calls `onUnauthorized` callback to notify Auth state.

### 4. `api_client.dart`
- Encapsulates `Dio` instance.
- Exposes `safeRequest<T>(Future<Response<T>> Function() request)` wrapper.
- Helper methods: `get()`, `post()`, `put()`, `delete()`, `patch()`.

---

## Verification & Testing
- Unit test suite in `test/core/network/api_client_test.dart` to verify:
  1. Successful JSON responses handled correctly.
  2. `DioException` correctly transformed into `ApiException`.
  3. `AuthInterceptor` attaches authorization headers.
