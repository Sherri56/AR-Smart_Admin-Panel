import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_web/main.dart';

void main() {
  testWidgets('Admin login screen test', (WidgetTester tester) async {
    // Build your admin app
    await tester.pumpWidget(const AdminApp()); // Changed from MyApp to AdminApp

    // Verify login screen appears
    expect(find.text('Admin Login'), findsOneWidget);
    expect(find.byType(TextFormField),
        findsNWidgets(2)); // Email and password fields
  });
}
