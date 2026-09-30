# Token Flow Diagram

## Authentication Token Lifecycle

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│  Login UI   │ ──→ │ AuthProvider  │ ──→ │ AuthDataSource  │
│  (Screen)   │     │ (Presentation)│     │   (Data Layer)  │
└─────────────┘     └──────────────┘     └────────┬────────┘
                                                   │
                                          Firebase Auth / API
                                                   │
                                          ┌────────▼────────┐
                                          │   TokenVault     │
                                          │ (Secure Storage) │
                                          └────────┬────────┘
                                                   │
                              ┌────────────────────┼────────────────────┐
                              │                    │                    │
                    ┌─────────▼──────┐   ┌────────▼────────┐   ┌──────▼──────┐
                    │ AuthInterceptor│   │ TokenRefresh     │   │   Logout    │
                    │ (attach token) │   │ Interceptor      │   │ (clearAll)  │
                    └────────────────┘   │ (on 401)         │   └─────────────┘
                                         └─────────────────┘
```

## Token Operations

| Operation | Method | When |
|-----------|--------|------|
| **Save** | `TokenVault.saveTokens(access, refresh)` | After successful login |
| **Read** | `TokenVault.getAccessToken()` | Before every API request (AuthInterceptor) |
| **Refresh** | `TokenVault.getRefreshToken()` → API call → `saveTokens()` | On 401 response |
| **Clear** | `TokenVault.clearAll()` | On logout or security breach |

## Security Rules

1. ✅ Tokens stored in `flutter_secure_storage` (AES encrypted)
2. ✅ Authorization header attached automatically by `AuthInterceptor`
3. ✅ Refresh token used only once per 401 cycle
4. ⛔ Tokens NEVER logged (LoggingInterceptor redacts `Authorization` header)
5. ⛔ Tokens NEVER stored in `SharedPreferences`
6. ⛔ Tokens NEVER passed as URL query parameters
