# Tasks: Secure Token Vault & Clean Auth Architecture

**Feature Branch**: `002-secure-auth-vault`
**Plan**: [plan.md](plan.md)
**Status**: Completed

---

## Phase 1: Secure Hardware-Encrypted Token Vault
- [x] **Task 1.1**: Build `TokenVault` in `lib/core/security/token_vault.dart` with `flutter_secure_storage`.

## Phase 2: Domain Clean Auth Contract
- [x] **Task 2.1**: Define `IAuthRepository` in `lib/domain/repositories/auth_repository.dart`.

## Phase 3: Data Implementation & Elimination of Hardcoded Roles
- [x] **Task 3.1**: Build `AuthRepositoryImpl` in `lib/data/repositories/auth_repository_impl.dart` with dynamic Firestore roles and `TokenVault` sync.
- [x] **Task 3.2**: Wire `TokenVault.getAccessToken` to `ApiClient.configureAuth`.

## Phase 4: Static Verification
- [x] **Task 4.1**: Run `dart analyze` to ensure zero compilation or analyzer errors.
