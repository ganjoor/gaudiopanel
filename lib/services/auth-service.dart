import 'dart:convert';

import 'package:gaudiopanel/services/storage-service.dart';
import 'package:http/http.dart' as http;
import 'package:gaudiopanel/models/auth/logged-on-user-model.dart';

class AuthService {
  final StorageService _storageService = StorageService();

  Future<String> login(String username, String password) async {
    try {
      final http.Response response = await http.post(
        'http://localhost:3439/api/users/login',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'clientAppName': 'پیشخان خوانشهای گنجور',
          'language': 'fa-IR'
        }),
      );

      if (response.statusCode == 200) {
        LoggedOnUserModel loginResponse =
            LoggedOnUserModel.fromJson(json.decode(response.body));
        await _storageService.setUserInfo(loginResponse);
      } else {
        return response.body;
      }
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
          e.toString();
    }
    return '';
  }
}
