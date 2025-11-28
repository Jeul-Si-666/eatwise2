// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:eatwise2/util/config.dart';
// import 'package:eatwise2/services/api_helper.dart';

// class ProductService {
//   // ============================================
//   // GET PRODUCT BY BARCODE
//   // ============================================
//   static Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/products.php?barcode=$barcode'),
//         headers: {"Content-Type": "application/json"},
//       );

//       print('Get Product Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         if (jsonData['success'] == true && jsonData['data'] != null) {
//           // Parse dengan ApiHelper untuk handle String/Int conversion
//           return ApiHelper.parseProductData(jsonData['data']);
//         }
//       }

//       return null;
//     } catch (e) {
//       print('Error getting product: $e');
//       return null;
//     }
//   }

//   // ============================================
//   // GET PRODUCT BY ID
//   // ============================================
//   static Future<Map<String, dynamic>?> getProductById(int productId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/products.php?id=$productId'),
//         headers: {"Content-Type": "application/json"},
//       );

//       print('Get Product Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         if (jsonData['success'] == true && jsonData['data'] != null) {
//           // Parse dengan ApiHelper untuk handle String/Int conversion
//           return ApiHelper.parseProductData(jsonData['data']);
//         }
//       }

//       return null;
//     } catch (e) {
//       print('Error getting product: $e');
//       return null;
//     }
//   }

//   // ============================================
//   // GET ALL PRODUCTS (dengan pagination)
//   // ============================================
//   static Future<Map<String, dynamic>?> getAllProducts({int page = 1, int limit = 20}) async {
//     try {
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/products.php?page=$page&limit=$limit'),
//         headers: {"Content-Type": "application/json"},
//       );

//       print('Get All Products Response: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         if (jsonData['success'] == true) {
//           // Parse setiap product dengan ApiHelper
//           if (jsonData['data'] != null) {
//             final products = (jsonData['data'] as List)
//                 .map((product) => ApiHelper.parseProductData(product))
//                 .toList();
            
//             jsonData['data'] = products;
//           }
//           return jsonData;
//         }
//       }

//       return null;
//     } catch (e) {
//       print('Error getting products: $e');
//       return null;
//     }
//   }

//   // ============================================
//   // CREATE PRODUCT (User Input Manual)
//   // ============================================
//   static Future<int?> createProduct(Map<String, dynamic> productData) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/products.php'),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode(productData),
//       );

//       print('Create Product Response: ${response.body}');

//       if (response.statusCode == 201) {
//         final jsonData = json.decode(response.body);
//         if (jsonData['success'] == true) {
//           return ApiHelper.parseInt(jsonData['product_id']);
//         }
//       }

//       return null;
//     } catch (e) {
//       print('Error creating product: $e');
//       return null;
//     }
//   }

//   // ============================================
//   // ANALYZE & SAVE CONSUMPTION
//   // ============================================
//   static Future<Map<String, dynamic>?> analyzeAndSaveConsumption({
//     required int userId,
//     required int productId,
//     double jumlahPorsi = 1.0,
//     String? jenisWaktuMakan,
//     String? catatan,
//   }) async {
//     try {
//       final requestData = {
//         'user_id': userId,
//         'product_id': productId,
//         'jumlah_porsi': jumlahPorsi,
//         'jenis_waktu_makan': jenisWaktuMakan,
//         'catatan': catatan,
//       };

//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/analyze.php'),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode(requestData),
//       );

//       print('Analyze Response: ${response.body}');

//       if (response.statusCode == 201) {
//         final jsonData = json.decode(response.body);
//         if (jsonData['success'] == true && jsonData['data'] != null) {
//           // Parse response data dengan safe parsing
//           final data = jsonData['data'];
//           return {
//             'history_id': ApiHelper.parseInt(data['history_id']),
//             'kalori_dikonsumsi': ApiHelper.parseIntWithDefault(data['kalori_dikonsumsi'], 0),
//             'total_kalori_hari_ini': ApiHelper.parseIntWithDefault(data['total_kalori_hari_ini'], 0),
//             'target_kalori': ApiHelper.parseIntWithDefault(data['target_kalori'], 2000),
//             'persentase_kalori': ApiHelper.parseDoubleWithDefault(data['persentase_kalori'], 0.0),
//             'status_aman': ApiHelper.parseBool(data['status_aman']),
//             'peringatan_alergi': data['peringatan_alergi'] ?? [],
//             'peringatan_penyakit': data['peringatan_penyakit'] ?? [],
//             'rekomendasi': data['rekomendasi'] ?? [],
//           };
//         }
//       }

//       return null;
//     } catch (e) {
//       print('Error analyzing consumption: $e');
//       return null;
//     }
//   }
// }
