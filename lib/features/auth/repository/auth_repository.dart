import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/core/network/api_client.dart';
import 'package:gircik/data/models/user.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<String> login(String email, String password) async {
    try {
      final response = await _apiClient.client.post(
        '/auth/login',
        data: FormData.fromMap({
          'username': email, // OAuth2PasswordRequestForm expects username
          'password': password,
        }),
      );
      
      final token = response.data['access_token'] as String;
      await _apiClient.saveToken(token);
      return token;
    } catch (e) {
      throw Exception('Giriş başarısız: \${_handleError(e)}');
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _apiClient.client.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Kayıt başarısız: \${_handleError(e)}');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.client.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Kullanıcı bilgileri alınamadı: \${_handleError(e)}');
    }
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
  }

  Future<User> updateProfile({String? name, String? email, String? password}) async {
    try {
      final response = await _apiClient.client.put(
        '/auth/me',
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (password != null) 'password': password,
        },
      );
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Profil güncellenemedi: ${_handleError(e)}');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _apiClient.client.delete('/auth/me');
      await logout();
    } catch (e) {
      throw Exception('Hesap silinemedi: ${_handleError(e)}');
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data['detail'] != null) {
        return error.response!.data['detail'].toString();
      }
      return error.message ?? 'Bilinmeyen bir hata oluştu';
    }
    return error.toString();
  }
}

final authRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

