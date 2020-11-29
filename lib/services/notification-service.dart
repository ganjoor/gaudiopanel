import 'dart:convert';
import 'dart:io';

import 'package:gaudiopanel/models/auth/logged-on-user-model.dart';
import 'package:gaudiopanel/models/notifications/ruser-notification-viewmodel.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:gaudiopanel/services/gservice-address.dart';
import 'package:gaudiopanel/services/storage-service.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final StorageService _storageService = StorageService();

  /// Get Notifications
  ///
  ///returns a Tuple2, if any error occurs Items1 is null and Item2 contains the error message
  ///Items1 is the actual response if the call is successful
  Future<Tuple2<List<RUserNotificationViewModel>, String>> getNotifications(
      bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<List<RUserNotificationViewModel>, String>(
            null, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response =
          await http.get('$apiRoot/api/notifications', headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
      });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<List<RUserNotificationViewModel>, String>(
              null, errSessionRenewal);
        }
        return await getNotifications(true);
      }

      List<RUserNotificationViewModel> ret = [];
      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(RUserNotificationViewModel.fromJson(item));
        }
        return Tuple2<List<RUserNotificationViewModel>, String>(ret, '');
      } else {
        return Tuple2<List<RUserNotificationViewModel>, String>(
            null,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<List<RUserNotificationViewModel>, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// switches notification status
  ///
  /// returns non empty string if fails
  Future<String> switchStatus(String id, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return 'کاربر وارد سیستم نشده است.';
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.put(
        '$apiRoot/api/notifications/$id',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
        },
      );

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return errSessionRenewal;
        }
        return await switchStatus(id, true);
      }

      if (response.statusCode == 200) {
        return '';
      } else {
        return 'کد برگشتی: ' +
            response.statusCode.toString() +
            ' ' +
            response.body;
      }
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
          e.toString();
    }
  }

  /// delete a notification
  ///
  ///
  Future<Tuple2<bool, String>> deleteNotification(
      String id, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<bool, String>(false, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.delete(
        '$apiRoot/api/notifications/$id',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
        },
      );

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<bool, String>(false, errSessionRenewal);
        }
        return await deleteNotification(id, true);
      }

      if (response.statusCode == 200) {
        return Tuple2<bool, String>(true, '');
      } else {
        return Tuple2<bool, String>(
            false,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<bool, String>(
          false,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }
}
