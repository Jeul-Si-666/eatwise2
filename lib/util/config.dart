import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // ============================================
  // SETTING: Ganti ini sesuai device yang dipakai
  // ============================================
  static const bool usePhysicalDevice = true; // true = HP Fisik, false = Emulator/Simulator
  
  // IP Laptop kamu (untuk HP fisik)
  static const String laptopIP = '192.168.100.167';
  
  // ============================================
  // BASE URL (Otomatis sesuai device)
  // ============================================
  static String get baseUrl {
    // Kalau pakai HP fisik
    if (usePhysicalDevice) {
      return 'http://$laptopIP/eatwise2/eatwise2';  // ← INI YANG DIGANTI
    }
    
    // Kalau Web (Chrome)
    if (kIsWeb) {
      return 'http://localhost/eatwise2/eatwise2';
    }
    
    // Kalau Android Emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2/eatwise2/eatwise2';
    }
    
    // Kalau iOS Simulator
    if (Platform.isIOS) {
      return 'http://localhost/eatwise2/eatwise2';
    }
    
    // Default (fallback)
    return 'http://localhost/eatwise2/eatwise2';
  }
}