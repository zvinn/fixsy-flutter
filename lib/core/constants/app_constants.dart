/// App Constants
/// All constant values used throughout the application
class AppConstants {
  // App Information
  static const String appName = 'Fixsy';
  static const String appNameArabic = 'فكسي - صيانة منازل ذكية';
  static const String appVersion = '1.0.0';

  // API Endpoints (if needed)
  static const String baseUrl = 'https://your-api-url.com';

  // Pagination
  static const int itemsPerPage = 20;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration shortDelay = Duration(milliseconds: 300);
  static const Duration mediumDelay = Duration(seconds: 1);

  // Image Sizes
  static const double userAvatarSize = 100.0;
  static const double thumbnailSize = 80.0;

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  // Icon Sizes
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  // User Roles
  static const String roleCustomer = 'customer';
  static const String roleTechnician = 'technician';
  static const String roleAdmin = 'admin';

  // Booking Status
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Service Categories (examples)
  static const List<String> serviceCategories = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'AC Repair',
    'Appliance Repair',
  ];

  // Service Categories Arabic
  static const Map<String, String> serviceCategoriesArabic = {
    'Plumbing': 'سباكة',
    'Electrical': 'كهرباء',
    'Carpentry': 'نجارة',
    'Painting': 'دهان',
    'AC Repair': 'تكييف',
    'Appliance Repair': 'أجهزة منزلية',
  };
}
