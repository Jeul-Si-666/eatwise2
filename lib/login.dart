import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eatwise2/model/user.dart';
import 'package:eatwise2/page/home.dart' as Indexhome;
// import 'package:eatwise2/page/modul_pasien/signup.dart';
// import 'package:eatwise2/page/modul_pegawai/index.dart' as IndexPegawai;
import 'package:eatwise2/util/session.dart';
import 'package:eatwise2/util/util.dart';

import 'dart:developer' as developer;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/sign_up.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // --- ASET DESAIN DARI FIGMA ---
    final _formKey = GlobalKey<FormState>();
  TextEditingController namaCont = new TextEditingController();
  TextEditingController passCont = new TextEditingController();

  // Warna
  static const Color _backgroundColor = Color(0xFFAEB8AF); // Latar belakang baru
  static const Color _buttonColor = Color(0xFF549E61);
  static const Color _signupLinkColor = Color(0xFF13721D);
  static const Color _textFieldFillColor = Color(0x51D1D1D1); // 32% Opacity Grey
  static const Color _textColorBlack = Color(0xFF000000);
  static const Color _dividerColor = Color(0xFF000000); // Garis divider hitam

  // Gradien Teks (untuk 'EATWISE')
  static final Shader _titleGradient = const LinearGradient(
    colors: [Color(0xFF549A5B), Color(0xFF5F9D65), Color(0xFF13721D)],
    stops: [0.0, 0.44, 0.97],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0));

  // Style Teks
  static final TextStyle _titleStyle = GoogleFonts.padauk(
    fontSize: 59.21,
    fontWeight: FontWeight.w700, // Bold
    // Warna di-handle oleh ShaderMask
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

  // Style untuk teks di dalam TextField
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
    color: _signupLinkColor,
  );

  // Ukuran & Spacing
  static const double _sidePadding = 32.0;
  static const double _textFieldHeight = 60.0;
  static const double _buttonHeight = 60.0;
  static const double _buttonRadius = 55.0;
  static const double _textFieldRadius = 10.0;
  static const double _iconSize = 32.0; // Ukuran ikon Material Design

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
                'Continue Your Journey',
                textAlign: TextAlign.center,
                style: _subtitleStyle,
              ),
              const SizedBox(height: 12),

              // 4. Deskripsi
              Text(
                'lets track meals, calorie, and more for your health',
                textAlign: TextAlign.center,
                style: _bodyStyle,
              ),
              const SizedBox(height: 38),

              // 5. Form Input Email
              // _buildTextField(
              //   label: 'Email', 
              //   hint: '',
              //   ),
               TextFormField(
              controller: namaCont,
              decoration: InputDecoration(
                  icon: Icon(Icons.person), hintText: 'Username'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Tidak boleh kosong';
                }
                return null;
              },
            ),
              const SizedBox(height: 24),

              // 6. Form Input Password
              // _buildTextField(label: 'Password', hint: '', isPassword: true),
               TextFormField(
              controller: passCont,
              obscureText: true,
              decoration: InputDecoration(
                  icon: Icon(Icons.vpn_key), hintText: 'Password'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Tidak boleh kosong';
                }
                return null;
              },
            ),
              const SizedBox(height: 40),

              // 7. Tombol Login
              ElevatedButton(
                onPressed: tes_logn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  fixedSize: const Size(double.infinity, _buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_buttonRadius),
                  ),
                  elevation: 0,
                ),
                child: Text('Login', style: _buttonTextStyle),
              ),
              const SizedBox(height: 32),

              // 8. Divider dengan Ikon (Ikon Material Design)
              _buildDividerWithIcon(),
              const SizedBox(height: 32),

              // 9. Link ke Sign Up (menggunakan RichText agar presisi)
              Align(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    text: "Don't Have Account ? ",
                    style: _bottomTextStyle,
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: _bottomLinkStyle,
                        // TODO: Tambahkan recognizer untuk navigasi
                         recognizer: TapGestureRecognizer()..onTap = () {
                         print('Ke Halaman Sign In');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage()), // Ganti dengan halaman Sign Up Anda
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

  // Widget helper untuk TextField
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

  // Widget helper untuk divider dengan ikon Material Design
  Widget _buildDividerWithIcon() {
    return Row(
      children: [
        Expanded(child: Divider(color: _dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(
            Icons.restaurant_menu, // Ikon garpu & sendok dari Material Design Icons
            color: _dividerColor, // Warna ikon mengikuti warna divider
            size: _iconSize, // Ukuran ikon
          ),
        ),
        Expanded(child: Divider(color: _dividerColor, thickness: 1)),
      ],
    );
  }
  void tes_logn() async {
  print('--- [BISMILLAH DEBUG START] ---');

  try {
    // Kirim data ke server
    final response = await login(
      User(
        idUser: '', 
        nama: namaCont.text, // Pastikan ini sesuai dengan $data->nama di PHP
        password: passCont.text, 
        email: ""
      )
    );

    // 1. Cek apakah koneksi ke server berhasil (tidak null & body ada)
    if (response == null || response.body.isEmpty) {
      dialog(context, "Tidak ada respon dari server, pastikan koneksi internet lancar");
      return;
    }

    print("Isi Respon Server: ${response.body}");
    
    // Decode JSON
    var jsonResp = json.decode(response.body);

    // 2. Cek Status Code dari PHP (200 OK)
    if (response.statusCode == 200) {
      
      // Cek apakah object 'user' benar-benar ada
      if (jsonResp['user'] != null) {
        var userData = jsonResp['user'];
        
        print("Data User Ditemukan: " + userData.toString());

        // Simpan sesi user
        // Pastikan key string ('id', 'username', 'email') sesuai kolom database MySQL
        createUserSessionx(
          userData['id']?.toString() ?? "", 
          userData['username']?.toString() ?? "User", 
          // Password sebaiknya jangan disimpan di session hp jika tidak terpaksa (keamanan)
          // Tapi jika logic 'createPegawaiSession' butuh, biarkan string kosong jika null
          userData['password']?.toString() ?? "", 
          userData['email']?.toString() ?? ""
        );

        // Pindah halaman (Alhamdulillah sukses)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Indexhome.HomeContent())
        );
        
        print("Login berhasil, Alhamdulillah");
        
      } else {
        dialog(context, "Data user tidak ditemukan dalam respon");
      }
    } else {
      // Jika status code 401 (Gagal Login) atau 500 (Error DB)
      dialog(context, jsonResp['message'] ?? "Login Gagal");
    }

  } catch (e) {
    print("Error: $e");
    dialog(context, "Terjadi kesalahan sistem: $e");
  }
}
}
