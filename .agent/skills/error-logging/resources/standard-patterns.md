# Standard Error Handling Patterns

### 1. Functional Error Handling (Either)
For business logic, prefer returning an `Either` type to force the caller to handle success/failure explicitly.

```dart
Future<Either<Failure, User>> getUser() async {
  try {
    final user = await _remoteSource.fetch();
    return Right(user);
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}
```

### 2. UI Layer Handling
Use `ScaffoldMessenger` or custom Error Dialogs to inform the user.

```dart
final result = await provider.doSomething();
result.fold(
  (failure) => context.showError(failure.message),
  (success) => context.showSuccess('Success!'),
);
```

### 3. Graceful Degradation
If a non-critical component fails, log it but don't crash the UI.
```dart
try {
  loadMinorWidgetData();
} catch (e) {
  logger.warning('Failed to load minor data, skipping...');
}
```
