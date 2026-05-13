import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost or 127.0.0.1 for iOS simulator / web / windows
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8080/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    } else {
      return 'http://127.0.0.1:8080/api';
    }
  }
  
  // Storage Keys
  static const String tokenKey = 'jwt_token';
}
