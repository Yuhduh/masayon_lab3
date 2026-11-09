import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:masayon_lab3/main.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(ElevatedButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> openApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(480, 960));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const LoginRegisterApp());
}

void main() {
  testWidgets('Shows app details and validates required fields', (
    tester,
  ) async {
    await openApp(tester);

    expect(find.text(appName), findsOneWidget);
    expect(find.text('$studentName\n$studentSection'), findsOneWidget);
    await tapButton(tester, 'Login');
    expect(find.text('Please enter your email.'), findsOneWidget);
    expect(find.text('Please enter your password.'), findsOneWidget);

    await tester.enterText(field('Email'), 'invalid-email');
    await tester.enterText(field('Password'), '1234567');
    await tapButton(tester, 'Login');
    expect(find.text('Please enter a valid email.'), findsOneWidget);
    expect(find.text('Use at least 8 characters.'), findsOneWidget);

    await tester.enterText(field('Email'), 'student@example.com');
    await tester.enterText(field('Password'), '12345678');
    await tapButton(tester, 'Login');
    expect(find.text('Please register an account first.'), findsOneWidget);
  });

  testWidgets('Registers with eight characters, logs in, and logs out', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('No account yet? Register'));
    await tester.pumpAndSettle();
    expect(find.text(appName), findsOneWidget);
    expect(find.text('$studentName\n$studentSection'), findsOneWidget);

    await tapButton(tester, 'Register');
    expect(find.text('Please enter your full name.'), findsOneWidget);
    expect(find.text('Please confirm your password.'), findsOneWidget);

    await tester.enterText(field('Full Name'), 'Test Student');
    await tester.enterText(field('Email'), 'student@example.com');
    await tester.enterText(field('Password'), '1234567');
    await tester.enterText(field('Confirm Password'), '1234567');
    await tapButton(tester, 'Register');
    expect(find.text('Use at least 8 characters.'), findsOneWidget);

    await tester.enterText(field('Password'), '12345678');
    await tapButton(tester, 'Register');
    expect(find.text('Passwords do not match.'), findsOneWidget);

    await tester.enterText(field('Confirm Password'), '12345678');
    await tapButton(tester, 'Register');
    expect(
      find.text('Registration successful! Please log in.'),
      findsOneWidget,
    );
    expect(field('Confirm Password'), findsNothing);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.enterText(field('Email'), 'student@example.com');
    await tester.enterText(field('Password'), 'wrongpass');
    await tapButton(tester, 'Login');
    expect(find.text('Incorrect email or password.'), findsOneWidget);

    await tester.enterText(field('Email'), ' STUDENT@example.com ');
    await tester.enterText(field('Password'), '12345678');
    await tapButton(tester, 'Login');
    expect(find.text('Welcome, Test Student!'), findsOneWidget);
    expect(find.text('student@example.com'), findsOneWidget);

    await tapButton(tester, 'Logout');
    expect(field('Email'), findsOneWidget);
    expect(field('Password'), findsOneWidget);
    expect(find.text('Welcome, Test Student!'), findsNothing);

    await tester.enterText(field('Email'), 'student@example.com');
    await tester.enterText(field('Password'), '12345678');
    await tapButton(tester, 'Login');
    expect(find.text('Welcome, Test Student!'), findsOneWidget);
  });
}
