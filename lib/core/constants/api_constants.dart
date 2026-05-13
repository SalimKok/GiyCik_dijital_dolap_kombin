import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Canlı (Production) Sunucu Adresi
  static String get baseUrl {
    return 'https://giycikdijitaldolapkombin-production.up.railway.app/api';
  }
  
  // Storage Keys
  static const String tokenKey = 'jwt_token';
}
