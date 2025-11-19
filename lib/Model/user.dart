import 'dart:convert' ;
import 'package:http/http.dart';
//import 'package:good_health/util/config.dart';
import 'package:http/http.dart' as http;
import 'package:eatwise2/util/config.dart';

class User {
 final String? idUser, nama, password, email;
  // final Pasien? idPasien;

  User({
    this.idUser, 
    required this.nama, 
    required this.password, 
    this.email
    });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        idUser: json['id_User'],
        nama: json['nama'],
        password: json['password'],
        email: json['email']);
  }
}

List<User> UserFromJson(jsonData) {
  List<User> result =
      List<User>.from(jsonData.map((item) => User.fromJson(item)));

  return result;
}

// register User (POST)
Future UserCreate(User User) async {
  //String route = AppConfig.API_ENDPOINT + "/User/create.ppassword";
  try {
    final response = await http.post(Uri.parse('${AppConfig.baseUrl}/register.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {'nama': User.nama, 'password': User.password, 'email': User.email}));

    return response;
  } catch (e) {
    print("Error : ${e.toString()}");
    return null;
  }
}
Future<Response?> login(User user) async {
  //String route = AppConfig.API_ENDPOINT + "/login.php";
  try {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/login.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'username': user.nama, 'password': user.password}),
    );


    print(response.body.toString());
    return response;
  } catch (e) {
    print("Error : ${e.toString()}");
    return null;
  }
}