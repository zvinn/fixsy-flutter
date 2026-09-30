/// Centralized API Endpoints & Networking Constants
/// Complies with Fixsy Constitution Principle II & api-standards skill.
class ApiEndpoints {
  ApiEndpoints._();

  // Base URLs
  static String get baseUrl {
    // Defaults to production API or backend URL from environment
    return 'https://api.fixsy.app/v1';
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Common Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/me';

  // Bookings Endpoints
  static const String bookings = '/bookings';
  static String bookingDetails(String id) => '/bookings/$id';

  // Services & Categories
  static const String services = '/services';
  static const String categories = '/categories';

  // Technicians / Partners
  static const String technicians = '/technicians';
  static String technicianLocation(String id) => '/technicians/$id/location';

  // Notifications
  static const String notifications = '/notifications';
}
