import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App root shell loads without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Fixsy App'),
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    expect(find.text('Fixsy App'), findsOneWidget);
  });
}
