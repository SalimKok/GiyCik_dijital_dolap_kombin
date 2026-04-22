import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gircik/core/constants/api_constants.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          contentType: 'application/json',
        )),
        _storage = const FlutterSecureStorage() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add JWT token to headers if available
          final token = await _storage.read(key: ApiConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized globally if needed
          if (e.response?.statusCode == 401) {
            // Optional: trigger logout or token refresh
            await _storage.delete(key: ApiConstants.tokenKey);
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;
  
  // Helper to store token
  Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.tokenKey, value: token);
  }

  // Helper to clear token
  Future<void> clearToken() async {
    await _storage.delete(key: ApiConstants.tokenKey);
  }
}

final apiClientProvider = Provider((ref) {
  return ApiClient();
});

