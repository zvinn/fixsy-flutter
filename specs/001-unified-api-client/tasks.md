# Tasks: Unified API Client & Interceptors

**Feature Branch**: `001-unified-api-client`
**Plan**: [plan.md](plan.md)
**Status**: Completed

---

## Phase 1: Setup Core Network Models & Constants
- [x] **Task 1.1**: Define API endpoints and timeouts in `lib/core/network/api_endpoints.dart`.
- [x] **Task 1.2**: Define structured exceptions in `lib/core/network/api_exceptions.dart` with `ApiException.fromDio`.

## Phase 2: Interceptors & Resilience
- [x] **Task 2.1**: Implement `AuthInterceptor`, `LoggingInterceptor`, and `UnauthorizedInterceptor` in `lib/core/network/api_interceptors.dart`.

## Phase 3: Centralized ApiClient Implementation
- [x] **Task 3.1**: Build `ApiClient` with `safeRequest` and HTTP verbs in `lib/core/network/api_client.dart`.

## Phase 4: Validation & Testing
- [x] **Task 4.1**: Validate code with static analysis and verify no compilation errors.
