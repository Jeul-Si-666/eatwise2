// api_helper.dart - Utility untuk parsing data dari API
// Mengatasi masalah type mismatch (String vs Int/Double)

class ApiHelper {
  // ============================================
  // SAFE INT PARSE
  // ============================================
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  // Dengan default value
  static int parseIntWithDefault(dynamic value, int defaultValue) {
    return parseInt(value) ?? defaultValue;
  }

  // ============================================
  // SAFE DOUBLE PARSE
  // ============================================
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Dengan default value
  static double parseDoubleWithDefault(dynamic value, double defaultValue) {
    return parseDouble(value) ?? defaultValue;
  }

  // ============================================
  // SAFE BOOL PARSE
  // ============================================
  static bool parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' || 
             value.toLowerCase() == 'true' || 
             value.toLowerCase() == 'yes';
    }
    return false;
  }

  // ============================================
  // SAFE STRING PARSE
  // ============================================
  static String? parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  // Dengan default value
  static String parseStringWithDefault(dynamic value, String defaultValue) {
    return parseString(value) ?? defaultValue;
  }

  // ============================================
  // PARSE MAP DENGAN SAFE CONVERSION
  // ============================================
  static Map<String, dynamic> safeParseMap(Map<String, dynamic> data, Map<String, Type> schema) {
    final result = <String, dynamic>{};
    
    data.forEach((key, value) {
      if (schema.containsKey(key)) {
        final expectedType = schema[key];
        
        if (expectedType == int) {
          result[key] = parseInt(value);
        } else if (expectedType == double) {
          result[key] = parseDouble(value);
        } else if (expectedType == bool) {
          result[key] = parseBool(value);
        } else if (expectedType == String) {
          result[key] = parseString(value);
        } else {
          result[key] = value;
        }
      } else {
        result[key] = value;
      }
    });
    
    return result;
  }

  // ============================================
  // PARSE PRODUCT DATA
  // ============================================
  static Map<String, dynamic> parseProductData(Map<String, dynamic> raw) {
    return {
      'id': parseInt(raw['id']),
      'barcode': parseString(raw['barcode']),
      'nama_produk': parseString(raw['nama_produk']),
      'merek': parseString(raw['merek']),
      'kategori': parseString(raw['kategori']),
      'komposisi_bahan': raw['komposisi_bahan'],
      'komposisi_array': raw['komposisi_array'],
      'serving_size': parseString(raw['serving_size']),
      'kalori': parseIntWithDefault(raw['kalori'], 0),
      'karbohidrat': parseDoubleWithDefault(raw['karbohidrat'], 0.0),
      'protein': parseDoubleWithDefault(raw['protein'], 0.0),
      'lemak_total': parseDoubleWithDefault(raw['lemak_total'], 0.0),
      'lemak_jenuh': parseDoubleWithDefault(raw['lemak_jenuh'], 0.0),
      'gula': parseDoubleWithDefault(raw['gula'], 0.0),
      'garam': parseDoubleWithDefault(raw['garam'], 0.0),
      'serat': parseDoubleWithDefault(raw['serat'], 0.0),
      'mengandung_gluten': parseBool(raw['mengandung_gluten']),
      'mengandung_kacang': parseBool(raw['mengandung_kacang']),
      'mengandung_telur': parseBool(raw['mengandung_telur']),
      'mengandung_susu': parseBool(raw['mengandung_susu']),
      'mengandung_seafood': parseBool(raw['mengandung_seafood']),
      'tingkat_gula': parseString(raw['tingkat_gula']),
      'tingkat_garam': parseString(raw['tingkat_garam']),
      'tingkat_lemak': parseString(raw['tingkat_lemak']),
      'image_url': parseString(raw['image_url']),
      'status_verifikasi': parseString(raw['status_verifikasi']),
    };
  }

  // ============================================
  // PARSE PROFILE DATA
  // ============================================
  static Map<String, dynamic> parseProfileData(Map<String, dynamic> raw) {
    return {
      'id': parseInt(raw['id']),
      'user_id': parseInt(raw['user_id']),
      'nama_lengkap': parseString(raw['nama_lengkap']),
      'usia': parseInt(raw['usia']),
      'berat_badan': parseDouble(raw['berat_badan']),
      'tinggi_badan': parseDouble(raw['tinggi_badan']),
      'riwayat_diabetes': parseBool(raw['riwayat_diabetes']),
      'riwayat_kolesterol': parseBool(raw['riwayat_kolesterol']),
      'riwayat_hipertensi': parseBool(raw['riwayat_hipertensi']),
      'riwayat_jantung': parseBool(raw['riwayat_jantung']),
      'alergi_gluten': parseBool(raw['alergi_gluten']),
      'alergi_kacang': parseBool(raw['alergi_kacang']),
      'alergi_telur': parseBool(raw['alergi_telur']),
      'alergi_susu': parseBool(raw['alergi_susu']),
      'alergi_seafood': parseBool(raw['alergi_seafood']),
      'notif_sarapan_aktif': parseBool(raw['notif_sarapan_aktif']),
      'waktu_sarapan': parseString(raw['waktu_sarapan']),
      'notif_siang_aktif': parseBool(raw['notif_siang_aktif']),
      'waktu_siang': parseString(raw['waktu_siang']),
      'notif_malam_aktif': parseBool(raw['notif_malam_aktif']),
      'waktu_malam': parseString(raw['waktu_malam']),
      'target_kalori_harian': parseIntWithDefault(raw['target_kalori_harian'], 2000),
      'kalori_terkonsumsi_hari_ini': parseIntWithDefault(raw['kalori_terkonsumsi_hari_ini'], 0),
      'tanggal_reset_kalori': parseString(raw['tanggal_reset_kalori']),
    };
  }

  // ============================================
  // PARSE HISTORY DATA
  // ============================================
  static Map<String, dynamic> parseHistoryData(Map<String, dynamic> raw) {
    return {
      'id': parseInt(raw['id']),
      'user_id': parseInt(raw['user_id']),
      'food_product_id': parseInt(raw['food_product_id']),
      'nama_produk': parseString(raw['nama_produk']),
      'merek': parseString(raw['merek']),
      'image_url': parseString(raw['image_url']),
      'kategori': parseString(raw['kategori']),
      'tanggal': parseString(raw['tanggal']),
      'waktu': parseString(raw['waktu']),
      'jenis_waktu_makan': parseString(raw['jenis_waktu_makan']),
      'jumlah_porsi': parseDouble(raw['jumlah_porsi']),
      'kalori_dikonsumsi': parseIntWithDefault(raw['kalori_dikonsumsi'], 0),
      'kalori_per_serving': parseIntWithDefault(raw['kalori_per_serving'], 0),
      'status_aman': parseBool(raw['status_aman']),
      'peringatan_alergi': raw['peringatan_alergi'] ?? [],
      'peringatan_penyakit': raw['peringatan_penyakit'] ?? [],
      'catatan_user': parseString(raw['catatan_user']),
    };
  }
}
