import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class ApiConstants {
  // ──────────────────────────────────────────────
  // Set this to your deployed backend URL before building a release.
  // Example: https://giycik-api.onrender.com/api
  // ──────────────────────────────────────────────
  static const String productionBaseUrl = 'https://giycik-api.onrender.com/api';

  /// Development base URL (auto-detected per platform)
  static String get _devBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8080/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    } else {
      return 'http://127.0.0.1:8080/api';
    }
  }

  /// Dynamic base URL: uses production URL in release builds,
  /// development URL otherwise.
  static String get baseUrl {
    if (kReleaseMode) {
      return productionBaseUrl;
    }
    return _devBaseUrl;
  }

  // Storage Keys
  static const String tokenKey = 'jwt_token';
}
