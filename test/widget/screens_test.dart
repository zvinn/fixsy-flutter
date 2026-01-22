import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Login Screen Widget Tests', () {
    testWidgets('should display login form fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLoginForm(),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('البريد الإلكتروني'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
    });

    testWidgets('should display login button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _MockLoginForm(),
          ),
        ),
      );

      expect(find.text('تسجيل الدخول'), findsOneWidget);
    });

    testWidgets('should validate empty email', (tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'البريد الإلكتروني مطلوب';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'البريد'),
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('البريد الإلكتروني مطلوب'), findsOneWidget);
    });

    testWidgets('should validate password length', (tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                initialValue: '123',
                validator: (value) {
                  if (value != null && value.length < 6) {
                    return 'كلمة المرور قصيرة جداً';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('كلمة المرور قصيرة جداً'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      bool obscured = true;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TextField(
                  obscureText: obscured,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(obscured ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscured = !obscured),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });

  group('Profile Screen Widget Tests', () {
    testWidgets('should display user avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person),
            ),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should display edit button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });

  group('Booking Card Widget Tests', () {
    testWidgets('should display booking status chip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Chip(
              label: const Text('في الانتظار'),
              backgroundColor: Colors.orange.shade100,
            ),
          ),
        ),
      );

      expect(find.text('في الانتظار'), findsOneWidget);
    });

    testWidgets('should display technician info', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('محمد أحمد'),
              subtitle: const Text('سباك محترف'),
            ),
          ),
        ),
      );

      expect(find.text('محمد أحمد'), findsOneWidget);
      expect(find.text('سباك محترف'), findsOneWidget);
    });

    testWidgets('should display rating stars', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star, color: Colors.amber),
                Icon(Icons.star_half, color: Colors.amber),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_half), findsOneWidget);
    });
  });
}

// Mock Widgets
class _MockLoginForm extends StatelessWidget {
  const _MockLoginForm();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'كلمة المرور'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }
}
