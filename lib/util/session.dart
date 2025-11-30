import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatwise2/model/user.dart';

const String IS_LOGIN = 'IS_LOGIN';
const String JENIS_LOGIN = 'JENIS_LOGIN';
const String ID_User = 'ID_User';
const String NAMA = 'NAMA';
const String PASSWORD = 'PASSWORD';
const String EMAIL = 'EMAIL';

Future CreateUserSession(User user) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(IS_LOGIN, true);
  prefs.setString(ID_User, user.idUser ?? '');
  prefs.setString(NAMA, user.username ?? '');
  prefs.setString(PASSWORD, user.password ?? '');
  prefs.setString(EMAIL, user.email ?? '');
  return true;
}

Future createUserSessionx(String id, String username, String pwd, String email) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool(IS_LOGIN, true);
  prefs.setString(ID_User, id);
  prefs.setString(NAMA, username);
  prefs.setString(PASSWORD, pwd);
  prefs.setString(EMAIL, email);
  return true;
}

Future clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.clear();
  return true;
}