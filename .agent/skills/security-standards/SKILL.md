---
name: security-standards
description: Strict security rules for protecting user data and securing the application. Use this skill when handling authentication, local storage, or sensitive data.
---

# Security & Data Protection Standards

Security is non-negotiable. We must protect user privacy and prevent data breaches.

> **Authority**: This skill is subordinate to the [Fixsy Constitution](file:///.specify/memory/constitution.md). Refer to Constitution §III (Zero-Trust Security & Token Vault) for governing principles.

## When to use this skill
- When implementing Login/Signup flows.
- When storing tokens (JWT, Refresh tokens).
- When handling user PII (Personally Identifiable Information).
- When interacting with the device's secure elements.

## Workflow
- [ ] Never store sensitive data in `SharedPreferences`.
- [ ] Use `TokenVault` (backed by `flutter_secure_storage`) for all authentication tokens.
- [ ] Ensure all API communication is over HTTPS.
- [ ] Sanitize user input to prevent injection attacks.
- [ ] Obfuscate the code for production builds.

## Token Management (TokenVault)

All token operations must go through the centralized `TokenVault` at `lib/core/security/token_vault.dart`:

```dart
// ✅ CORRECT — Use TokenVault
final token = await TokenVault.getAccessToken();
await TokenVault.saveTokens(accessToken: jwt, refreshToken: refresh);
await TokenVault.clearAll(); // On logout

// ❌ WRONG — Never use SharedPreferences for tokens
final prefs = await SharedPreferences.getInstance();
prefs.setString('token', jwt); // PROHIBITED
```

### Token Lifecycle Rules:
1. **Save tokens** immediately after successful authentication.
2. **Read tokens** via `TokenVault` in the `AuthInterceptor` before each API request.
3. **Refresh tokens** via the `TokenRefreshInterceptor` on 401 responses.
4. **Clear all tokens** on logout via `TokenVault.clearAll()`.
5. **Never log tokens** — the `LoggingInterceptor` must redact Authorization headers.

## Environment Secrets

- Use `flutter_dotenv` to load environment variables from `.env`.
- The `.env` file must be in `.gitignore` — never committed to version control.
- Access via `EnvConfig` at `lib/core/config/env_config.dart`.
- ⛔ Never hardcode API keys, Firebase config, or admin emails in source code.

## PII Protection
- Encrypt PII if it must be stored locally.
- Minimize the amount of user data stored on the device.
- Clear all cached user data on logout alongside token purge.

## Firebase Security
- Firebase SDK calls are confined to `RemoteDataSource` classes only (Constitution §VII).
- Firebase Auth state changes must be monitored through `AuthProvider` — never checked directly in UI.
- Firestore security rules must be validated server-side; client-side checks are supplementary only.
