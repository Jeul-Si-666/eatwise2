import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // --- ASET DESAIN (KONSISTEN DENGAN SEBELUMNYA) ---

  // Warna
  static const Color _backgroundColor = Color(0xFFAEB8AF); // Latar belakang
  static const Color _buttonColor = Color(0xFF549E61);
  static const Color _textFieldFillColor = Color(0x51D1D1D1);
  static const Color _textColorBlack = Color(0xFF000000);
  static const Color _dividerColor = Color(0xFF000000);

  // Style Teks
  static final TextStyle _subtitleStyle = GoogleFonts.inter(
    fontSize: 28.12,
    fontWeight: FontWeight.w500, // Medium
    color: _textColorBlack,
  );

  static final TextStyle _bodyStyle = GoogleFonts.inter(
    fontSize: 18.62,
    fontWeight: FontWeight.w200, // Extra Light
    color: _textColorBlack,
  );

  static final TextStyle _headingStyle = GoogleFonts.inter(
    fontSize: 24, 
    fontWeight: FontWeight.w700, // Bold
    color: _textColorBlack,
  );

  static final TextStyle _labelStyle = GoogleFonts.inter(
    fontSize: 17.88,
    fontWeight: FontWeight.w300, // Light
    color: _textColorBlack,
  );

  static final TextStyle _textFieldInputStyle = GoogleFonts.inter(
    fontSize: 24.23,
    fontWeight: FontWeight.w400, // Regular
    color: _textColorBlack,
  );
  
  static final TextStyle _buttonTextStyle = GoogleFonts.inter(
    fontSize: 24.23,
    fontWeight: FontWeight.w400, // Regular
    color: _textColorBlack,
  );

  // Ukuran & Spacing
  static const double _sidePadding = 32.0;
  static const double _textFieldHeight = 60.0;
  static const double _buttonHeight = 60.0;
  static const double _textFieldRadius = 10.0; 
  static const double _buttonRadius = 10.0; 


  // --- State untuk Checkbox ---
  bool _diabetesChecked = false;
  bool _kolesterolChecked = false;
  
  // --- STATE BARU UNTUK BAHAN DIHINDARI ---
  bool _hindariGluten = false;
  bool _hindariKacang = false;
  bool _hindariTelur = false;
  // ---------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColorBlack, size: 30),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8), 

              // 2. Judul Halaman
              Text(
                'User Profile',
                style: _subtitleStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Hi, Zelcy', 
                style: _bodyStyle,
              ),
              const SizedBox(height: 40),

              // 3. Section Data Fisik
              Text(
                'Data Fisik',
                style: _headingStyle,
              ),
              const SizedBox(height: 16),
              _buildTextField(hint: 'Usia (tahun)'),
              const SizedBox(height: 16),
              _buildTextField(hint: 'Berat Badan (kg)'),
              const SizedBox(height: 16),
              _buildTextField(hint: 'Tinggi Badan (cm)'),
              const SizedBox(height: 40),

              // 4. Section Riwayat Kesehatan
              Text(
                'Riwayat Kesehatan',
                style: _headingStyle,
              ),
              const SizedBox(height: 16),
              _buildCheckbox(
                label: 'Riwayat Diabetes',
                value: _diabetesChecked,
                onChanged: (bool? newValue) {
                  setState(() {
                    _diabetesChecked = newValue ?? false;
                  });
                },
              ),
              _buildCheckbox(
                label: 'Riwayat Kolesterol',
                value: _kolesterolChecked,
                onChanged: (bool? newValue) {
                  setState(() {
                    _kolesterolChecked = newValue ?? false;
                  });
                },
              ),
              const SizedBox(height: 40), // Jarak antar section

              // 5. SECTION BARU: BAHAN YANG DIHINDARI
              Text(
                'Bahan yang Dihindari:',
                style: _headingStyle,
              ),
              const SizedBox(height: 16),
              _buildCheckbox(
                label: 'Gluten',
                value: _hindariGluten,
                onChanged: (bool? newValue) {
                  setState(() {
                    _hindariGluten = newValue ?? false;
                  });
                },
              ),
              _buildCheckbox(
                label: 'Kacang',
                value: _hindariKacang,
                onChanged: (bool? newValue) {
                  setState(() {
                    _hindariKacang = newValue ?? false;
                  });
                },
              ),
              _buildCheckbox(
                label: 'Telur',
                value: _hindariTelur,
                onChanged: (bool? newValue) {
                  setState(() {
                    _hindariTelur = newValue ?? false;
                  });
                },
              ),
              const SizedBox(height: 48),

              // 6. Tombol Save
              ElevatedButton(
                onPressed: () {
                  // TODO: Logika save data
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  minimumSize: const Size(double.infinity, _buttonHeight), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_buttonRadius),
                  ),
                  elevation: 0,
                ),
                child: Text('Save', style: _buttonTextStyle),
              ),
              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk TextField (TIDAK BERUBAH)
  Widget _buildTextField({required String hint}) {
    return SizedBox(
      height: _textFieldHeight,
      child: TextField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        style: _textFieldInputStyle,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: _textFieldInputStyle.copyWith(
            color: _textColorBlack.withOpacity(0.5),
          ),
          filled: true,
          fillColor: _textFieldFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_textFieldRadius),
            borderSide: const BorderSide(width: 1.0, color: _dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_textFieldRadius),
            borderSide: const BorderSide(width: 1.0, color: _dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_textFieldRadius),
            borderSide: const BorderSide(width: 1.5, color: _dividerColor),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
      ),
    );
  }

  // Widget helper untuk Checkbox (TIDAK BERUBAH, HANYA DIPAKAI ULANG)
  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(label, style: _labelStyle),
      value: value,
      onChanged: onChanged,
      activeColor: _buttonColor, 
      controlAffinity: ListTileControlAffinity.leading, 
      contentPadding: EdgeInsets.zero, 
    );
  }
}