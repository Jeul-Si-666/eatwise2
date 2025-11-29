import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eatwise2/util/config.dart';
import 'package:eatwise2/services/api_helper.dart';

class ProfileService {
  // ============================================
  // GET USER PROFILE
  // ============================================
  static Future<Map<String, dynamic>?> getProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/profile.php?user_id=$userId'),
        headers: {"Content-Type": "application/json"},
      );

      print('Get Profile Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          // Parse dengan ApiHelper untuk handle String/Int conversion
          return ApiHelper.parseProfileData(jsonData['data']);
        }
      } else if (response.statusCode == 404) {
        // Profile belum ada
        print('Profile not found for user $userId');
        return null;
      }

      return null;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  // ============================================
  // CREATE USER PROFILE (First Time)
  // ============================================
  static Future<bool> createProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/profile.php'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(profileData),
      );

      print('Create Profile Response: ${response.body}');

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }

      return false;
    } catch (e) {
      print('Error creating profile: $e');
      return false;
    }
  }

  // ============================================
  // UPDATE USER PROFILE
  // ============================================
  static Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final request = http.Request(
        'PUT',
        Uri.parse('${AppConfig.baseUrl}/profile.php'),
      );
      
      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode(profileData);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update Profile Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }

      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // ============================================
  // SAVE PROFILE (Create atau Update otomatis)
  // ============================================
  static Future<bool> saveProfile(int userId, Map<String, dynamic> profileData) async {
    // Cek apakah profile sudah ada
    final existingProfile = await getProfile(userId);
    
    // Tambahkan user_id ke data
    profileData['user_id'] = userId;

    if (existingProfile == null) {
      // Profile belum ada, create new
      return await createProfile(profileData);
    } else {
      // Profile sudah ada, update
      return await updateProfile(profileData);
    }
  }

  // ============================================
  // HELPER: Convert TimeOfDay to String
  // ============================================
  static String timeOfDayToString(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
  }

  // ============================================
  // HELPER: Parse Time String to Map
  // ============================================
  static Map<String, int> parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return {
      'hour': int.parse(parts[0]),
      'minute': int.parse(parts[1]),
    };
  }

  static int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static DateTime? parseBirthDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  
}
