import 'package:eatwise2/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eatwise2/Model/user.dart';
import 'package:eatwise2/util/config.dart';
import 'package:eatwise2/util/util.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // --- ASET DESAIN (SAMA SEPERTI LOGIN) ---
 final _formKey = GlobalKey<FormState>();
  TextEditingController namaCont = new TextEditingController();
  TextEditingController passwordCont = new TextEditingController();
  TextEditingController emailCont = new TextEditingController();
  // Warna
  static const Color _backgroundColor = Color(0xFFAEB8AF); // Latar belakang
  static const Color _buttonColor = Color(0xFF549E61);
  static const Color _signinLinkColor = Color(0xFF13721D); // Warna link "Sign In"
  static const Color _textFieldFillColor = Color(0x51D1D1D1); 
  static const Color _textColorBlack = Color(0xFF000000);
  static const Color _dividerColor = Color(0xFF000000); 

  // Gradien Teks (untuk 'EATWISE')
  static final Shader _titleGradient = const LinearGradient(
    colors: [Color(0xFF549A5B), Color(0xFF5F9D65), Color(0xFF13721D)],
    stops: [0.0, 0.44, 0.97],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0));

  // Style Teks
  static final TextStyle _titleStyle = GoogleFonts.padauk(
    fontSize: 59.21,
    fontWeight: FontWeight.w700, // Bold
  );

  static final TextStyle _subtitleStyle = GoogleFonts.inter(
    fontSize: 28.12,
    fontWeight: FontWeight.w500, // Medium
    color: _textColorBlack,
  );

  static final TextStyle _bodyStyle = GoogleFonts.inter(
    fontSize: 18.62,
    fontWeight: FontWeight.w300, // Extra Light
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

  static final TextStyle _bottomTextStyle = GoogleFonts.inter(
    fontSize: 17.88,
    fontWeight: FontWeight.w300, // Light
    color: _textColorBlack,
  );

  static final TextStyle _bottomLinkStyle = GoogleFonts.inter(
    fontSize: 17.88,
    fontWeight: FontWeight.w700, // Asumsi: Bold
    color: _signinLinkColor, // Menggunakan warna link yang sama
  );

  // Ukuran & Spacing
  static const double _sidePadding = 32.0;
  static const double _textFieldHeight = 60.0;
  static const double _buttonHeight = 60.0;
  static const double _buttonRadius = 55.0;
  static const double _textFieldRadius = 10.0;
  static const double _iconSize = 32.0; 

  // ---------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60), // Spasi atas

              // 2. Judul "EATWISE" (dengan Gradien)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => _titleGradient,
                child: Text(
                  'EATWISE',
                  textAlign: TextAlign.center,
                  style: _titleStyle,
                ),
              ),
              const SizedBox(height: 36),

              // 3. Sub-Judul
              Text(
                'Create Your Account',
                textAlign: TextAlign.center,
                style: _subtitleStyle,
              ),
              const SizedBox(height: 12),

              // 4. Deskripsi
              Text(
                'Sign Up Now, Thank Us Later',
                textAlign: TextAlign.center,
                style: _bodyStyle,
              ),
              const SizedBox(height: 48),

              // 5. Form Input (BARU: Hanya "Nama")
             // _buildTextField(label: 'Nama', hint: ''), // Diubah di sini
             TextFormField(
              controller: namaCont,
              decoration: InputDecoration(
                  icon: Icon(Icons.person), hintText: 'Nama Lengkap'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Tidak boleh kosong';
                }
                return null;
              },
            ),
             
              const SizedBox(height: 24),

              // 6. Form Input Email
              //_buildTextField(label: 'Email', hint: ''),
              TextFormField(
              controller: emailCont,
              decoration: InputDecoration(
                  icon: Icon(Icons.person), hintText: 'Email'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Tidak boleh kosong';
                }
                return null;
              },
            ),
              
              const SizedBox(height: 24),

              // 7. Form Input Password
              // _buildTextField(label: 'Password', hint: '', isPassword: true),
              TextFormField(
              controller: passwordCont,
              decoration: InputDecoration(
                  icon: Icon(Icons.person), hintText: 'Password'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Tidak boleh kosong';
                }
                return null;
              },
            ),
              
              const SizedBox(height: 40),

              // 8. Tombol Register
              ElevatedButton(
                onPressed:prosesRegistrasi,
                style: ElevatedButton.styleFrom(
                  
                  backgroundColor: _buttonColor,
                  fixedSize: const Size(double.infinity, _buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_buttonRadius),
                  ),
                  elevation: 0,
                ),
                child: Text('Register', style: _buttonTextStyle), 
              ),
              const SizedBox(height: 32),

              // 9. Divider dengan Ikon
              _buildDividerWithIcon(),
              const SizedBox(height: 32),

              // 10. Link ke Sign In
              Align(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    text: "Already Have Account ? ", 
                    style: _bottomTextStyle,
                    children: [
                      TextSpan(
                        text: 'Sign In', 
                        style: _bottomLinkStyle,
                        // TODO: Tambahkan recognizer untuk navigasi
                        recognizer: TapGestureRecognizer()..onTap = () {
                         print('Ke Halaman Sign In');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()), // Ganti dengan halaman Sign Up Anda
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40), // Spasi bawah
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk TextField (TIDAK BERUBAH)
  Widget _buildTextField({
    required String label,
    required String hint,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        SizedBox(
          height: _textFieldHeight,
          child: TextField(
            obscureText: isPassword,
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
        ),
      ],
    );
  }

  // Widget helper untuk divider (TIDAK BERUBAH)
  Widget _buildDividerWithIcon() {
    return Row(
      children: [
        Expanded(child: Divider(color: _dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(
            Icons.restaurant_menu, 
            color: _dividerColor, 
            size: _iconSize, 
          ),
        ),
        Expanded(child: Divider(color: _dividerColor, thickness: 1)),
      ],
    );
  }



  void prosesRegistrasi() async {
    final response = await UserCreate(
     User(nama: namaCont.text, password: passwordCont.text, email: emailCont.text));
    if (response != null) {
      print(response.body.toString());
      if (response.statusCode == 200) {
        var jsonResp = json.decode(response.body);
        Navigator.pop(context, jsonResp['message']);
      } else {
        dialog(context, "${response.body.toString()}");
      }
    }
  }
}
