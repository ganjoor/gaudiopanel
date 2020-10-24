import 'dart:convert';

import 'package:gaudiopanel/services/gservice-address.dart';
import 'package:gaudiopanel/services/storage-service.dart';
import 'package:http/http.dart' as http;
import 'package:gaudiopanel/models/auth/logged-on-user-model.dart';

class AuthService {
  final StorageService _storageService = StorageService();

  /// Login
  ///
  /// returns empty string is everything is ok otherwise the error string
  /// result is written in local storage
  Future<String> login(String username, String password) async {
    try {
      var apiRoot = GServiceAddress.Url;
      final http.Response response = await http.post(
        '$apiRoot/api/users/login',
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

  ///is user logged on?
  ///
  Future<bool> get isLoggedOn async {
    return (await _storageService.userInfo) != null;
  }

  /// renew user session
  ///
  /// returns empty string is everything is ok otherwise the error string
  /// result is written in local storage
  Future<String> relogin() async {
    try {
      LoggedOnUserModel oldLoginInfo = await _storageService.userInfo;
      var sessionId = oldLoginInfo.sessionId;
      var apiRoot = GServiceAddress.Url;
      final http.Response response = await http.put(
        '$apiRoot/api/users/relogin/$sessionId',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
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

  /// logout
  ///
  Future<String> logout() async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      await _storageService.delUserInfo();
      var userId = userInfo.user.id;
      var sessionId = userInfo.sessionId;
      var apiRoot = GServiceAddress.Url;
      final http.Response response = await http.delete(
        '$apiRoot/api/users/delsession?userId=$userId&sessionId=$sessionId',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode != 200) {
        return response.body;
      }
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
          e.toString();
    }
    return '';
  }
}
