import 'package:intl/intl.dart';

/// Date and Time Utilities
class DateUtils {
  /// Format date to Arabic
  static String formatDateArabic(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }

  /// Format time to Arabic
  static String formatTimeArabic(DateTime date) {
    return DateFormat('hh:mm a', 'ar').format(date);
  }

  /// Format date and time to Arabic
  static String formatDateTimeArabic(DateTime date) {
    return DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(date);
  }

  /// Get relative time (e.g., "منذ ساعتين")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDateArabic(date);
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}
