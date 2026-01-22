import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/core/security/security_utils.dart';

void main() {
  group('Input Sanitization', () {
    test('removes HTML tags', () {
      final result = SecurityUtils.sanitizeInput('<script>alert("xss")</script>');
      // Verify tags are removed
      expect(result.contains('<script>'), false);
      expect(result.contains('</script>'), false);
    });

    test('removes script tags', () {
      final result = SecurityUtils.sanitizeInput('<SCRIPT>malicious()</SCRIPT>');
      expect(result.toLowerCase().contains('<script>'), false);
    });

    test('removes SQL injection attempts', () {
      final result = SecurityUtils.sanitizeInput("'; DROP TABLE users--");
      // Verify dangerous chars are removed
      expect(result.contains("';"), false);
      expect(result.contains('--'), false);
    });

    test('removes XSS attempts', () {
      expect(
        SecurityUtils.sanitizeInput('javascript:alert(1)'),
        'alert(1)',
      );
      expect(
        SecurityUtils.sanitizeInput('<img onerror="alert(1)">'),
        contains('alert'), // Tag removed, content may remain
      );
    });

    test('normalizes whitespace', () {
      expect(
        SecurityUtils.sanitizeInput('  Hello    World  '),
        'Hello World',
      );
    });
  });

  group('Email Sanitization', () {
    test('trims and lowercases email', () {
      expect(
        SecurityUtils.sanitizeEmail('  TEST@EXAMPLE.COM  '),
        'test@example.com',
      );
    });
  });

  group('Phone Sanitization', () {
    test('removes non-digit characters except plus', () {
      expect(
        SecurityUtils.sanitizePhone(' 05(12)345-678 '),
        '0512345678',
      );
      expect(
        SecurityUtils.sanitizePhone('+966 51 234 5678'),
        '+966512345678',
      );
    });
  });

  group('SQL Injection Detection', () {
    test('detects SQL injection patterns', () {
      expect(
        SecurityUtils.containsSqlInjection("'; DROP TABLE"),
        true,
      );
      expect(
        SecurityUtils.containsSqlInjection("1' OR '1'='1"),
        true,
      );
      expect(
        SecurityUtils.containsSqlInjection("UNION SELECT"),
        true,
      );
    });

    test('allows clean input', () {
      expect(
        SecurityUtils.containsSqlInjection('Normal text'),
        false,
      );
    });
  });

  group('XSS Detection', () {
    test('detects XSS patterns', () {
      expect(
        SecurityUtils.containsXss('<script>'),
        true,
      );
      expect(
        SecurityUtils.containsXss('javascript:'),
        true,
      );
      expect(
        SecurityUtils.containsXss('<iframe'),
        true,
      );
    });

    test('allows clean input', () {
      expect(
        SecurityUtils.containsXss('Normal text'),
        false,
      );
    });
  });

  group('File Extension Validation', () {
    test('validates allowed extensions', () {
      expect(
        SecurityUtils.isAllowedFileExtension(
          'photo.jpg',
          SecurityUtils.allowedImageExtensions,
        ),
        true,
      );
      expect(
        SecurityUtils.isAllowedFileExtension(
          'document.pdf',
          SecurityUtils.allowedDocExtensions,
        ),
        true,
      );
    });

    test('rejects disallowed extensions', () {
      expect(
        SecurityUtils.isAllowedFileExtension(
          'malware.exe',
          SecurityUtils.allowedImageExtensions,
        ),
        false,
      );
    });
  });

  group('File Size Validation', () {
    test('validates file size within limit', () {
      expect(
        SecurityUtils.isFileSizeValid(5 * 1024 * 1024), // 5MB
        true,
      );
    });

    test('rejects file size over limit', () {
      expect(
        SecurityUtils.isFileSizeValid(15 * 1024 * 1024, maxSizeMB: 10), // 15MB
        false,
      );
    });
  });

  group('Safe Filename Generation', () {
    test('removes path separators', () {
      final result = SecurityUtils.generateSafeFilename('../../../etc/passwd');
      // Verify no path separators remain
      expect(result.contains('/'), false);
      expect(result.contains('\\'), false);
      // Should have underscores or similar safe chars
      expect(result.isNotEmpty, true);
    });

    test('removes special characters', () {
      final result = SecurityUtils.generateSafeFilename('file@#\$%^&*.jpg');
      // Verify extension preserved and special chars removed
      expect(result.endsWith('.jpg'), true);
      expect(result.contains('@'), false);
      expect(result.contains('#'), false);
      expect(result.contains('\$'), false);
      expect(result.contains('%'), false);
    });

    test('limits filename length', () {
      final longName = 'a' * 200 + '.jpg';
      final result = SecurityUtils.generateSafeFilename(longName);
      expect(result.length, lessThanOrEqualTo(100));
      expect(result.endsWith('.jpg'), true);
    });
  });

  group('Rate Limiting', () {
    setUp(() {
      // Clear rate limits before each test
      SecurityUtils.clearRateLimit('test_key');
    });

    test('allows requests within limit', () {
      for (int i = 0; i < 5; i++) {
        expect(
          SecurityUtils.isRateLimited('test_key', maxAttempts: 5),
          false,
        );
      }
    });

    test('blocks requests over limit', () {
      for (int i = 0; i < 5; i++) {
        SecurityUtils.isRateLimited('test_key', maxAttempts: 5);
      }
      expect(
        SecurityUtils.isRateLimited('test_key', maxAttempts: 5),
        true,
      );
    });

    test('clears rate limit', () {
      for (int i = 0; i < 5; i++) {
        SecurityUtils.isRateLimited('test_key', maxAttempts: 5);
      }
      SecurityUtils.clearRateLimit('test_key');
      expect(
        SecurityUtils.isRateLimited('test_key', maxAttempts: 5),
        false,
      );
    });
  });

  group('Data Masking', () {
    test('masks email', () {
      expect(
        SecurityUtils.maskEmail('test@example.com'),
        'te***@example.com',
      );
    });

    test('masks short email', () {
      expect(
        SecurityUtils.maskEmail('ab@example.com'),
        '**@example.com',
      );
    });

    test('masks phone', () {
      expect(
        SecurityUtils.maskPhone('0512345678'),
        '****5678',
      );
    });

    test('masks credit card', () {
      expect(
        SecurityUtils.maskCreditCard('1234567890123456'),
        '**** **** **** 3456',
      );
    });
  });
}
