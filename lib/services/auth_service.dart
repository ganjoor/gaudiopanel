import 'dart:convert';
import 'dart:io';

import 'package:gaudiopanel/models/auth/rverify_queue_type.dart';
import 'package:gaudiopanel/services/gservice_address.dart';
import 'package:gaudiopanel/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:gaudiopanel/models/auth/logged_on_user_model.dart';
import 'package:tuple/tuple.dart';

class AuthService {
  final StorageService _storageService = StorageService();

  /// Login
  ///
  /// returns empty string is everything is ok otherwise the error string
  /// result is written in local storage
  Future<String> login(String username, String password) async {
    try {
      var apiRoot = GServiceAddress.url;
      final http.Response response = await http.post(
        Uri.parse('$apiRoot/api/users/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'clientAppName': 'Ganjoor Recitations Flutter Panel',
          'language': 'fa-IR'
        }),
      );

      if (response.statusCode == 200) {
        LoggedOnUserModel? loginResponse =
            LoggedOnUserModel.fromJson(json.decode(response.body));
        await _storageService.setUserInfo(loginResponse);
      } else {
        return response.body;
      }
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e';
    }
    return '';
  }

  ///is user logged on?
  ///
  Future<bool> get isLoggedOn async {
    return (await _storageService.userInfo) != null;
  }

  ///has user specified operation permission
  ///
  Future<bool> hasPermission(
      String securableItemShortName, String operationShortName) async {
    LoggedOnUserModel? userInfo = await _storageService.userInfo;
    var securableItems = userInfo!.securableItem
        .where((element) => element.shortName == securableItemShortName)
        .toList();
    if (securableItems.isNotEmpty) {
      var operations = securableItems[0]
          .operations
          .where((element) => element.shortName == operationShortName)
          .toList();
      if (operations.isNotEmpty) {
        return operations[0].status;
      }
    }
    return false;
  }

  /// renew user session
  ///
  /// returns empty string is everything is ok otherwise the error string
  /// result is written in local storage
  Future<String> relogin() async {
    try {
      LoggedOnUserModel? oldLoginInfo = await _storageService.userInfo;
      var sessionId = oldLoginInfo!.sessionId;
      var apiRoot = GServiceAddress.url;
      final http.Response response = await http.put(
        Uri.parse('$apiRoot/api/users/relogin/$sessionId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        LoggedOnUserModel? loginResponse =
            LoggedOnUserModel.fromJson(json.decode(response.body));
        await _storageService.setUserInfo(loginResponse);
      } else {
        return response.body;
      }
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e';
    }
    return '';
  }

  /// logout
  ///
  Future<String> logout() async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      await _storageService.delUserInfo();
      var userId = userInfo!.user.id;
      var sessionId = userInfo.sessionId;
      var apiRoot = GServiceAddress.url;
      final http.Response response = await http.delete(
        Uri.parse(
            '$apiRoot/api/users/delsession?userId=$userId&sessionId=$sessionId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ${userInfo.token}'
        },
      );

      if (response.statusCode != 200) {
        return response.body;
      }
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e';
    }
    return '';
  }

  ///Get a captcha image id
  ///
  /// item2 contains error message if occurs any
  Future<Tuple2<String, String>> getACaptchaImageId() async {
    try {
      var apiRoot = GServiceAddress.url;
      http.Response response = await http
          .get(Uri.parse('$apiRoot/api/users/captchaimage'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        return Tuple2<String, String>(json.decode(response.body), '');
      } else {
        return Tuple2<String, String>(
            '', 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<String, String>(
          '', 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// Signup phase 1 (unverified)
  ///
  ///returns error message if any happens
  Future<String> signupUnverified(
      String email, String captchaImageId, String captchaValue) async {
    try {
      var apiRoot = GServiceAddress.url;
      final http.Response response = await http.post(
        Uri.parse('$apiRoot/api/users/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'clientAppName': 'Ganjoor Recitations Flutter Panel',
          'language': 'fa-IR',
          'captchaImageId': captchaImageId,
          'captchaValue': captchaValue,
          'callbackUrl': ''
        }),
      );

      return response.body;
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e';
    }
  }

  ///sends a signup/forgotpassword secret and retrievs and email
  ///
  ///item2 contains the error if happens
  Future<Tuple2<String, String>> verifyEmail(bool signup, String secret) async {
    try {
      var apiRoot = GServiceAddress.url;
      int type =
          signup ? RVerifyQueueType.signUp : RVerifyQueueType.forgotPassword;
      final http.Response response = await http.get(
          Uri.parse('$apiRoot/api/users/verify?type=$type&secret=$secret'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });

      if (response.statusCode == 200) {
        return Tuple2<String, String>(json.decode(response.body), '');
      } else {
        return Tuple2<String, String>('', response.body);
      }
    } catch (e) {
      return Tuple2<String, String>(
          '', 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  ///Finalize Signup
  ///
  ///returns the error if occurs, empty if successfull
  Future<String> finalizeSignUp(String email, String secret, String password,
      String firstName, String sureName) async {
    try {
      var apiRoot = GServiceAddress.url;
      final http.Response response = await http.post(
        Uri.parse('$apiRoot/api/users/finalizesignup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'secret': secret,
          'password': password,
          'firstName': firstName,
          'sureName': sureName
        }),
      );

      if (response.statusCode == 200) {
        return '';
      } else {
        return response.body;
      }
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e';
    }
  }
}
