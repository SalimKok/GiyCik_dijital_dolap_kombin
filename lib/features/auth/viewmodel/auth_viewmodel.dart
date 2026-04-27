import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final bool hasSeenWelcome;
  final bool isLoading;
  final String? error;

  AuthState({
    this.status = AuthStatus.initial,
    this.hasSeenWelcome = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? hasSeenWelcome,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthViewModel extends Notifier<AuthState> {
  static const String _keyLoggedIn = 'isLoggedIn';
  static const String _keySeenWelcome = 'seen_welcome';

  @override
  AuthState build() {
    _init();
    return AuthState();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final bool loggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    final bool seenWelcome = prefs.getBool(_keySeenWelcome) ?? false;

    state = AuthState(
      status: loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      hasSeenWelcome: seenWelcome,
    );
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
      await setLoggedIn(true);
      state = state.copyWith(isLoading: false);
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
      await setLoggedIn(true);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    await setLoggedIn(false);
  }

  Future<void> deleteAccount() async {
    await ref.read(authRepositoryProvider).deleteAccount();
    await setLoggedIn(false);
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});
