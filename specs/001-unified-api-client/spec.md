# Feature Specification: Unified API Client & Interceptors

**Feature Branch**: `001-unified-api-client`
**Created**: 2026-09-30
**Status**: Draft
**Input**: Implement unified API client with interceptors, resilient request execution (`safeRequest`), and robust domain error mapping in accordance with Fixsy Constitution Principle II.

---

## User Scenarios & Testing

### User Story 1 - Centralized & Resilient Request Handling (Priority: P1)
As a developer building data sources in Fixsy, I need a unified `ApiClient` wrapper around `Dio` with a `safeRequest` method, so that all network communications are consistently executed with timeouts, proper headers, and converted into domain-friendly `Failure` objects without crashing the app.

**Why this priority**: Fundamental foundation for all remote network communications across Fixsy. Without this, services write fragmented, unhandled HTTP calls.

**Independent Test**: Can be independently tested by sending mock GET/POST requests through `safeRequest` and asserting proper parsing on success and structured `ApiException` / `Failure` on network timeout, 404, or 500 errors.

**Acceptance Scenarios**:
1. **Given** a valid endpoint and correct parameters, **When** `safeRequest` is invoked, **Then** the request completes successfully and returns the expected response.
2. **Given** a network loss or connection timeout, **When** `safeRequest` is invoked, **Then** it throws a mapped `NetworkException` with a clear Arabic error message ("تعذر الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت").
3. **Given** a server error (HTTP 500), **When** `safeRequest` is invoked, **Then** it throws a `ServerException` without leaking internal server traces to the UI.

---

### User Story 2 - Automated Auth Token Injection (Priority: P2)
As an authenticated user (client or technician), my requests to protected backend endpoints must automatically include my Bearer authentication token, without manual header construction in every service.

**Why this priority**: Essential for security and developer efficiency; prevents repetitive, error-prone token injection.

**Independent Test**: Can be tested by invoking a protected endpoint and inspecting the outgoing HTTP headers for `Authorization: Bearer <token>`.

**Acceptance Scenarios**:
1. **Given** an authenticated user session with a stored token, **When** an authorized request is dispatched, **Then** the `AuthInterceptor` automatically attaches `Authorization: Bearer <token>` to the request headers.
2. **Given** an unauthenticated session (public endpoint), **When** the request is dispatched with `requiresAuth: false`, **Then** no authorization header is added.

---

### User Story 3 - Graceful 401 Session Expiration & Developer Logging (Priority: P3)
As a user whose token has expired, or a developer debugging API issues, the app should automatically detect 401 Unauthorized responses to notify the auth layer, and log requests in debug mode without leaking sensitive credentials.

**Why this priority**: Prevents stale sessions from causing ghost bugs, and provides observability during development.

**Independent Test**: Can be tested by returning a 401 status from a mock server and verifying that the unauthorized handler callback is triggered.

**Acceptance Scenarios**:
1. **Given** an expired session receiving HTTP 401, **When** the response interceptor catches it, **Then** it triggers the unauthorized callback to clear session and redirect to login.
2. **Given** development mode (`kDebugMode`), **When** requests and responses are exchanged, **Then** a sanitized, structured log is printed using `AppErrorHandler` / `ErrorLogger`.

---

## Technical Constraints & Standards
* Must comply with **Fixsy Constitution Principle II (Unified API & Networking Standards)**.
* Direct calls to raw `Dio` or `http` from UI or Repositories are strictly forbidden.
* Must follow `api-standards/SKILL.md` guidelines:
  * Endpoints defined in `lib/core/network/api_endpoints.dart`.
  * Client in `lib/core/network/api_client.dart`.
  * Interceptors in `lib/core/network/api_interceptors.dart`.
