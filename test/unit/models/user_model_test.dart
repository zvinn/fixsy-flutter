import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/data/models/user.dart';
import 'package:fixsy_flutter/data/services/auth_service.dart';

void main() {
  group('User Model Unit Tests', () {
    test('should instantiate user correctly with phone', () {
      final user = User(
        id: 'u1',
        email: 'user@test.com',
        displayName: 'Test User',
        role: 'client',
        createdAt: DateTime(2026, 1, 1),
        phone: '0512345678',
      );

      expect(user.id, 'u1');
      expect(user.email, 'user@test.com');
      expect(user.displayName, 'Test User');
      expect(user.phone, '0512345678');
      expect(user.phoneNumber, '0512345678');
      expect(user.isClient, isTrue);
      expect(user.isTechnician, isFalse);
      expect(user.isAdmin, isFalse);
    });

    test('should support phoneNumber parameter alias', () {
      final user = User(
        id: 'u2',
        email: 'tech@test.com',
        displayName: 'Tech User',
        role: 'technician',
        createdAt: DateTime(2026, 1, 1),
        phoneNumber: '0587654321',
      );

      expect(user.phone, '0587654321');
      expect(user.phoneNumber, '0587654321');
      expect(user.isTechnician, isTrue);
      expect(user.isClient, isFalse);
      expect(user.isAdmin, isFalse);
    });

    test('should correctly identify admin role', () {
      final user = User(
        id: 'admin_1',
        email: 'admin@fixsy.com',
        displayName: 'Admin User',
        role: 'admin',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(user.isAdmin, isTrue);
      expect(user.isTechnician, isFalse);
      expect(user.isClient, isFalse);
    });

    test('should serialize to and from JSON properly', () {
      final original = User(
        id: 'json_1',
        email: 'json@test.com',
        displayName: 'JSON User',
        photoURL: 'https://example.com/avatar.jpg',
        role: 'client',
        createdAt: DateTime(2026, 5, 20),
        phone: '0500000000',
      );

      final json = original.toJson();
      final restored = User.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.email, original.email);
      expect(restored.displayName, original.displayName);
      expect(restored.photoURL, original.photoURL);
      expect(restored.role, original.role);
      expect(restored.phone, original.phone);
      expect(restored.phoneNumber, original.phoneNumber);
    });

    test('copyWith should return updated user copy', () {
      final user = User(
        id: 'cp_1',
        email: 'old@test.com',
        displayName: 'Old Name',
        role: 'client',
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = user.copyWith(
        displayName: 'New Name',
        email: 'new@test.com',
      );

      expect(updated.displayName, 'New Name');
      expect(updated.email, 'new@test.com');
      expect(updated.id, user.id);
      expect(updated.role, user.role);
    });
  });

  group('AuthService Demo Credentials Tests', () {
    test('should contain valid demo users matching Fixy Web App', () {
      expect(AuthService.demoUsers.containsKey('client'), isTrue);
      expect(AuthService.demoUsers.containsKey('technician'), isTrue);
      expect(AuthService.demoUsers.containsKey('admin'), isTrue);

      final clientDemo = AuthService.demoUsers['client']!;
      expect(clientDemo.email, 'client.demo@fixsy.com');
      expect(clientDemo.isClient, isTrue);

      final techDemo = AuthService.demoUsers['technician']!;
      expect(techDemo.email, 'tech.demo@fixsy.com');
      expect(techDemo.isTechnician, isTrue);

      final adminDemo = AuthService.demoUsers['admin']!;
      expect(adminDemo.email, 'admin.demo@fixsy.com');
      expect(adminDemo.isAdmin, isTrue);
    });
  });
}
