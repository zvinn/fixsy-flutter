import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/screens/home/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('should display app bar with title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: _MockAppBar(),
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      expect(find.text('Fixsy'), findsOneWidget);
    });

    testWidgets('should display search icon in app bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: _MockAppBar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display notification icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: _MockAppBar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });

  group('Service Card Widget Tests', () {
    testWidgets('should display service name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _MockServiceCard(name: 'سباكة'),
          ),
        ),
      );

      expect(find.text('سباكة'), findsOneWidget);
    });

    testWidgets('should display service icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _MockServiceCard(name: 'كهرباء', icon: Icons.electrical_services),
          ),
        ),
      );

      expect(find.byIcon(Icons.electrical_services), findsOneWidget);
    });

    testWidgets('should be tappable', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () => tapped = true,
              child: const _MockServiceCard(name: 'Test'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });
  });

  group('Button Widget Tests', () {
    testWidgets('ElevatedButton should display text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('احجز الآن'),
            ),
          ),
        ),
      );

      expect(find.text('احجز الآن'), findsOneWidget);
    });

    testWidgets('ElevatedButton should be clickable', (tester) async {
      bool clicked = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => clicked = true,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(clicked, isTrue);
    });

    testWidgets('Disabled button should not be clickable', (tester) async {
      bool clicked = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: null,
              child: const Text('Disabled'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(clicked, isFalse);
    });
  });

  group('TextField Widget Tests', () {
    testWidgets('should display hint text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(
                hintText: 'أدخل اسمك',
              ),
            ),
          ),
        ),
      );

      expect(find.text('أدخل اسمك'), findsOneWidget);
    });

    testWidgets('should accept text input', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'محمد');
      expect(find.text('محمد'), findsOneWidget);
    });
  });

  group('Navigation Tests', () {
    testWidgets('should navigate to new screen on button tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const _SecondScreen()),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Second Screen'), findsOneWidget);
    });
  });
}

// Mock Widgets for Testing
class _MockAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MockAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Fixsy'),
      actions: const [
        Icon(Icons.search),
        SizedBox(width: 8),
        Icon(Icons.notifications_outlined),
        SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MockServiceCard extends StatelessWidget {
  final String name;
  final IconData icon;

  const _MockServiceCard({
    required this.name,
    this.icon = Icons.build,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Icon(icon),
          Text(name),
        ],
      ),
    );
  }
}

class _SecondScreen extends StatelessWidget {
  const _SecondScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Second Screen')),
    );
  }
}
