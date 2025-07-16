import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoginService {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/signup_data.json');

    if (!await file.exists()) {
      return null;
    }

    final contents = await file.readAsString();
    final List<dynamic> users = json.decode(contents);

    final user = users.cast<Map<String, dynamic>>().firstWhere(
      (u) =>
          u['email'].toString().trim().toLowerCase() ==
              email.trim().toLowerCase() &&
          u['password'].toString().trim() == password.trim(),
      orElse: () => {},
    );

    if (user.isEmpty) {
      return null;
    } else {
      return user;
    }
  }
}
