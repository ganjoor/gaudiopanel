import 'dart:convert';
import 'dart:io';

import 'package:gaudiopanel/models/auth/logged-on-user-model.dart';
import 'package:gaudiopanel/models/common/pagination-metadata.dart';
import 'package:gaudiopanel/models/recitation/recitation-verse-sync.dart';
import 'package:gaudiopanel/models/recitation/recitation-viewmodel.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/recitation/uploaded-item-viewmodel.dart';
import 'package:gaudiopanel/models/recitation/user-recitation-profile-viewmodel.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:gaudiopanel/services/gservice-address.dart';
import 'package:gaudiopanel/services/storage-service.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

class RecitationService {
  final StorageService _storageService = StorageService();

  /// Get Narrations
  ///
  Future<PaginatedItemsResponseModel<RecitationViewModel>> getRecitations(
      int pageNumber,
      int pageSize,
      bool allUsers,
      int status,
      String searchTerm,
      bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return PaginatedItemsResponseModel<RecitationViewModel>(
            error: 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.get(
          '$apiRoot/api/audio?PageNumber=$pageNumber&PageSize=$pageSize&allUsers=$allUsers&status=$status&searchTerm=$searchTerm',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
          });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return PaginatedItemsResponseModel<RecitationViewModel>(
              error: errSessionRenewal);
        }
        return await getRecitations(
            pageNumber, pageSize, allUsers, status, searchTerm, true);
      }

      List<RecitationViewModel> ret = [];
      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(RecitationViewModel.fromJson(item));
        }
        return PaginatedItemsResponseModel<RecitationViewModel>(
            items: ret,
            paginationMetadata: PaginationMetadata.fromJson(
                json.decode(response.headers['paging-headers'])),
            error: '');
      } else {
        return PaginatedItemsResponseModel<RecitationViewModel>(
            error: 'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return PaginatedItemsResponseModel<RecitationViewModel>(
          error: 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// updates an existing narration
  ///
  ///
  Future<Tuple2<RecitationViewModel, String>> updateRecitation(
      RecitationViewModel narration, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<RecitationViewModel, String>(
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
          return Tuple2<RecitationViewModel, String>(null, errSessionRenewal);
        }
        return await updateRecitation(narration, true);
      }

      if (response.statusCode == 200) {
        RecitationViewModel ret =
            RecitationViewModel.fromJson(json.decode(response.body));

        return Tuple2<RecitationViewModel, String>(ret, '');
      } else {
        return Tuple2<RecitationViewModel, String>(
            null,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<RecitationViewModel, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  ///moderate narration
  ///
  ///
  Future<Tuple2<RecitationViewModel, String>> moderateRecitation(int id,
      RecitationModerationResult res, String message, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<RecitationViewModel, String>(
            null, 'کاربر وارد سیستم نشده است.');
      }

      int mres = res == RecitationModerationResult.MetadataNeedsFixation
          ? 0
          : res == RecitationModerationResult.Approve
              ? 1
              : 2;
      RecitationModerateViewModel model =
          RecitationModerateViewModel(result: mres, message: message);
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.put('$apiRoot/api/audio/moderate/$id',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
          },
          body: jsonEncode(model.toJson()));

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<RecitationViewModel, String>(null, errSessionRenewal);
        }
        return await moderateRecitation(id, res, message, true);
      }

      if (response.statusCode == 200) {
        RecitationViewModel ret =
            RecitationViewModel.fromJson(json.decode(response.body));

        return Tuple2<RecitationViewModel, String>(ret, '');
      } else {
        return Tuple2<RecitationViewModel, String>(
            null,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<RecitationViewModel, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// delete an existing recitation
  ///
  ///
  Future<Tuple2<bool, String>> deleteRecitation(int id, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<bool, String>(false, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.delete(
        '$apiRoot/api/audio/$id',
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
        return await deleteRecitation(id, true);
      }

      if (response.statusCode == 200) {
        return Tuple2<bool, String>(json.decode(response.body), '');
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

  /// Get Profiles
  ///
  ///returns a Tuple2, if any error occurs Items1 is null and Item2 contains the error message
  ///Items1 is the actual response if the call is successful
  Future<Tuple2<List<UserRecitationProfileViewModel>, String>> getProfiles(
      String artistName, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<List<UserRecitationProfileViewModel>, String>(
            null, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http
          .get('$apiRoot/api/audio/profile?artistName=$artistName', headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
      });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<List<UserRecitationProfileViewModel>, String>(
              null, errSessionRenewal);
        }
        return await getProfiles(artistName, true);
      }

      List<UserRecitationProfileViewModel> ret = [];
      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(UserRecitationProfileViewModel.fromJson(item));
        }
        return Tuple2<List<UserRecitationProfileViewModel>, String>(ret, '');
      } else {
        return Tuple2<List<UserRecitationProfileViewModel>, String>(
            null,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<List<UserRecitationProfileViewModel>, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// Get User Default Profile
  ///
  ///returns a Tuple2, if any error occurs Items1 is null and Item2 contains the error message
  ///Items1 is the actual response if the call is successful
  Future<Tuple2<UserRecitationProfileViewModel, String>> getDefProfile(
      bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<UserRecitationProfileViewModel, String>(
            null, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response =
          await http.get('$apiRoot/api/audio/profile/def', headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
      });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<UserRecitationProfileViewModel, String>(
              null, errSessionRenewal);
        }
        return await getDefProfile(true);
      }
      if (response.statusCode == 200) {
        return Tuple2<UserRecitationProfileViewModel, String>(
            UserRecitationProfileViewModel.fromJson(json.decode(response.body)),
            '');
      } else {
        return Tuple2<UserRecitationProfileViewModel, String>(
            null,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<UserRecitationProfileViewModel, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// adds a new profile
  ///
  ///
  Future<Tuple2<UserRecitationProfileViewModel, String>> addProfile(
      UserRecitationProfileViewModel profile, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<UserRecitationProfileViewModel, String>(
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
          return Tuple2<UserRecitationProfileViewModel, String>(
              null, errSessionRenewal);
        }
        return await addProfile(profile, true);
      }

      if (response.statusCode == 200) {
        UserRecitationProfileViewModel ret =
            UserRecitationProfileViewModel.fromJson(json.decode(response.body));

        return Tuple2<UserRecitationProfileViewModel, String>(ret, '');
      } else {
        return Tuple2<UserRecitationProfileViewModel, String>(
            null,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<UserRecitationProfileViewModel, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// updates an existing profile
  ///
  ///
  Future<Tuple2<UserRecitationProfileViewModel, String>> updateProfile(
      UserRecitationProfileViewModel profile, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<UserRecitationProfileViewModel, String>(
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
          return Tuple2<UserRecitationProfileViewModel, String>(
              null, errSessionRenewal);
        }
        return await updateProfile(profile, true);
      }

      if (response.statusCode == 200) {
        UserRecitationProfileViewModel ret =
            UserRecitationProfileViewModel.fromJson(json.decode(response.body));

        return Tuple2<UserRecitationProfileViewModel, String>(ret, '');
      } else {
        return Tuple2<UserRecitationProfileViewModel, String>(
            null,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<UserRecitationProfileViewModel, String>(
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
            error: 'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return PaginatedItemsResponseModel<UploadedItemViewModel>(
          error: 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  Future<Tuple2<List<RecitationVerseSync>, String>> getVerses(
      int id, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<List<RecitationVerseSync>, String>(
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
          return Tuple2<List<RecitationVerseSync>, String>(
              null, errSessionRenewal);
        }
        return await getVerses(id, true);
      }

      List<RecitationVerseSync> ret = [];
      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(RecitationVerseSync.fromJson(item));
        }
        return Tuple2<List<RecitationVerseSync>, String>(ret, '');
      } else {
        return Tuple2<List<RecitationVerseSync>, String>(
            null,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<List<RecitationVerseSync>, String>(
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

  /// Transfer Recitations Ownership
  ///
  ///
  Future<Tuple2<int, String>> transferRecitationsOwnership(
      String targetEmailAddress, String artistName, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<int, String>(0, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.put(
        '$apiRoot/api/audio/chown?targetEmailAddress=$targetEmailAddress&artistName=$artistName',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
        },
      );

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<int, String>(0, errSessionRenewal);
        }
        return await transferRecitationsOwnership(
            targetEmailAddress, artistName, true);
      }

      if (response.statusCode == 200) {
        int ret = json.decode(response.body);

        return Tuple2<int, String>(ret, '');
      } else {
        return Tuple2<int, String>(
            0,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<int, String>(
          0,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// Makes recitations of فریدون فرح‌اندوز first recitations
  ///
  ///
  Future<Tuple2<int, String>> makeFFRecitationsFirst(bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<int, String>(0, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response = await http.put(
        '$apiRoot/api/audio/ff',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
        },
      );

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<int, String>(0, errSessionRenewal);
        }
        return await makeFFRecitationsFirst(true);
      }

      if (response.statusCode == 200) {
        int ret = json.decode(response.body);

        return Tuple2<int, String>(ret, '');
      } else {
        return Tuple2<int, String>(
            0,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<int, String>(
          0,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// Get Synchronization Queue
  ///
  ///returns a Tuple2, if any error occurs Items1 is null and Item2 contains the error message
  ///Items1 is the actual response if the call is successful
  Future<Tuple2<List<RecitationViewModel>, String>> getSynchronizationQueue(
      bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return Tuple2<List<RecitationViewModel>, String>(
            null, 'کاربر وارد سیستم نشده است.');
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response =
          await http.get('$apiRoot/api/audio/syncqueue', headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
      });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<List<RecitationViewModel>, String>(
              null, errSessionRenewal);
        }
        return await getSynchronizationQueue(true);
      }

      List<RecitationViewModel> ret = [];
      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(RecitationViewModel.fromJson(item));
        }
        return Tuple2<List<RecitationViewModel>, String>(ret, '');
      } else {
        return Tuple2<List<RecitationViewModel>, String>(
            null,
            'کد برگشتی: ' +
                response.statusCode.toString() +
                ' ' +
                response.body);
      }
    } catch (e) {
      return Tuple2<List<RecitationViewModel>, String>(
          null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
              e.toString());
    }
  }

  /// Retry publish
  ///
  ///returns error string if any error occurs
  ///retrurns empty response if the call is successful
  Future<String> retryPublish(bool error401) async {
    try {
      LoggedOnUserModel userInfo = await _storageService.userInfo;
      if (userInfo == null) {
        return 'کاربر وارد سیستم نشده است.';
      }
      var apiRoot = GServiceAddress.Url;
      http.Response response =
          await http.post('$apiRoot/api/audio/retrypublish', headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
      });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return errSessionRenewal;
        }
        return await retryPublish(true);
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
}
