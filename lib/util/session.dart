import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatwise2/Model/user.dart';


const IS_LOGIN = 'IS_LOGIN';
const JENIS_LOGIN = 'JENIS_LOGIN';
const ID_User = 'ID_User';
const NAMA = 'NAMA';
const password = 'password';
const EMAIL = 'EMAIL';

// ignore: camel_case_types
// enum jenisLogin { User, PEGAWAI }

Future CreateUserSession(User User) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(IS_LOGIN, true);
  prefs.setString(ID_User, User.idUser ?? '');
  prefs.setString(NAMA, User.nama ?? '');
  prefs.setString(password, User.password ?? '');
  prefs.setString(EMAIL, User.email ?? '');
  // prefs.setString(JENIS_LOGIN, jenisLogin.User.toString());
  return true;
}

Future createUserSessionx(String id, String nama, String password, String email) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(IS_LOGIN, true);
  prefs.setString(ID_User, id);
  prefs.setString(NAMA, nama);
  prefs.setString(password, password);
  prefs.setString(EMAIL, email);
  // prefs.setString(JENIS_LOGIN, jenisLogin.User.toString());
  return true;
}

Future createPegawaiSession(String username) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(IS_LOGIN, true);
  prefs.setString(NAMA, username);
  // prefs.setString(JENIS_LOGIN, jenisLogin.PEGAWAI.toString());
  return true;
}

Future clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.clear();
  return true;
}
