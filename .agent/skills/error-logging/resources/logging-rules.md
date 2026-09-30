# Logging Rules & Best Practices

To maintain security and clean logs, follow these rules:

### 1. No PII in Logs
Never log Personally Identifiable Information (PII) like:
- Passwords
- Full names (unless necessary for debugging a specific user)
- Email addresses
- Phone numbers
- GPS coordinates

**Bad:** `log('User $email failed to login')`
**Good:** `log('User ID $userId failed to login')`

### 2. Include Semantic Context
Always provide enough context to understand *where* the error happened.
- Current Screen/Route
- Operation name
- Key IDs (not PII)

### 3. Log Levels
- `DEBUG`: Information for developers during implementation.
- `INFO`: General app flow events.
- `WARNING`: Unexpected but recoverable issues.
- `ERROR`: Critical failures that affect user experience.

### 4. External Services
- Use `Sentry.captureException()` for all `ERROR` level events.
- Use `FirebaseCrashlytics.instance.recordError()` for fatal crashes.
