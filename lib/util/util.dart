import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eatwise2/login.dart';
import 'package:eatwise2/util/session.dart';
// import 'package:goodhealth/page/login.dart';
// import 'package:goodhealth/util/session.dart';



dialog(_context, msg, {title}) {
  showDialog(
    context: _context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title ?? 'Perhatian!'),
        content: Text(msg.toString()),
      );
    },
  );
}

// Template button lebar utk posisi bottomNavigationBar
Widget largetButton(
    {String label = "Simpan", IconData? iconData, Function? onPressed}) {
  iconData = iconData ?? Icons.done_all;
  return Container(
    height: 60,
    width: double.infinity,
    child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(elevation: 4.0, backgroundColor: Colors.blue, 
                                          disabledForegroundColor: Colors.grey.withOpacity(0.38), 
                                          disabledBackgroundColor: Colors.grey.withOpacity(0.12),),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        
        icon: Icon(iconData, color: Colors.white),
       
        onPressed: (){ }),
  );
}

// fungsi format tulisan rupiah
String toRupiah(int val) {
  final formatter = NumberFormat.currency(locale: 'ID');
        return formatter.format(val);
}

void logOut(BuildContext context) {
  clearSession().then((value) => Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return LoginPage();
      }, transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return new SlideTransition(
          position: new Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      }),
      (route) => false));
}
