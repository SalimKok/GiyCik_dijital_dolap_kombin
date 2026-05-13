import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Canlı (Production) Sunucu Adresi
  static String get baseUrl {
    return 'https://giycik-api.onrender.com/api';
  }
  
  // Storage Keys
  static const String tokenKey = 'jwt_token';
}
