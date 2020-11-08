import 'dart:convert';
import 'dart:io';

import 'package:gaudiopanel/models/auth/logged-on-user-model.dart';
import 'package:gaudiopanel/models/common/pagination-metadata.dart';
import 'package:gaudiopanel/models/narration/narration-verse-sync.dart';
import 'package:gaudiopanel/models/narration/poem-narration-viewmodel.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/narration/uploaded-item-viewmodel.dart';
import 'package:gaudiopanel/models/narration/user-narration-profile-viewmodel.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:gaudiopanel/services/gservice-address.dart';
import 'package:gaudiopanel/services/storage-service.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

class NarrationService {
  final StorageService _storageService = StorageService();

  /// Get Narrations
  ///
  Future<PaginatedItemsResponseModel<PoemNarrationViewModel>> getNarrations(
      int pageNumber,
      int pageSize,
      bool allUsers,
      int status,
      bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return PaginatedItemsResponseModel<PoemNarrationViewModel>(
            error: 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.get(
          '$apiRoot/api/audio?PageNumber=$pageNumber&PageSize=$pageSize&allUsers=$allUsers&status=$status',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
          });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return PaginatedItemsResponseModel<PoemNarrationViewModel>(
              error: errSessionRenewal);
        }
        return await getNarrations(
            pageNumber, pageSize, allUsers, status, true);
      }

      List<PoemNarrationViewModel> ret = [];
      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(PoemNarrationViewModel.fromJson(item));
        }
        return PaginatedItemsResponseModel<PoemNarrationViewModel>(
            items: ret,
            paginationMetadata: PaginationMetadata.fromJson(
                json.decode(response.headers['paging-headers'])),
            error: '');
      } else {
        return PaginatedItemsResponseModel<PoemNarrationViewModel>(
            error: response.body);
      }
    } catch (e) {
      return PaginatedItemsResponseModel<PoemNarrationViewModel>(
          error: 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// updates an existing narration
  ///
  ///
  Future<Tuple2<PoemNarrationViewModel, String>> updateNarration(
      PoemNarrationViewModel narration, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<PoemNarrationViewModel, String>(
            null, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      int id = narration.id;
      http.Response response = await http.put('$apiRoot/api/audio/$id',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
          },
          body: jsonEncode(narration.toJson()));

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<PoemNarrationViewModel, String>(
              null, errSessionRenewal);
        }
        return await updateNarration(narration, true);
      }

      if (response.statusCode == 200) {
        PoemNarrationViewModel ret =
            PoemNarrationViewModel.fromJson(json.decode(response.body));

        return Tuple2<PoemNarrationViewModel, String>(ret, '');
      } else {
        return Tuple2<PoemNarrationViewModel, String>(null, response.body);
      }
    } catch (e) {
      return Tuple2<PoemNarrationViewModel, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// Get Profiles
  ///
  ///returns a Tuple2, if any error occurs Items1 is null and Item2 contains the error message
  ///Items1 is the actual response if the call is successful
  Future<Tuple2<List<UserNarrationProfileViewModel>, String>> getProfiles(
      bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<List<UserNarrationProfileViewModel>, String>(
            null, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response =
          await http.get('$apiRoot/api/audio/profile', headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
      });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<List<UserNarrationProfileViewModel>, String>(
              null, errSessionRenewal);
        }
        return await getProfiles(true);
      }

      List<UserNarrationProfileViewModel> ret = [];
      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(UserNarrationProfileViewModel.fromJson(item));
        }
        return Tuple2<List<UserNarrationProfileViewModel>, String>(ret, '');
      } else {
        return Tuple2<List<UserNarrationProfileViewModel>, String>(
            null, response.body);
      }
    } catch (e) {
      return Tuple2<List<UserNarrationProfileViewModel>, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// adds a new profile
  ///
  ///
  Future<Tuple2<UserNarrationProfileViewModel, String>> addProfile(
      UserNarrationProfileViewModel profile, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<UserNarrationProfileViewModel, String>(
            null, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.post('$apiRoot/api/audio/profile',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
          },
          body: jsonEncode(profile.toJson()));

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<UserNarrationProfileViewModel, String>(
              null, errSessionRenewal);
        }
        return await addProfile(profile, true);
      }

      if (response.statusCode == 200) {
        UserNarrationProfileViewModel ret =
            UserNarrationProfileViewModel.fromJson(json.decode(response.body));

        return Tuple2<UserNarrationProfileViewModel, String>(ret, '');
      } else {
        return Tuple2<UserNarrationProfileViewModel, String>(
            null, response.body);
      }
    } catch (e) {
      return Tuple2<UserNarrationProfileViewModel, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// updates an existing profile
  ///
  ///
  Future<Tuple2<UserNarrationProfileViewModel, String>> updateProfile(
      UserNarrationProfileViewModel profile, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<UserNarrationProfileViewModel, String>(
            null, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.put('$apiRoot/api/audio/profile',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
          },
          body: jsonEncode(profile.toJson()));

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<UserNarrationProfileViewModel, String>(
              null, errSessionRenewal);
        }
        return await updateProfile(profile, true);
      }

      if (response.statusCode == 200) {
        UserNarrationProfileViewModel ret =
            UserNarrationProfileViewModel.fromJson(json.decode(response.body));

        return Tuple2<UserNarrationProfileViewModel, String>(ret, '');
      } else {
        return Tuple2<UserNarrationProfileViewModel, String>(
            null, response.body);
      }
    } catch (e) {
      return Tuple2<UserNarrationProfileViewModel, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// delete an existing profile
  ///
  ///
  Future<Tuple2<bool, String>> deleteProfile(String id, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<bool, String>(false, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.delete(
        '$apiRoot/api/audio/profile/$id',
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
        return await deleteProfile(id, true);
      }

      if (response.statusCode == 200) {
        return Tuple2<bool, String>(json.decode(response.body), '');
      } else {
        return Tuple2<bool, String>(false, response.body);
      }
    } catch (e) {
      return Tuple2<bool, String>(
          false,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// Get User Uploads
  ///
  /// allUsers parameter is currently ignored
  Future<PaginatedItemsResponseModel<UploadedItemViewModel>> getUploads(
      int pageNumber, int pageSize, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return PaginatedItemsResponseModel<UploadedItemViewModel>(
            error: 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.get(
          '$apiRoot/api/audio/uploads?PageNumber=$pageNumber&PageSize=$pageSize',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
          });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return PaginatedItemsResponseModel<UploadedItemViewModel>(
              error: errSessionRenewal);
        }
        return await getUploads(pageNumber, pageSize, true);
      }

      List<UploadedItemViewModel> ret = [];
      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(UploadedItemViewModel.fromJson(item));
        }
        return PaginatedItemsResponseModel<UploadedItemViewModel>(
            items: ret,
            paginationMetadata: PaginationMetadata.fromJson(
                json.decode(response.headers['paging-headers'])),
            error: '');
      } else {
        return PaginatedItemsResponseModel<UploadedItemViewModel>(
            error: response.body);
      }
    } catch (e) {
      return PaginatedItemsResponseModel<UploadedItemViewModel>(
          error: 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  Future<Tuple2<List<NarrationVerseSync>, String>> getVerses(
      int id, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<List<NarrationVerseSync>, String>(
            null, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response =
          await http.get('$apiRoot/api/audio/verses/$id', headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
      });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<List<NarrationVerseSync>, String>(
              null, errSessionRenewal);
        }
        return await getVerses(id, true);
      }

      List<NarrationVerseSync> ret = [];
      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(NarrationVerseSync.fromJson(item));
        }
        return Tuple2<List<NarrationVerseSync>, String>(ret, '');
      } else {
        return Tuple2<List<NarrationVerseSync>, String>(null, response.body);
      }
    } catch (e) {
      return Tuple2<List<NarrationVerseSync>, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  ///Get mp3 url
  ///
  /// for the player
  String getAudioFileUrl(int id) {
    var apiRoot = GServiceAddress.Url;
    return '$apiRoot/api/audio/file/$id.mp3';
  }
}
