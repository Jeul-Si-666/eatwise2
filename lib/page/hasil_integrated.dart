import 'package:eatwise2/page/home_integrated.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/services/product_service_fixed.dart';
import 'package:eatwise2/services/profile_service_fixed.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Import LogicAlgorithm Anda
class LogicAlgorithm {
  double _hitungBayes(double kemungkinanAwal, double peluangJikaSakit, double peluangJikaSehat) {
    double pembilang = peluangJikaSakit * kemungkinanAwal;
    double penyebut = (peluangJikaSakit * kemungkinanAwal) +
        (peluangJikaSehat * (1 - kemungkinanAwal));
    return pembilang / penyebut;
  }
  
  double _pHipotesis(double kemungkinanAwal, String umurStr, bool adaRiwayat, String penyakit) {
    double faktor = 1.0;
    int umur = int.parse(umurStr);
    if (penyakit == "Diabetes") {
      if (umur > 45) faktor *= 1.39;
      else if (umur > 31) faktor *= 1.24;
      else faktor *= 1.09;
      faktor *= adaRiwayat ? 1.7 : 1.0;
    }
    else if (penyakit == "Kolestrol") {
      if (umur > 45) faktor *= 1.36;
      else if (umur > 31) faktor *= 1.27;
      else faktor *= 1.15;
      faktor *= adaRiwayat ? 1.4 : 1.0;
    }
    else if (penyakit == "Hipertensi") {
      if (umur > 45) faktor *= 1.39;
      else if (umur > 31) faktor *= 1.24;
      else faktor *= 1.09;
      faktor *= adaRiwayat ? 1.7 : 1.0;
    }
    return (kemungkinanAwal * faktor).clamp(0, 0.9);
  }
  
  double diabetes(String umur, bool adaRiwayat) {
    double P_Gula_Terhadap_Diabetes = 0.65;
    double P_Gula_Terhadap_Sehat = 0.4;
    double P_Diabetes = _pHipotesis(0.1, umur, adaRiwayat, "Diabetes");
    return _hitungBayes(P_Diabetes, P_Gula_Terhadap_Diabetes, P_Gula_Terhadap_Sehat);
  }
  
  double kolestrol(String umur, bool adaRiwayat) {
    double P_Lemak_Terhadap_Kolestrol = 0.65;
    double P_Lemak_Terhadap_Sehat = 0.4;
    double P_Kolestrol = _pHipotesis(0.1, umur, adaRiwayat, "Kolestrol");
    return _hitungBayes(P_Kolestrol, P_Lemak_Terhadap_Kolestrol, P_Lemak_Terhadap_Sehat);
  }
  
  double hipertensi(String umur, bool adaRiwayat) {
    double P_Garam_Terhadap_Hipertensi = 0.65;
    double P_Garam_Terhadap_Sehat = 0.4;
    double P_Hipertensi = _pHipotesis(0.1, umur, adaRiwayat, "Hipertensi");
    return _hitungBayes(P_Hipertensi, P_Garam_Terhadap_Hipertensi, P_Garam_Terhadap_Sehat);
  }
}

class ReportScreenApi extends StatefulWidget {
  final int productId;

  const ReportScreenApi({Key? key, required this.productId}) : super(key: key);

  @override
  State<ReportScreenApi> createState() => _ReportScreenApiState();
}

class _ReportScreenApiState extends State<ReportScreenApi> {
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _product;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _analysis;
  Map<String, double>? _risikoPersentase; // Tambahkan ini
  int? _userId;
  
  final LogicAlgorithm _bayesAlgorithm = LogicAlgorithm(); // Instance Bayes
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String? uIdString = prefs.getString('user_id');
      _userId = int.tryParse(uIdString ?? '');

      _product = await ProductService.getProductById(widget.productId);
      
      if (_userId != null) {
        _profile = await ProfileService.getProfile(_userId!);
      }

      if (_product != null && _profile != null) {
        _analysis = _performClientSideAnalysis(_product!, _profile!);
        _risikoPersentase = _calculateBayesRisk(_product!, _profile!); // Hitung risiko Bayes
      }

    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk menghitung risiko menggunakan Bayes
  Map<String, double> _calculateBayesRisk(
    Map<String, dynamic> product,
    Map<String, dynamic> profile,
  ) {
    Map<String, double> risiko = {};
    
    // Ambil data profil
    String umur = (profile['umur'] ?? 25).toString();
    bool riwayatDiabetes = profile['riwayat_diabetes'] == 1;
    bool riwayatKolesterol = profile['riwayat_kolesterol'] == 1;
    bool riwayatHipertensi = profile['riwayat_hipertensi'] == 1;
    
    // Hitung risiko hanya jika produk memiliki tingkat tinggi
    if (product['tingkat_gula'] == 'tinggi') {
      risiko['Diabetes'] = _bayesAlgorithm.diabetes(umur, riwayatDiabetes);
    }
    
    if (product['tingkat_lemak'] == 'tinggi') {
      risiko['Kolesterol'] = _bayesAlgorithm.kolestrol(umur, riwayatKolesterol);
    }
    
    if (product['tingkat_garam'] == 'tinggi') {
      risiko['Hipertensi'] = _bayesAlgorithm.hipertensi(umur, riwayatHipertensi);
    }
    
    return risiko;
  }

  Map<String, dynamic> _performClientSideAnalysis(
    Map<String, dynamic> product,
    Map<String, dynamic> profile,
  ) {
    bool statusAman = true;
    List<String> peringatanAlergi = [];
    List<String> peringatanPenyakit = [];

    // Cek alergi
    if (profile['alergi_gluten'] == 1 && product['mengandung_gluten'] == 1) {
      statusAman = false;
      peringatanAlergi.add('⚠️ MENGANDUNG GLUTEN');
    }
    if (profile['alergi_kacang'] == 1 && product['mengandung_kacang'] == 1) {
      statusAman = false;
      peringatanAlergi.add('⚠️ MENGANDUNG KACANG');
    }
    if (profile['alergi_telur'] == 1 && product['mengandung_telur'] == 1) {
      statusAman = false;
      peringatanAlergi.add('⚠️ MENGANDUNG TELUR');
    }
    if (profile['alergi_susu'] == 1 && product['mengandung_susu'] == 1) {
      statusAman = false;
      peringatanAlergi.add('⚠️ MENGANDUNG SUSU');
    }

    // Cek penyakit
    if (profile['riwayat_diabetes'] == 1 && product['tingkat_gula'] == 'tinggi') {
      peringatanPenyakit.add('⚠️ GULA TINGGI - Berisiko untuk diabetes');
    }
    if (profile['riwayat_kolesterol'] == 1 && product['tingkat_lemak'] == 'tinggi') {
      peringatanPenyakit.add('⚠️ LEMAK TINGGI - Berisiko untuk kolesterol');
    }
    if (profile['riwayat_hipertensi'] == 1 && product['tingkat_garam'] == 'tinggi') {
      peringatanPenyakit.add('⚠️ GARAM TINGGI - Berisiko untuk hipertensi');
    }

    if (peringatanPenyakit.isNotEmpty) {
      statusAman = false;
    }

    return {
      'status_aman': statusAman,
      'peringatan_alergi': peringatanAlergi,
      'peringatan_penyakit': peringatanPenyakit,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Produk tidak ditemukan'),
        ),
      );
    }

    // Parse komposisi
    List<String> composition = [];
    if (_product!['komposisi_array'] != null) {
      composition = List<String>.from(_product!['komposisi_array']);
    } else if (_product!['komposisi_bahan'] != null) {
      try {
        composition = List<String>.from(
          (jsonDecode(_product!['komposisi_bahan']) as List)
        );
      } catch (e) {
        composition = [_product!['komposisi_bahan']];
      }
    }

    final bool isGood = _analysis?['status_aman'] ?? true;
    final Color primaryColor = isGood ? const Color(0xFF388E3C) : const Color(0xFFFBC02D);
    final Color lightColor = isGood ? const Color(0xFFC8E6C9) : const Color(0xFFFFF9C4);
    final IconData statusIcon = isGood ? Icons.check_circle : Icons.warning;
    final String statusText = isGood ? 'AMAN' : 'BERESIKO';

    final int currentCalories = _profile?['kalori_terkonsumsi_hari_ini'] ?? 0;
    final int targetCalories = _profile?['target_kalori_harian'] ?? 2000;
    final int productCalories = _product!['kalori'] ?? 0;
    final int futureCalories = currentCalories + productCalories;
    double calorieProgress = (futureCalories / targetCalories).clamp(0.0, 1.0);
    String caloriePercentage = (calorieProgress * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header dengan gambar
            Stack(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: _product!['image_url'] != null
                        ? DecorationImage(
                            image: NetworkImage(_product!['image_url']),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[300],
                  ),
                  child: _product!['image_url'] == null
                      ? const Center(
                          child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                        )
                      : null,
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            statusText,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Konten detail
            Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama produk
                  Text(
                    (_product!['nama_produk'] ?? 'Unknown').toUpperCase(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: Colors.black,
                    ),
                  ),
                  if (_product!['merek'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _product!['merek'],
                      style: GoogleFonts.inter(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // BAGIAN BARU: Analisis Risiko Bayes
                  if (_risikoPersentase != null && _risikoPersentase!.isNotEmpty) ...[
                    _buildRisikoSection(_risikoPersentase!),
                    const SizedBox(height: 24),
                  ],

                  // Peringatan alergi
                  if (_analysis != null && _analysis!['peringatan_alergi'].isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                'PERINGATAN ALERGI',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...(_analysis!['peringatan_alergi'] as List).map((warning) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                warning,
                                style: GoogleFonts.inter(color: Colors.red.shade900),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Peringatan penyakit
                  if (_analysis != null && _analysis!['peringatan_penyakit'].isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.health_and_safety, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                'PERHATIAN KESEHATAN',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...(_analysis!['peringatan_penyakit'] as List).map((warning) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                warning,
                                style: GoogleFonts.inter(color: Colors.orange.shade900),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Komposisi
                  Text('Komposisi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: composition.map((item) {
                      return _buildCompositionItem(item, isGood: isGood);
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Informasi Gizi
                  Text('Informasi Gizi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    '${_product!['kalori']} kal | ${_product!['karbohidrat']}g karbo | ${_product!['protein']}g protein | ${_product!['lemak_total']}g lemak',
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Kalori Harian
                  Text('Kalori Harian (Setelah Konsumsi)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$futureCalories / $targetCalories kal',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$caloriePercentage%',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: calorieProgress,
                      minHeight: 12,
                      color: primaryColor,
                      backgroundColor: lightColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Tambah Konsumsi
                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleAddConsumption,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Tambah Konsumsi',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isGood ? Colors.white : Colors.black,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget baru untuk menampilkan risiko Bayes
  Widget _buildRisikoSection(Map<String, double> risiko) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.purple.shade700, size: 28),
              const SizedBox(width: 12),
              Text(
                'Analisis Risiko Penyakit',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.purple.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Berdasarkan komposisi makanan dan profil kesehatan Anda:',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          ...risiko.entries.map((entry) {
            return _buildRisikoItem(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRisikoItem(String penyakit, double persentase) {
    final persenFormat = (persentase * 100).toStringAsFixed(1);
    Color risikoColor;
    String risikoLevel;
    
    if (persentase < 0.3) {
      risikoColor = Colors.green;
      risikoLevel = 'Rendah';
    } else if (persentase < 0.6) {
      risikoColor = Colors.orange;
      risikoLevel = 'Sedang';
    } else {
      risikoColor = Colors.red;
      risikoLevel = 'Tinggi';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                penyakit,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: risikoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: risikoColor, width: 1),
                ),
                child: Text(
                  '$persenFormat% ($risikoLevel)',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: risikoColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: persentase,
              minHeight: 8,
              color: risikoColor,
              backgroundColor: risikoColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompositionItem(String text, {required bool isGood}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(
            '•  ',
            style: TextStyle(
              color: isGood ? Colors.black : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddConsumption() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak ditemukan')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final result = await ProductService.analyzeAndSaveConsumption(
        userId: _userId!,
        productId: widget.productId,
        jumlahPorsi: 1.0,
      );

      if (result != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Berhasil!', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            content: Text(
              'Konsumsi berhasil ditambahkan!\n\n'
              'Kalori: +${result['kalori_dikonsumsi']} kal\n'
              'Total Hari Ini: ${result['total_kalori_hari_ini']} kal',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => HomeContent()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Gagal menyimpan konsumsi');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
}