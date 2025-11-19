import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:eatwise2/user_profile.dart';
// Import FoodHistoryScreen (perlu dibuat)


class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  // --- ASET DESAIN (Modifikasi Anti-Desain) ---

  // Warna
  static const Color _backgroundColor = Color(0xFFC0C0C0); // Lebih terang, sedikit "dingin"
  static const Color _cardColor = Color(0xFFEFEFEF); // Tetap terang
  static const Color _scanButtonColor = Color(0xFFEFEFEF);
  static const Color _textColorBlack = Color(0xFF000000);
  static const Color _textColorWhite = Color(0xFFFFFFFF);
  static const Color _brandColorGreen = Color(0xFF13721C); // Hijau gelap tetap dominan
  static const Color _antiDesignAccentColor = Color(0xFFD32F2F); // Warna aksen yang kontras/berani (Merah)

  // Gradien (Header & Footer) - Lebih tegas atau sedikit "berubah"
  static const LinearGradient _headerGradient = LinearGradient(
    colors: [Color(0xFF388E3C), Color(0xFF1B5E20)], // Hijau lebih gelap dan kontras
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient _bottomBarGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)], // Dibalik atau beda sedikit
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  // Style Teks - Bisa lebih berani atau penempatan aneh
  static final TextStyle _titleStyle = GoogleFonts.padauk(
    fontSize: 65, // Lebih besar
    fontWeight: FontWeight.w900, // Extra Bold
    color: _textColorWhite,
    letterSpacing: 2, // Spacing antar huruf
  );

  static final TextStyle _subtitleStyle = GoogleFonts.inter(
    fontSize: 28, // Lebih besar
    fontWeight: FontWeight.w700, // Bold
    color: _textColorWhite,
    height: 1.5, // Jarak antar baris
  );

  static final TextStyle _cardTextStyle = GoogleFonts.inter(
    fontSize: 26, // Lebih besar
    fontWeight: FontWeight.w600, // Semi-Bold
    color: _textColorBlack,
  );

  static final TextStyle _scanTextStyle = GoogleFonts.inter(
    fontSize: 28, // Lebih besar
    fontWeight: FontWeight.w700, // Bold
    color: _textColorWhite,
  );

  static final TextStyle _calorieNumStyle = GoogleFonts.inter(
    fontSize: 38, // Lebih besar
    fontWeight: FontWeight.w900, // Extra Bold
    color: _brandColorGreen,
    letterSpacing: -0.5, // Sedikit rapat
  );

  static final TextStyle _calorieLabelStyle = GoogleFonts.inter(
    fontSize: 38, // Lebih besar
    fontWeight: FontWeight.w500, // Medium
    color: _textColorBlack,
  );

  // Ukuran & Spacing (Diubah untuk anti-desain)
  static const double _sidePadding = 20.0; // Sedikit kurang padding
  static const double _cardRadius = 10.0; // Sudut lebih tajam
  static const double _barRadius = 50.0; // Lebih bulat ekstrem
  static const double _iconSizeLarge = 80.0; // Ikon lebih besar
  static const double _iconSizeMedium = 50.0;

  // ---------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER (Lebih besar, gradien lebih tajam)
            _buildHeader(),

            // 2. KONTEN (CARD) - Layout asimetris
            Padding(
              padding: const EdgeInsets.fromLTRB(_sidePadding, 30, _sidePadding, 20), // Padding tidak simetris
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align kiri
                children: [
                  // Card Profil (Geser sedikit ke kanan)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildClickableCard(
                      context: context,
                      widthFactor: 0.9, // Ukuran tidak penuh
                      height: 180, // Lebih tinggi
                      icon: Icons.person_outline_sharp, // Ikon lebih "basic"
                      iconColor: _antiDesignAccentColor, // Warna ikon kontras
                      label: 'Profil',
                      labelStyle: _cardTextStyle.copyWith(color: _antiDesignAccentColor), // Warna teks kontras
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25), // Jarak tidak biasa

                  // Card Kalori (Geser sedikit ke kiri, tumpang tindih)
                  Transform.translate(
                    offset: const Offset(-20, -50), // Geser dan tumpang tindih
                    child: _buildClickableCalorieCard(
                      context: context,
                      widthFactor: 1.0, // Penuh
                      height: 180, // Tinggi sama
                      calorieValue: 1500,
                      progress: 0.75,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FoodHistoryScreen()), // Navigasi ke FoodHistoryScreen
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Memberi ruang ekstra untuk FAB
          ],
        ),
      ),
      // 3. TOMBOL SCAN (FLOATING ACTION BUTTON) - Lebih besar, diletakkan lebih tinggi
      floatingActionButton: _buildScanButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Diletakkan di tengah-bawah, tidak menempel
      
      // 4. BOTTOM BAR - Bentuk dan gradien berbeda
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 80, // Lebih banyak padding atas
        bottom: 50, // Lebih banyak padding bawah
        left: _sidePadding,
        right: _sidePadding,
      ),
      decoration: const BoxDecoration(
        gradient: _headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_barRadius),
          bottomRight: Radius.circular(_barRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'EATWISE',
            textAlign: TextAlign.center,
            style: _titleStyle,
          ),
          const SizedBox(height: 15),
          Text(
            'Hai, Zelcy yang hebat!', // Pesan yang sedikit beda
            textAlign: TextAlign.center,
            style: _subtitleStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildClickableCard({
    required BuildContext context,
    required double widthFactor,
    required double height,
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextStyle labelStyle,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: height,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(_cardRadius),
            boxShadow: [
              BoxShadow(
                color: const Color(0x66000000), // Shadow lebih kuat
                blurRadius: 8,
                offset: const Offset(5, 8), // Offset shadow yang lebih besar
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: _iconSizeLarge, color: iconColor),
              const SizedBox(height: 15),
              Text(label, style: labelStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickableCalorieCard({
    required BuildContext context,
    required double widthFactor,
    required double height,
    required int calorieValue,
    required double progress,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: height,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(_cardRadius),
            boxShadow: [
              BoxShadow(
                color: const Color(0x66000000), // Shadow lebih kuat
                blurRadius: 8,
                offset: const Offset(5, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Teks Kalori
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$calorieValue', style: _calorieNumStyle),
                  Text('Kalori', style: _calorieLabelStyle),
                ],
              ),
              
              // Lingkaran Progress (Placeholder)
              SizedBox(
                width: 120, // Lebih besar
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      color: _brandColorGreen.withOpacity(0.3),
                      strokeWidth: 15, // Lebih tebal
                    ),
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: CircularProgressIndicator(
                        value: progress,
                        color: _brandColorGreen,
                        strokeWidth: 15,
                        strokeCap: StrokeCap.square, // Ujung kotak
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.local_fire_department,
                        color: _brandColorGreen,
                        size: _iconSizeMedium, // Ikon api lebih kecil sedikit
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120, // Lebih besar
          height: 120,
          child: FloatingActionButton(
            onPressed: () {
              // TODO: Logika tap SCAN
            },
            backgroundColor: _scanButtonColor,
            elevation: 8.0, // Elevasi lebih tinggi
            shape: const CircleBorder(
              side: BorderSide(color: _brandColorGreen, width: 4), // Border hijau
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: 70, // Ikon lebih besar
              color: _brandColorGreen, // Ikon warna hijau
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'SCAN SEKARANG', // Teks lebih eksplisit
          style: _scanTextStyle.copyWith(color: _brandColorGreen), // Warna teks hijau
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 100, // Lebih tinggi
      decoration: const BoxDecoration(
        gradient: _bottomBarGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_barRadius),
          topRight: Radius.circular(_barRadius),
        ),
      ),
      child: Center(
        child: Text(
          'EATWISE 2024', // Info di footer
          style: _subtitleStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w300),
        ),
      ),
    );
  }
}

// TODO: Buat FoodHistoryScreen.dart (Contoh sederhana)
class FoodHistoryScreen extends StatelessWidget {
  const FoodHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Makanan'),
        backgroundColor: HomeContent._headerGradient.colors.first,
      ),
      body: Center(
        child: Text('Ini adalah halaman Riwayat Makanan yang sudah di-scan.'),
      ),
    );
  }
}