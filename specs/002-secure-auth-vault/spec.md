# Feature Specification: Secure Token Vault & Clean Auth Architecture

**Feature Branch**: `002-secure-auth-vault`
**Created**: 2026-09-30
**Status**: Ready
**Input**: Implement secure token storage vault, domain-level IAuthRepository interface, and remove hardcoded role logic in accordance with Fixsy Constitution Principles I & III.

---

## User Scenarios & Testing

### User Story 1 - Secure Hardware-Encrypted Token Vault (Priority: P1)
As a user of Fixsy, my authentication tokens (access and refresh tokens) must be stored securely using hardware-backed encryption (`flutter_secure_storage`), preventing credential theft even if the device is inspected.

**Why this priority**: Directly enforces Fixsy Constitution Principle III (Zero-Trust Security & Token Vault) and `security-standards/SKILL.md`.

**Independent Test**: Can be tested by storing a mock JWT, verifying its presence in encrypted storage, retrieving it via `TokenVault`, and asserting all keys are wiped upon calling `clear()`.

**Acceptance Scenarios**:
1. **Given** a user signs in successfully, **When** auth tokens are received, **Then** they are stored encrypted via `TokenVault`.
2. **Given** an active session, **When** `TokenVault.getAccessToken()` is called by `ApiClient`, **Then** the valid token is returned without exposing it to insecure storage.
3. **Given** a user logs out, **When** `TokenVault.clear()` is called, **Then** all tokens and credentials are deleted completely.

---

### User Story 2 - Domain Clean Auth Repository Interface (Priority: P1)
As an architect/developer, the business logic layer must depend on an abstract `IAuthRepository` in the Domain layer, with zero direct dependency on `FirebaseAuth` or external SDKs.

**Why this priority**: Enforces Fixsy Constitution Principle I (Strict Clean Architecture).

**Independent Test**: Can be independently verified by checking imports: `lib/domain/repositories/auth_repository.dart` contains no imports of `firebase_auth` or UI libraries.

**Acceptance Scenarios**:
1. **Given** any authentication use case, **When** requesting authentication actions (login, register, logout, current user), **Then** it interfaces solely with `IAuthRepository`.
2. **Given** auth failures, **When** returned to domain/presentation, **Then** they are expressed as typed `AuthException` / `Failure` rather than raw Firebase codes.

---

### User Story 3 - Elimination of Hardcoded Roles & Data Repository Implementation (Priority: P2)
As a system administrator, user roles (client, partner, admin) must be dynamically determined from Firestore or token claims, eliminating hardcoded emails from the source code.

**Why this priority**: Removes security vulnerability and architectural debt in `auth_service.dart`.

**Independent Test**: Can be tested by signing in with test accounts and verifying their roles are loaded from the database profile.

**Acceptance Scenarios**:
1. **Given** a user signing in with any email, **When** profile is fetched, **Then** their assigned role is read dynamically from their Firestore user document.
2. **Given** successful authentication, **When** `TokenVault` and `ApiClient.configureAuth` are hooked, **Then** all future HTTP calls automatically carry the authenticated token.
