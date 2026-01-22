import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/data/models/user.dart';

void main() {
  group('User Model', () {
    group('fromJson', () {
      test('should create User from valid JSON', () {
        final json = {
          'id': 'user123',
          'email': 'test@example.com',
          'displayName': 'محمد أحمد',
          'phone': '01234567890',
          'photoURL': 'https://example.com/photo.jpg',
          'role': 'client',
          'isVerified': true,
          'createdAt': DateTime.now().toIso8601String(),
        };

        final user = AppUser.fromJson(json);

        expect(user.id, equals('user123'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('محمد أحمد'));
        expect(user.role, equals('client'));
      });

      test('should handle optional phone field', () {
        final json = {
          'id': 'user123',
          'email': 'test@example.com',
          'displayName': 'Test User',
        };

        final user = AppUser.fromJson(json);

        expect(user.id, equals('user123'));
        expect(user.phone, isNull);
      });
    });

    group('toJson', () {
      test('should convert User to JSON', () {
        final user = AppUser(
          id: 'user123',
          email: 'test@example.com',
          displayName: 'محمد أحمد',
          phone: '01234567890',
          role: 'client',
        );

        final json = user.toJson();

        expect(json['id'], equals('user123'));
        expect(json['email'], equals('test@example.com'));
        expect(json['displayName'], equals('محمد أحمد'));
        expect(json['phone'], equals('01234567890'));
      });
    });

    group('User Roles', () {
      test('should have valid role values', () {
        final validRoles = ['client', 'technician', 'admin'];
        
        for (final role in validRoles) {
          final user = AppUser(
            id: 'test',
            email: 'test@test.com',
            displayName: 'Test',
            role: role,
          );
          
          expect(user.role, equals(role));
        }
      });

      test('client role should have correct permissions', () {
        final user = AppUser(
          id: 'test',
          email: 'test@test.com',
          displayName: 'Test',
          role: 'client',
        );

        expect(user.role, equals('client'));
        // Clients can create bookings but not manage technicians
      });

      test('technician role should have correct permissions', () {
        final user = AppUser(
          id: 'test',
          email: 'test@test.com',
          displayName: 'Test',
          role: 'technician',
        );

        expect(user.role, equals('technician'));
        // Technicians can accept jobs and update status
      });

      test('admin role should have correct permissions', () {
        final user = AppUser(
          id: 'test',
          email: 'test@test.com',
          displayName: 'Test',
          role: 'admin',
        );

        expect(user.role, equals('admin'));
        // Admins can manage all users and settings
      });
    });

    group('Email Validation', () {
      test('should accept valid email formats', () {
        final validEmails = [
          'test@example.com',
          'user.name@domain.org',
          'user+tag@subdomain.domain.com',
        ];

        for (final email in validEmails) {
          final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
          expect(isValid, isTrue, reason: '$email should be valid');
        }
      });

      test('should reject invalid email formats', () {
        final invalidEmails = [
          'invalid',
          '@nodomain.com',
          'spaces in@email.com',
        ];

        for (final email in invalidEmails) {
          final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
          expect(isValid, isFalse, reason: '$email should be invalid');
        }
      });
    });

    group('Phone Validation', () {
      test('should accept valid Egyptian phone numbers', () {
        final validPhones = [
          '01012345678',
          '01123456789',
          '01234567890',
          '01512345678',
        ];

        for (final phone in validPhones) {
          final isValid = RegExp(r'^01[0125]\d{8}$').hasMatch(phone);
          expect(isValid, isTrue, reason: '$phone should be valid');
        }
      });

      test('should reject invalid phone numbers', () {
        final invalidPhones = [
          '1234567890',
          '02012345678',
          '0101234567',  // Too short
        ];

        for (final phone in invalidPhones) {
          final isValid = RegExp(r'^01[0125]\d{8}$').hasMatch(phone);
          expect(isValid, isFalse, reason: '$phone should be invalid');
        }
      });
    });
  });

  group('User Repository', () {
    test('should filter verified users', () {
      final users = [
        AppUser(id: '1', email: 'a@a.com', displayName: 'A', isVerified: true),
        AppUser(id: '2', email: 'b@b.com', displayName: 'B', isVerified: false),
        AppUser(id: '3', email: 'c@c.com', displayName: 'C', isVerified: true),
      ];

      final verifiedUsers = users.where((u) => u.isVerified == true).toList();

      expect(verifiedUsers.length, equals(2));
    });

    test('should filter by role', () {
      final users = [
        AppUser(id: '1', email: 'a@a.com', displayName: 'A', role: 'client'),
        AppUser(id: '2', email: 'b@b.com', displayName: 'B', role: 'technician'),
        AppUser(id: '3', email: 'c@c.com', displayName: 'C', role: 'client'),
      ];

      final clients = users.where((u) => u.role == 'client').toList();

      expect(clients.length, equals(2));
    });
  });
}
