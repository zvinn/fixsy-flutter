# Implementation Plan: Secure Token Vault & Clean Auth Architecture

**Feature Branch**: `002-secure-auth-vault`
**Created**: 2026-09-30
**Status**: Ready
**Specification**: [spec.md](spec.md)

---

## Technical Architecture & File Layout

```text
lib/
├── core/
│   └── security/
│       └── token_vault.dart                 # Hardware-backed encrypted token storage
├── domain/
│   └── repositories/
│       └── auth_repository.dart            # Domain contract (IAuthRepository)
└── data/
    └── repositories/
        └── auth_repository_impl.dart       # Implementation linking Firebase + TokenVault
```

---

## Component Details

### 1. `TokenVault` (`lib/core/security/token_vault.dart`)
- Singleton wrapping `FlutterSecureStorage`.
- Uses Android `AndroidOptions(encryptedSharedPreferences: true)` and iOS `IOSOptions(accessibility: KeychainAccessibility.first_unlock)`.
- Keys:
  - `_keyAccessToken = 'fixsy_access_token'`
  - `_keyRefreshToken = 'fixsy_refresh_token'`
  - `_keyUserId = 'fixsy_user_id'`
- Methods: `saveTokens()`, `getAccessToken()`, `getRefreshToken()`, `clear()`.

### 2. `IAuthRepository` (`lib/domain/repositories/auth_repository.dart`)
- Pure Dart interface.
- Returns domain entity `User`.
- Throws typed `AuthException`.

### 3. `AuthRepositoryImpl` (`lib/data/repositories/auth_repository_impl.dart`)
- Implements `IAuthRepository`.
- Replaces hardcoded admin email with dynamic Firestore role query.
- Saves the Firebase ID token in `TokenVault` on successful sign-in.
- Purges `TokenVault` on sign-out.
- Binds `TokenVault.getAccessToken` to `ApiClient`.

---

## Verification
- Run `dart analyze` to ensure zero compilation or architectural lint errors.
- Confirm no hardcoded emails in the auth logic.
