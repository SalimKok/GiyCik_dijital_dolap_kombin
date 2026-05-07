import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gircik/features/auth/view/register_screen.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: RegisterScreen(),
        ),
      ),
    );
  }

  testWidgets('RegisterScreen renders fields and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Hesap oluştur'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Kayıt Ol'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3)); // Ad Soyad, Email, Password
  });

  testWidgets('Password visibility toggle changes obscureText', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Password field is the 3rd TextFormField (index 2)
    final passwordField = find.byType(TextFormField).at(2);
    
    // Check initial state (obscured)
    TextField textFieldWidget = tester.widget<TextField>(find.descendant(
      of: passwordField,
      matching: find.byType(TextField),
    ));
    expect(textFieldWidget.obscureText, isTrue);

    // Tap visibility icon
    final visibilityIcon = find.byIcon(Icons.visibility_off_outlined);
    await tester.tap(visibilityIcon);
    await tester.pump();

    // Check new state (visible)
    textFieldWidget = tester.widget<TextField>(find.descendant(
      of: passwordField,
      matching: find.byType(TextField),
    ));
    expect(textFieldWidget.obscureText, isFalse);
  });
  
  testWidgets('Shows validation error for short name', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    
    // Enter short name
    await tester.enterText(textFields.at(0), 'A');
    
    // Tap Register
    await tester.tap(find.widgetWithText(FilledButton, 'Kayıt Ol'));
    await tester.pump(); // Trigger validation

    expect(find.text('En az 2 karakter girin'), findsOneWidget);
  });
}
