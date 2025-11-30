import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:eatwise2/model/user.dart';
import 'package:eatwise2/util/session.dart';
import 'package:eatwise2/util/util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatwise2/page/home_integrated.dart' as Indexhome;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameCont = TextEditingController();
  TextEditingController passCont = TextEditingController();

  static const Color _backgroundColor = Color(0xFFAEB8AF);
  static const Color _buttonColor = Color(0xFF549E61);
  static const Color _signupLinkColor = Color(0xFF13721D);
  static const Color _textColorBlack = Color(0xFF000000);
  static const Color _dividerColor = Color(0xFF000000);

  static final Shader _titleGradient = const LinearGradient(
    colors: [Color(0xFF549A5B), Color(0xFF5F9D65), Color(0xFF13721D)],
    stops: [0.0, 0.44, 0.97],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0));

  static final TextStyle _titleStyle = GoogleFonts.padauk(fontSize: 59.21, fontWeight: FontWeight.w700);
  static final TextStyle _subtitleStyle = GoogleFonts.inter(fontSize: 28.12, fontWeight: FontWeight.w500, color: _textColorBlack);
  static final TextStyle _bodyStyle = GoogleFonts.inter(fontSize: 18.62, fontWeight: FontWeight.w300, color: _textColorBlack);
  static final TextStyle _buttonTextStyle = GoogleFonts.inter(fontSize: 24.23, fontWeight: FontWeight.w400, color: _textColorBlack);
  static final TextStyle _bottomTextStyle = GoogleFonts.inter(fontSize: 17.88, fontWeight: FontWeight.w300, color: _textColorBlack);
  static final TextStyle _bottomLinkStyle = GoogleFonts.inter(fontSize: 17.88, fontWeight: FontWeight.w700, color: _signupLinkColor);

  static const double _sidePadding = 32.0;
  static const double _buttonHeight = 60.0;
  static const double _buttonRadius = 55.0;
  static const double _iconSize = 32.0;

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
              const SizedBox(height: 60),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => _titleGradient,
                child: Text('EATWISE', textAlign: TextAlign.center, style: _titleStyle),
              ),
              const SizedBox(height: 36),
              Text('Continue Your Journey', textAlign: TextAlign.center, style: _subtitleStyle),
              const SizedBox(height: 12),
              Text('lets track meals, calorie, and more for your health', textAlign: TextAlign.center, style: _bodyStyle),
              const SizedBox(height: 38),
              TextFormField(
                controller: usernameCont,
                decoration: const InputDecoration(icon: Icon(Icons.person), hintText: 'Username'),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: passCont,
                obscureText: true,
                decoration: const InputDecoration(icon: Icon(Icons.vpn_key), hintText: 'Password'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  fixedSize: const Size(double.infinity, _buttonHeight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
                  elevation: 0,
                ),
                child: Text('Login', style: _buttonTextStyle),
              ),
              const SizedBox(height: 32),
              _buildDividerWithIcon(),
              const SizedBox(height: 32),
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
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                        }
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDividerWithIcon() {
    return Row(
      children: [
        Expanded(child: Divider(color: _dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(Icons.restaurant_menu, color: _dividerColor, size: _iconSize),
        ),
        Expanded(child: Divider(color: _dividerColor, thickness: 1)),
      ],
    );
  }

  void handleLogin() async {
    try {
      final response = await login(User(username: usernameCont.text, password: passCont.text));

      if (response == null || response.body.isEmpty) {
        dialog(context, "Tidak ada respon dari server");
        return;
      }

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['user'] != null) {
          var userData = jsonData['user'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(IS_LOGIN, true);
          await prefs.setString('user_id', userData['id'].toString());
          await prefs.setString('username', userData['username'] ?? 'User');
          await prefs.setString('email', userData['email'] ?? '');

          createUserSessionx(
            userData['id']?.toString() ?? "",
            userData['username']?.toString() ?? "User",
            "",
            userData['email']?.toString() ?? "",
          );

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Indexhome.HomeContent()));
        } else {
          dialog(context, "Data user tidak ditemukan");
        }
      } else if (response.statusCode == 401) {
        final jsonData = json.decode(response.body);
        dialog(context, jsonData['message'] ?? "Username atau password salah");
      } else {
        dialog(context, "Terjadi kesalahan server");
      }
    } catch (e) {
      dialog(context, "Terjadi kesalahan: $e");
    }
  }
}