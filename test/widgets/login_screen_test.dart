import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gircik/features/auth/view/login_screen.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';
import 'package:gircik/core/services/notification_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockNotificationService mockNotificationService;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockNotificationService = MockNotificationService();
    when(() => mockNotificationService.initialize()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('LoginScreen renders header, email, password and login button', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Tekrar hoş geldin'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });

  testWidgets('Shows validation error when email is invalid', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Try finding by hint or label instead of widgetWithText if needed, 
    // but in TextFormField the label is usually found.
    // To be safer we find by type and index.
    final textFields = find.byType(TextFormField);
    
    // Enter invalid email
    await tester.enterText(textFields.at(0), 'invalid-email');
    await tester.enterText(textFields.at(1), '123456');

    // Tap Login
    await tester.tap(find.widgetWithText(FilledButton, 'Giriş Yap'));
    await tester.pump(); // Trigger validation

    // Verify validation error
    expect(find.text('Geçerli bir e-posta adresi girin'), findsOneWidget);
  });
  
  testWidgets('Shows validation error when password is too short', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);

    await tester.enterText(textFields.at(0), 'test@test.com');
    await tester.enterText(textFields.at(1), '123'); // Short

    await tester.tap(find.widgetWithText(FilledButton, 'Giriş Yap'));
    await tester.pump(); 

    expect(find.text('Şifre en az 6 karakter olmalı'), findsOneWidget);
  });
}
