import 'package:fixsy_flutter/data/models/user.dart';

/// Mock Data Factory for Tests
class MockData {
  // Mock Users
  static User createMockUser({
    String id = 'user_123',
    String email = 'test@example.com',
    String displayName = 'Test User',
    String? phoneNumber,
    String role = 'client',
  }) {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      role: role,
      createdAt: DateTime.now(),
    );
  }

  static User get mockClient => createMockUser(
        id: 'client_1',
        email: 'client@test.com',
        displayName: 'Ahmed Ali',
        phoneNumber: '0512345678',
      );

  static User get mockTechnician => createMockUser(
        id: 'tech_1',
        email: 'tech@test.com',
        displayName: 'Mohammed Tech',
        role: 'technician',
      );

  // Valid test inputs
  static const validEmail = 'test@example.com';
  static const validPhone = '0512345678';
  static const validPassword = 'Test1234';
  static const validName = 'أحمد علي';

  // Invalid test inputs
  static const invalidEmail = 'not-an-email';
  static const invalidPhone = '123';
  static const invalidPassword = 'weak';
  static const empty = '';
}
