import 'package:eatwise2/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatwise2/util/session.dart';
import 'package:eatwise2/login.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(primarySwatch: const Color.fromARGB(255, 255, 255, 255)),
      home: FutureBuilder(
        future: _loadSession(),
        builder: (context, snapshot) {
          
          late Widget result;
          late final SharedPreferences prefs = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            
            result = Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (prefs.getBool(IS_LOGIN) ?? false) {
                // if (prefs.getString(JENIS_LOGIN) ==
                //     jenisLogin.PASIEN.toString()) {
                //   result = IndexPasien.IndexPage();
                // } else {
                //   // result home pegawai
                //   result = IndexPegawai.IndexPage();
                // }
                result = SignUpPage();
              } else {
                  // result = RegisterScreen();
                 result = LoginPage();
                //  return Container(child: Text('Error..'));
              }
            } else {
              // result = SignUpPage();
              return Container(child: Text('Error..'));
            }
          }

          return result;
        },
      ),
    );
  }

  Future _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  }
}
