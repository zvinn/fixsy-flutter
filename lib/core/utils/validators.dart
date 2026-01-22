import '../error/exceptions.dart';

/// Input Validators
/// Provides validation functions for all input fields
class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  // Phone validation (Saudi format)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    // Remove spaces and special chars
    final phone = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Saudi phone: 05xxxxxxxx or +9665xxxxxxxx
    final phoneRegex = RegExp(r'^(05|009665|\+9665)\d{8}$');

    if (!phoneRegex.hasMatch(phone)) {
      return 'رقم الهاتف غير صحيح (مثال: 0512345678)';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value, {String fieldName = 'الاسم'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }

    if (value.trim().length < 2) {
      return '$fieldName يجب أن يكون حرفين على الأقل';
    }

    if (value.trim().length > 50) {
      return '$fieldName طويل جداً';
    }

    // Only letters, spaces, and Arabic characters
    final nameRegex = RegExp(r'^[\u0621-\u064A\s\a-zA-Z]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'الاسم يجب أن يحتوي على حروف فقط';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (value.length > 128) {
      return 'كلمة المرور طويلة جداً';
    }

    // Must contain at least one letter and one number
    if (!value.contains(RegExp(r'[A-Za-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف واحد على الأقل';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'العنوان مطلوب';
    }

    if (value.trim().length < 10) {
      return 'العنوان قصير جداً';
    }

    if (value.trim().length > 200) {
      return 'العنوان طويل جداً';
    }

    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'السعر مطلوب';
    }

    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'السعر غير صحيح';
    }

    if (price < 0) {
      return 'السعر يجب أن يكون موجباً';
    }

    if (price > 100000) {
      return 'السعر كبير جداً';
    }

    return null;
  }

  // Rating validation
  static String? validateRating(double? value) {
    if (value == null || value == 0) {
      return 'يرجى اختيار التقييم';
    }

    if (value < 0 || value > 5) {
      return 'التقييم يجب أن يكون بين 0 و 5';
    }

    return null;
  }

  // Comment validation
  static String? validateComment(String? value, {bool required = false}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'التعليق مطلوب';
    }

    if (value != null && value.trim().length > 500) {
      return 'التعليق طويل جداً (الحد الأقصى 500 حرف)';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  // Length validation
  static String? validateLength(
    String? value,
    int min,
    int max,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }

    if (value.length < min) {
      return '$fieldName قصير جداً (الحد الأدنى $min أحرف)';
    }

    if (value.length > max) {
      return '$fieldName طويل جداً (الحد الأقصى $max حرف)';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرابط مطلوب';
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'الرابط غير صحيح';
      }
    } catch (e) {
      return 'الرابط غير صحيح';
    }

    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value, {DateTime? minDate}) {
    if (value == null) {
      return 'التاريخ مطلوب';
    }

    if (minDate != null && value.isBefore(minDate)) {
      return 'التاريخ يجب أن يكون بعد ${minDate.day}/${minDate.month}/${minDate.year}';
    }

    return null;
  }

  // Future date validation
  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return 'التاريخ مطلوب';
    }

    final now = DateTime.now();
    if (value.isBefore(now)) {
      return 'يجب اختيار تاريخ في المستقبل';
    }

    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'الرقم مطلوب';
    }

    final number = int.tryParse(value.trim());
    if (number == null) {
      return 'الرقم غير صحيح';
    }

    if (min != null && number < min) {
      return 'الرقم يجب أن يكون $min على الأقل';
    }

    if (max != null && number > max) {
      return 'الرقم يجب أن يكون $max كحد أقصى';
    }

    return null;
  }
}
