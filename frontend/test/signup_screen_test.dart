import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gps_tracker/auth/signup_screen.dart'; 

void main() {
  testWidgets('SignUpScreen UI test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));
    

    
    expect(find.widgetWithText(TextFormField, 'First Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Last Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Date of Birth'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Phone'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Confirm Password'), findsOneWidget);

    
    await tester.enterText(find.widgetWithText(TextFormField, 'First Name'), 'moni');
    await tester.enterText(find.widgetWithText(TextFormField, 'Last Name'), 'nisha');
    await tester.enterText(find.widgetWithText(TextFormField, 'Date of Birth'), '01/01/2000');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'monisha@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '7418569485');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'monisha');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'monisha');

    
    final registerButton = find.widgetWithText(ElevatedButton, 'Register');
    expect(registerButton, findsOneWidget);

  });

  testWidgets('TextFormField sizes are consistent', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

    final firstNameField = find.widgetWithText(TextFormField, 'First Name');
    final lastNameField = find.widgetWithText(TextFormField, 'Last Name');

    final firstSize = tester.getSize(firstNameField);
    final lastSize = tester.getSize(lastNameField);

    expect(firstSize.width, greaterThan(200)); 
    expect(firstSize.height, greaterThan(50)); 

    expect(lastSize.width, equals(firstSize.width));  
    expect(lastSize.height, equals(firstSize.height));
  });
}
