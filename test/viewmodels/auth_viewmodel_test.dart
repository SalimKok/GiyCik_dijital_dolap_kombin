import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gircik/features/auth/repository/auth_repository.dart';
import 'package:gircik/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:gircik/core/services/notification_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockNotificationService mockNotificationService;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockNotificationService = MockNotificationService();
    
    SharedPreferences.setMockInitialValues({});
    
    when(() => mockNotificationService.initialize()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthViewModel Tests', () {
    test('initial state is unauthenticated if no saved login', () async {
      // Read the provider to initialize it
      container.read(authViewModelProvider);
      await Future.delayed(Duration.zero);
      
      expect(container.read(authViewModelProvider).status, AuthStatus.unauthenticated);
      expect(container.read(authViewModelProvider).hasSeenWelcome, isFalse);
    });

    test('login with rememberMe=false saves session but no remember flag', () async {
      when(() => mockAuthRepository.login('test@test.com', 'password123'))
          .thenAnswer((_) async => 'fake_token');
          
      final viewModel = container.read(authViewModelProvider.notifier);
      final success = await viewModel.login('test@test.com', 'password123', false);
      
      expect(success, isTrue);
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.isLoading, isFalse);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isLoggedIn'), isNull); // Removed because rememberMe=false
      expect(prefs.getBool('login_remember_me'), isFalse);
      
      verify(() => mockAuthRepository.login('test@test.com', 'password123')).called(1);
    });
    
    test('login with rememberMe=true saves session and flag', () async {
      when(() => mockAuthRepository.login('test@test.com', 'password123'))
          .thenAnswer((_) async => 'fake_token');
          
      final viewModel = container.read(authViewModelProvider.notifier);
      final success = await viewModel.login('test@test.com', 'password123', true);
      
      expect(success, isTrue);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isLoggedIn'), isTrue); 
      expect(prefs.getBool('login_remember_me'), isTrue);
    });

    test('login failure updates error state', () async {
      when(() => mockAuthRepository.login('test@test.com', 'wrong'))
          .thenThrow(Exception('Yanlış şifre'));
          
      // Init() methodunun bitmesi için bekle
      container.read(authViewModelProvider);
      await Future.delayed(Duration.zero);
          
      final viewModel = container.read(authViewModelProvider.notifier);
      final success = await viewModel.login('test@test.com', 'wrong', true);
      
      expect(success, isFalse);
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.error, 'Yanlış şifre');
    });

    test('logout clears session and flags', () async {
      SharedPreferences.setMockInitialValues({
        'isLoggedIn': true,
        'login_remember_me': true,
      });
      
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.logout();
      
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isLoggedIn'), isNull); 
      expect(prefs.getBool('login_remember_me'), isNull);
      
      verify(() => mockAuthRepository.logout()).called(1);
    });
  });
}
