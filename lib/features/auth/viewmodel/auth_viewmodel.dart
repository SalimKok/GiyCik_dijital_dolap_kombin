import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';
import 'package:gircik/core/services/notification_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final bool hasSeenWelcome;
  final bool hasSeenSplash;
  final bool isLoading;
  final String? error;

  AuthState({
    this.status = AuthStatus.initial,
    this.hasSeenWelcome = false,
    this.hasSeenSplash = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? hasSeenWelcome,
    bool? hasSeenSplash,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
      hasSeenSplash: hasSeenSplash ?? this.hasSeenSplash,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthViewModel extends Notifier<AuthState> {
  static const String _keyLoggedIn    = 'isLoggedIn';
  static const String _keyRememberMe  = 'login_remember_me';
  static const String _keySeenWelcome = 'seen_welcome';

  @override
  AuthState build() {
    _init();
    return AuthState();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final bool rememberMe  = prefs.getBool(_keyRememberMe)  ?? false;
    final bool loggedIn    = prefs.getBool(_keyLoggedIn)    ?? false;
    final bool seenWelcome = prefs.getBool(_keySeenWelcome) ?? false;

    // Otomatik giriş yalnızca "Beni Hatırla" işaretliyse yapılır
    final bool autoLogin = rememberMe && loggedIn;

    state = AuthState(
      status: autoLogin ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      hasSeenWelcome: seenWelcome,
    );

    if (autoLogin) {
      try {
        await ref.read(notificationServiceProvider).initialize();
      } catch (e) {
        print("Firebase notification initialization skipped: $e");
      }
    }
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
    state = state.copyWith(status: value ? AuthStatus.authenticated : AuthStatus.unauthenticated);
  }

  Future<void> setSeenWelcome(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeenWelcome, value);
    state = state.copyWith(hasSeenWelcome: value);
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authRepositoryProvider).login(email, password);

      final prefs = await SharedPreferences.getInstance();
      // "Beni Hatırla" seçiliyse kalıcı oturum kaydet; değilse sadece flag'i false bırak
      await prefs.setBool(_keyRememberMe, rememberMe);
      if (rememberMe) {
        await prefs.setBool(_keyLoggedIn, true);
      } else {
        // Bir önceki oturumdan kalan kaydı temizle
        await prefs.remove(_keyLoggedIn);
      }

      // Kullanıcı adını hemen çekip cache'le (splash ekranında göstermek için)
      try {
        final user = await ref.read(authRepositoryProvider).getCurrentUser();
        await prefs.setString('cached_user_name', user.name);
      } catch (_) {
        // Cache başarısız olursa sorun değil, home_viewmodel zaten tekrar deneyecek
      }

      try {
        await ref.read(notificationServiceProvider).initialize();
      } catch (e) {
        print("Firebase notification initialization skipped: $e");
      }

      state = state.copyWith(isLoading: false, status: AuthStatus.authenticated);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authRepositoryProvider).register(name, email, password);
      // Kayıt olunca "Beni Hatırla" aktif say ve kalıcı kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyRememberMe, true);
      await prefs.setBool(_keyLoggedIn, true);

      // Kullanıcı adını cache'le (splash ekranında hemen göstermek için)
      await prefs.setString('cached_user_name', name);

      try {
        await ref.read(notificationServiceProvider).initialize();
      } catch (e) {
        print("Firebase notification initialization skipped: $e");
      }

      state = state.copyWith(isLoading: false, status: AuthStatus.authenticated);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> resetPassword(String email, String code, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authRepositoryProvider).resetPassword(email, code, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    final prefs = await SharedPreferences.getInstance();
    // Çıkış yapınca hem oturumu hem de "Beni Hatırla" flag'ini ve cache'i temizle
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyRememberMe);
    await prefs.remove('cached_user_name');
    state = state.copyWith(status: AuthStatus.unauthenticated, hasSeenSplash: false);
  }

  void setSeenSplash(bool value) {
    state = state.copyWith(hasSeenSplash: value);
  }

  Future<void> deleteAccount() async {
    await ref.read(authRepositoryProvider).deleteAccount();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyRememberMe);
    await prefs.remove('cached_user_name');
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});

