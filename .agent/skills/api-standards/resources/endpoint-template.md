# API Endpoint Template

Use this template when adding a new API endpoint to the project.

## 1. Define the Endpoint Constant

```dart
// In lib/core/constants/api_constants.dart (or feature-specific file)
class ApiEndpoints {
  static const String baseUrl = 'https://api.fixsy.com/v1';

  // Bookings
  static const String bookings = '/bookings';
  static String bookingById(String id) => '/bookings/$id';
  static String userBookings(String userId) => '/users/$userId/bookings';

  // Services
  static const String services = '/services';
  static String serviceById(String id) => '/services/$id';
}
```

## 2. Create the RemoteDataSource Method

```dart
// In lib/data/datasources/remote/booking_remote_datasource.dart
Future<BookingModel> getBooking(String id) async {
  final response = await apiClient.safeRequest(
    () => dio.get(ApiEndpoints.bookingById(id)),
  );
  return BookingModel.fromJson(response.data);
}
```

## 3. Add to Repository

```dart
// In lib/data/repositories/booking_repository_impl.dart
@override
Future<Booking> getBooking(String id) async {
  try {
    final model = await remoteDataSource.getBooking(id);
    return model.toEntity();
  } on ApiException catch (e, s) {
    ErrorLogger.log('getBooking failed', error: e, stack: s);
    throw ServerFailure(e.message);
  }
}
```

## 4. Call from Provider

```dart
// In lib/presentation/providers/booking_provider.dart
Future<void> loadBooking(String id) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    _booking = await _repository.getBooking(id);
  } catch (e, s) {
    _errorMessage = e.toString();
    ErrorLogger.log('loadBooking failed', error: e, stack: s);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```
