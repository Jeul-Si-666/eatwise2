import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eatwise2/util/config.dart';
import 'package:eatwise2/services/api_helper.dart';

class HistoryService {
  // ============================================
  // GET TODAY'S HISTORY
  // ============================================
  static Future<Map<String, dynamic>?> getTodayHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/history.php?today=1&user_id=$userId'),
        headers: {"Content-Type": "application/json"},
      );

      print('Get Today History Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          // Parse setiap history item dengan ApiHelper
          if (jsonData['data'] != null) {
            final historyItems = (jsonData['data'] as List)
                .map((item) => ApiHelper.parseHistoryData(item))
                .toList();
            
            jsonData['data'] = historyItems;
          }
          
          // Parse summary dengan safe parsing
          if (jsonData['summary'] != null) {
            jsonData['summary'] = {
              'total_items': ApiHelper.parseIntWithDefault(jsonData['summary']['total_items'], 0),
              'total_kalori': ApiHelper.parseIntWithDefault(jsonData['summary']['total_kalori'], 0),
              'tanggal': ApiHelper.parseString(jsonData['summary']['tanggal']),
            };
          }
          
          return jsonData;
        }
      }

      return null;
    } catch (e) {
      print('Error getting today history: $e');
      return null;
    }
  }

  // ============================================
  // GET HISTORY (dengan filter tanggal)
  // ============================================
  static Future<Map<String, dynamic>?> getHistory({
    required int userId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      String url = '${AppConfig.baseUrl}/history.php?user_id=$userId&page=$page&limit=$limit';
      
      if (startDate != null) {
        url += '&start_date=$startDate';
      }
      if (endDate != null) {
        url += '&end_date=$endDate';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      print('Get History Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          // Parse history items
          if (jsonData['data'] != null) {
            final historyItems = (jsonData['data'] as List)
                .map((item) => ApiHelper.parseHistoryData(item))
                .toList();
            
            jsonData['data'] = historyItems;
          }
          
          // Parse summary by date
          if (jsonData['summary_by_date'] != null) {
            final summaries = (jsonData['summary_by_date'] as List)
                .map((summary) => {
                  'tanggal': ApiHelper.parseString(summary['tanggal']),
                  'total_items': ApiHelper.parseIntWithDefault(summary['total_items'], 0),
                  'total_kalori': ApiHelper.parseIntWithDefault(summary['total_kalori'], 0),
                })
                .toList();
            
            jsonData['summary_by_date'] = summaries;
          }
          
          // Parse pagination
          if (jsonData['pagination'] != null) {
            jsonData['pagination'] = {
              'page': ApiHelper.parseIntWithDefault(jsonData['pagination']['page'], 1),
              'limit': ApiHelper.parseIntWithDefault(jsonData['pagination']['limit'], 50),
              'total': ApiHelper.parseIntWithDefault(jsonData['pagination']['total'], 0),
              'total_pages': ApiHelper.parseIntWithDefault(jsonData['pagination']['total_pages'], 1),
            };
          }
          
          return jsonData;
        }
      }

      return null;
    } catch (e) {
      print('Error getting history: $e');
      return null;
    }
  }

  // ============================================
  // DELETE HISTORY ITEM
  // ============================================
  static Future<bool> deleteHistoryItem(int historyId, int userId) async {
    try {
      final request = http.Request(
        'DELETE',
        Uri.parse('${AppConfig.baseUrl}/history.php'),
      );
      
      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode({
        'history_id': historyId,
        'user_id': userId,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Delete History Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }

      return false;
    } catch (e) {
      print('Error deleting history: $e');
      return false;
    }
  }

  // ============================================
  // GET WEEKLY SUMMARY
  // ============================================
  static Future<List<Map<String, dynamic>>?> getWeeklySummary(int userId) async {
    try {
      final today = DateTime.now();
      final sevenDaysAgo = today.subtract(const Duration(days: 7));
      
      final startDate = '${sevenDaysAgo.year}-${sevenDaysAgo.month.toString().padLeft(2, '0')}-${sevenDaysAgo.day.toString().padLeft(2, '0')}';
      final endDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final result = await getHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (result != null && result['summary_by_date'] != null) {
        return List<Map<String, dynamic>>.from(result['summary_by_date']);
      }

      return null;
    } catch (e) {
      print('Error getting weekly summary: $e');
      return null;
    }
  }
}
