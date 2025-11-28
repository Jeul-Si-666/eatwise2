import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/Model/reporthasil.dart';
// import 'report_data.dart'; // Import file model Anda

// --- CONTOH DATA (Bisa dihapus jika data dari server) ---
// Ini hanya untuk demo, agar Anda bisa langsung run kodenya
final ReportHasil reportAman = ReportHasil(
  isGood: true,
  imageUrl: 'https_placeholder_image_url_susu', // Ganti dengan URL gambar
  title: 'SUSU UHT FULL CREAM',
  composition: ['Susu'],
  nutritionInfo: '120 kal | 10 g karbo | 6 g protein | 6 g Lemak',
  currentCalories: 720,
  totalCalories: 2500,
);

final ReportHasil reportBuruk = ReportHasil(
  isGood: false,
  imageUrl: 'https_placeholder_image_url_nasi_padang', // Ganti dengan URL gambar
  title: 'NASI PADANG',
  composition: ['Santan', 'Gula', 'Daging'],
  nutritionInfo: '1500 kal | 90 g karbo | 20 g protein | 220 g Lemak',
  currentCalories: 1770,
  totalCalories: 2500,
);
// --------------------------------------------------------


class ReportScreen extends StatelessWidget {
  // Layar ini menerima data laporan yang mau ditampilkan
  final ReportHasil report;

  const ReportScreen({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tentukan warna tema berdasarkan status laporan
    final Color primaryColor = report.isGood ? const Color(0xFF388E3C) : const Color(0xFFFBC02D);
    final Color lightColor = report.isGood ? const Color(0xFFC8E6C9) : const Color(0xFFFFF9C4);
    final IconData statusIcon = report.isGood ? Icons.check_circle : Icons.warning;
    final String statusText = report.isGood ? 'AMAN' : 'BERESIKO';

    // Kalkulasi persentase kalori
    double calorieProgress = (report.currentCalories / report.totalCalories).clamp(0.0, 1.0);
    String caloriePercentage = (calorieProgress * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Latar belakang abu-abu muda
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header (Gambar, Tombol Back, Status Chip)
            Stack(
              children: [
                // Gambar Makanan
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(report.imageUrl), // Placeholder
                      fit: BoxFit.cover,
                    ),
                    color: Colors.grey[300],
                  ),
                ),

                // Tombol Back
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

                // Status Chip (Aman / Berisiko)
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

            // 2. Konten Detail (Area Putih)
            Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0), // Tarik ke atas
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
                  // Judul Makanan
                  Text(
                    report.title.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Komposisi
                  Text(
                    'Komposisi',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Buat list komposisi
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: report.composition.map((item) {
                      return _buildCompositionItem(item, isGood: report.isGood);
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Informasi Gizi
                  Text(
                    'Informasi Gizi',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.nutritionInfo,
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Kalori Harian
                  Text(
                    'Kalori Harian',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${report.currentCalories} / ${report.totalCalories} kal',
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
                    onPressed: () {
                      // TODO: Logika tambah konsumsi
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size(double.infinity, 56), // Lebar penuh
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Tambah Konsumsi',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: report.isGood ? Colors.white : Colors.black, // Teks hitam di tombol kuning
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

  // Widget helper untuk item komposisi (agar bisa beda warna)
  Widget _buildCompositionItem(String text, {required bool isGood}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(
            '•  ',
            style: TextStyle(
              color: isGood ? Colors.black : Colors.red, // Warna bullet
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}