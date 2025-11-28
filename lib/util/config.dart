  import 'dart:io' show Platform;
  import 'package:flutter/foundation.dart' show kIsWeb;
  class AppConfig {

    // static const String API_ENDPOINT = "http://10.0.2.2/eatwise2/";
    static String get baseUrl {
      if (kIsWeb) {
        // Untuk Web (Chrome)
        return 'http://localhost/EatWise2.0'; 
      }
      if (Platform.isAndroid) {
        // Untuk Android Emulator
        return 'http://10.0.2.2/EatWise2.0';
      }
      if (Platform.isIOS) {
        // Untuk iOS Simulator
        return 'http://localhost/EatWise2.0';
      }
      // Default
      return 'http://localhost/EatWise2.0';
    }

  }