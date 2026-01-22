/// Security Utilities
/// Provides security functions for input sanitization and validation
class SecurityUtils {
  /// Sanitize string input
  /// Remove dangerous characters and scripts
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    String sanitized = input;

    // Remove HTML tags
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove script tags
    sanitized = sanitized.replaceAll(RegExp(r'<script.*?</script>',
        caseSensitive: false, multiLine: true), '');

    // Remove SQL injection attempts
    sanitized = sanitized.replaceAll(RegExp(r"('|(--)|;|\/\*|\*\/)", caseSensitive: false), '');

    // Remove XSS attempts
    sanitized = sanitized.replaceAll(RegExp(r'javascript:', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');

    // Trim and normalize whitespace
    sanitized = sanitized.trim();
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    return sanitized;
  }

  /// Sanitize email
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Sanitize phone number
  static String sanitizePhone(String phone) {
    // Remove all non-digit and non-plus characters
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Check if string contains SQL injection attempts
  static bool containsSqlInjection(String input) {
    final sqlPatterns = [
      r"('|(--)|;|\/\*|\*\/)",
      r'(\bOR\b|\bAND\b).*=',
      r'\bDROP\b|\bDELETE\b|\bINSERT\b|\bUPDATE\b',
      r'\bUNION\b|\bSELECT\b',
    ];

    for (final pattern in sqlPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }

    return false;
  }

  /// Check if string contains XSS attempts
  static bool containsXss(String input) {
    final xssPatterns = [
      r'<script',
      r'javascript:',
      r'on\w+\s*=',
      r'<iframe',
      r'<object',
      r'<embed',
    ];

    for (final pattern in xssPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }

    return false;
  }

  /// Validate file extension
  static bool isAllowedFileExtension(String filename, List<String> allowedExtensions) {
    final extension = filename.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Check file size
  static bool isFileSizeValid(int fileSize, {int maxSizeMB = 10}) {
    final maxBytes = maxSizeMB * 1024 * 1024;
    return fileSize <= maxBytes;
  }

  /// Generate safe filename
  static String generateSafeFilename(String filename) {
    // Remove path separators
    String safe = filename.replaceAll(RegExp(r'[/\\]'), '_');

    // Remove special characters except dots and underscores
    safe = safe.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    // Limit length
    if (safe.length > 100) {
      final extension = safe.split('.').last;
      safe = '${safe.substring(0, 95)}.$extension';
    }

    return safe;
  }

  /// Allowed image extensions
  static const allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

  /// Allowed document extensions
  static const allowedDocExtensions = ['pdf', 'doc', 'docx', 'txt'];

  /// Max image size (10MB)
  static const maxImageSizeMB = 10;

  /// Max document size (20MB)
  static const maxDocSizeMB = 20;

  /// Rate limiting check (simple in-memory)
  static final Map<String, List<DateTime>> _rateLimitMap = {};

  /// Check if action is rate limited
  static bool isRateLimited(
    String key, {
    int maxAttempts = 5,
    Duration window = const Duration(minutes: 1),
  }) {
    final now = DateTime.now();

    // Get attempts for this key
    final attempts = _rateLimitMap[key] ?? [];

    // Remove old attempts outside the window
    attempts.removeWhere((time) => now.difference(time) > window);

    // Check if rate limited
    if (attempts.length >= maxAttempts) {
      return true;
    }

    // Add current attempt
    attempts.add(now);
    _rateLimitMap[key] = attempts;

    return false;
  }

  /// Clear rate limit for a key
  static void clearRateLimit(String key) {
    _rateLimitMap.remove(key);
  }

  /// Mask sensitive data for logging
  static String maskEmail(String email) {
    if (email.isEmpty) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '**@$domain';
    }

    return '${username.substring(0, 2)}***@$domain';
  }

  /// Mask phone number
  static String maskPhone(String phone) {
    if (phone.length < 4) return '****';

    return '****${phone.substring(phone.length - 4)}';
  }

  /// Mask credit card
  static String maskCreditCard(String card) {
    if (card.length < 4) return '****';

    return '**** **** **** ${card.substring(card.length - 4)}';
  }
}
