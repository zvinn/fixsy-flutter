import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/core/utils/validators.dart';

void main() {
  group('Email Validation', () {
    test('returns null for valid email', () {
      expect(Validators.validateEmail('test@example.com'), null);
      expect(Validators.validateEmail('user.name@domain.co.uk'), null);
      expect(Validators.validateEmail('test123@test.org'), null);
    });

    test('returns error for empty email', () {
      expect(
        Validators.validateEmail(''),
        'البريد الإلكتروني مطلوب',
      );
      expect(
        Validators.validateEmail(null),
        'البريد الإلكتروني مطلوب',
      );
    });

    test('returns error for invalid email format', () {
      expect(
        Validators.validateEmail('invalid'),
        'البريد الإلكتروني غير صحيح',
      );
      expect(
        Validators.validateEmail('test@'),
        'البريد الإلكتروني غير صحيح',
      );
      expect(
        Validators.validateEmail('@example.com'),
        'البريد الإلكتروني غير صحيح',
      );
      expect(
        Validators.validateEmail('test@.com'),
        'البريد الإلكتروني غير صحيح',
      );
    });
  });

  group('Phone Validation', () {
    test('returns null for valid Saudi phone', () {
      expect(Validators.validatePhone('0512345678'), null);
      expect(Validators.validatePhone('+966512345678'), null);
      expect(Validators.validatePhone('00966512345678'), null);
    });

    test('returns error for empty phone', () {
      expect(
        Validators.validatePhone(''),
        'رقم الهاتف مطلوب',
      );
      expect(
        Validators.validatePhone(null),
        'رقم الهاتف مطلوب',
      );
    });

    test('returns error for invalid phone format', () {
      expect(
        Validators.validatePhone('123'),
        contains('رقم الهاتف غير صحيح'),
      );
      expect(
        Validators.validatePhone('0612345678'), // Wrong prefix
        contains('رقم الهاتف غير صحيح'),
      );
    });
  });

  group('Name Validation', () {
    test('returns null for valid name', () {
      expect(Validators.validateName('أحمد'), null);
      expect(Validators.validateName('Ahmed'), null);
      expect(Validators.validateName('محمد علي'), null);
    });

    test('returns error for empty name', () {
      expect(
        Validators.validateName(''),
        'الاسم مطلوب',
      );
      expect(
        Validators.validateName(null),
        'الاسم مطلوب',
      );
    });

    test('returns error for too short name', () {
      expect(
        Validators.validateName('A'),
        'الاسم يجب أن يكون حرفين على الأقل',
      );
    });

    test('returns error for too long name', () {
      final longName = 'A' * 51;
      expect(
        Validators.validateName(longName),
        'الاسم طويل جداً',
      );
    });

    test('returns error for invalid characters', () {
      expect(
        Validators.validateName('Test123'),
        'الاسم يجب أن يحتوي على حروف فقط',
      );
      expect(
        Validators.validateName('Test@#'),
        'الاسم يجب أن يحتوي على حروف فقط',
      );
    });
  });

  group('Password Validation', () {
    test('returns null for valid password', () {
      expect(Validators.validatePassword('Test1234'), null);
      expect(Validators.validatePassword('Password123'), null);
      expect(Validators.validatePassword('MyPass99'), null);
    });

    test('returns error for empty password', () {
      expect(
        Validators.validatePassword(''),
        'كلمة المرور مطلوبة',
      );
      expect(
        Validators.validatePassword(null),
        'كلمة المرور مطلوبة',
      );
    });

    test('returns error for too short password', () {
      expect(
        Validators.validatePassword('Test1'),
        'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
      );
    });

    test('returns error for password without letter', () {
      expect(
        Validators.validatePassword('12345678'),
        'كلمة المرور يجب أن تحتوي على حرف واحد على الأقل',
      );
    });

    test('returns error for password without number', () {
      expect(
        Validators.validatePassword('TestPassword'),
        'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل',
      );
    });
  });

  group('Price Validation', () {
    test('returns null for valid price', () {
      expect(Validators.validatePrice('100'), null);
      expect(Validators.validatePrice('99.99'), null);
      expect(Validators.validatePrice('0'), null);
    });

    test('returns error for empty price', () {
      expect(
        Validators.validatePrice(''),
        'السعر مطلوب',
      );
      expect(
        Validators.validatePrice(null),
        'السعر مطلوب',
      );
    });

    test('returns error for invalid price', () {
      expect(
        Validators.validatePrice('abc'),
        'السعر غير صحيح',
      );
    });

    test('returns error for negative price', () {
      expect(
        Validators.validatePrice('-10'),
        'السعر يجب أن يكون موجباً',
      );
    });

    test('returns error for too large price', () {
      expect(
        Validators.validatePrice('100001'),
        'السعر كبير جداً',
      );
    });
  });

  group('Rating Validation', () {
    test('returns null for valid rating', () {
      expect(Validators.validateRating(1.0), null);
      expect(Validators.validateRating(3.5), null);
      expect(Validators.validateRating(5.0), null);
    });

    test('returns error for zero rating', () {
      expect(
        Validators.validateRating(0.0),
        'يرجى اختيار التقييم',
      );
      expect(
        Validators.validateRating(null),
        'يرجى اختيار التقييم',
      );
    });

    test('returns error for out of range rating', () {
      expect(
        Validators.validateRating(-1.0),
        'التقييم يجب أن يكون بين 0 و 5',
      );
      expect(
        Validators.validateRating(6.0),
        'التقييم يجب أن يكون بين 0 و 5',
      );
    });
  });
}
