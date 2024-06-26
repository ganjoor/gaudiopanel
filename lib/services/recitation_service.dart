import 'dart:convert';
import 'dart:io';

import 'package:gaudiopanel/models/auth/logged_on_user_model.dart';
import 'package:gaudiopanel/models/common/pagination_metadata.dart';
import 'package:gaudiopanel/models/recitation/public_recitation_viewmodel.dart';
import 'package:gaudiopanel/models/recitation/recitation_verse_sync.dart';
import 'package:gaudiopanel/models/recitation/recitation_viewmodel.dart';
import 'package:gaudiopanel/models/common/paginated_items_response_model.dart';
import 'package:gaudiopanel/models/recitation/recitation_error_report_viewmodel.dart';
import 'package:gaudiopanel/models/recitation/uploaded_item_viewmodel.dart';
import 'package:gaudiopanel/models/recitation/user_recitation_profile_viewmodel.dart';
import 'package:gaudiopanel/services/auth_service.dart';
import 'package:gaudiopanel/services/gservice_address.dart';
import 'package:gaudiopanel/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

import '../models/recitation/recitation_publishing_tracker_viewmodel.dart';

class RecitationService {
  final StorageService _storageService = StorageService();

  /// Get Narrations
  ///
  Future<PaginatedItemsResponseModel<RecitationViewModel>> getRecitations(
      {required int pageNumber,
      required int pageSize,
      required bool allUsers,
      required int status,
      required String searchTerm,
      required bool mistakes,
      required bool commentaries,
      required bool error401}) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      int recitationType = commentaries ? 1 : 1000;
      http.Response response = await http.get(
          Uri.parse(
              '$apiRoot/api/audio?PageNumber=$pageNumber&PageSize=$pageSize&allUsers=$allUsers&status=$status&mistakes=$mistakes&recitationType=$recitationType&searchTerm=$searchTerm'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
          });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return PaginatedItemsResponseModel<RecitationViewModel>(
              error: errSessionRenewal);
        }
        return await getRecitations(
            pageNumber: pageNumber,
            pageSize: pageSize,
            allUsers: allUsers,
            status: status,
            searchTerm: searchTerm,
            mistakes: mistakes,
            commentaries: commentaries,
            error401: true);
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
                json.decode(response.headers['paging-headers']!)),
            error: '',
            audioUploadEnabled:
                json.decode(response.headers['audio-upload-enabled']!));
      } else {
        return PaginatedItemsResponseModel<RecitationViewModel>(
            error: 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return PaginatedItemsResponseModel<RecitationViewModel>(
          error:
              'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// updates an existing narration
  ///
  ///
  Future<Tuple2<RecitationViewModel?, String>> updateRecitation(
      RecitationViewModel narration, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      int id = narration.id;
      http.Response response =
          await http.put(Uri.parse('$apiRoot/api/audio/$id'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
              },
              body: jsonEncode(narration.toJson()));

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<RecitationViewModel?, String>(null, errSessionRenewal);
        }
        return await updateRecitation(narration, true);
      }

      if (response.statusCode == 200) {
        RecitationViewModel ret =
            RecitationViewModel.fromJson(json.decode(response.body));

        return Tuple2<RecitationViewModel, String>(ret, '');
      } else {
        return Tuple2<RecitationViewModel?, String>(
            null, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<RecitationViewModel?, String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  ///moderate narration
  ///
  ///
  Future<Tuple2<RecitationViewModel?, String>> moderateRecitation(int id,
      RecitationModerationResult res, String message, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;

      int mres = res == RecitationModerationResult.metadataNeedsFixation
          ? 0
          : res == RecitationModerationResult.approve
              ? 1
              : 2;
      RecitationModerateViewModel model =
          RecitationModerateViewModel(result: mres, message: message);
      var apiRoot = GServiceAddress.url;
      http.Response response =
          await http.put(Uri.parse('$apiRoot/api/audio/moderate/$id'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
              },
              body: jsonEncode(model.toJson()));

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<RecitationViewModel?, String>(null, errSessionRenewal);
        }
        return await moderateRecitation(id, res, message, true);
      }

      if (response.statusCode == 200) {
        RecitationViewModel ret =
            RecitationViewModel.fromJson(json.decode(response.body));

        return Tuple2<RecitationViewModel, String>(ret, '');
      } else {
        return Tuple2<RecitationViewModel?, String>(
            null, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<RecitationViewModel?, String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// delete an existing recitation
  ///
  ///
  Future<Tuple2<bool, String>> deleteRecitation(int id, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response = await http.delete(
        Uri.parse('$apiRoot/api/audio/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
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
            false, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<bool, String>(false,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// Get Profiles
  ///
  ///returns a Tuple2, if any error occurs Items1 is null and Item2 contains the error message
  ///Items1 is the actual response if the call is successful
  Future<Tuple2<List<UserRecitationProfileViewModel>?, String>> getProfiles(
      String artistName, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response = await http.get(
          Uri.parse('$apiRoot/api/audio/profile?artistName=$artistName'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
          });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<List<UserRecitationProfileViewModel>?, String>(
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
        return Tuple2<List<UserRecitationProfileViewModel>?, String>(
            null, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<List<UserRecitationProfileViewModel>?, String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// Get User Default Profile
  ///
  ///returns a Tuple2, if any error occurs Items1 is null and Item2 contains the error message
  ///Items1 is the actual response if the call is successful
  Future<Tuple2<UserRecitationProfileViewModel?, String>> getDefProfile(
      bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response =
          await http.get(Uri.parse('$apiRoot/api/audio/profile/def'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
      });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<UserRecitationProfileViewModel?, String>(
              null, errSessionRenewal);
        }
        return await getDefProfile(true);
      }
      if (response.statusCode == 200) {
        return Tuple2<UserRecitationProfileViewModel, String>(
            UserRecitationProfileViewModel.fromJson(json.decode(response.body)),
            '');
      } else {
        return Tuple2<UserRecitationProfileViewModel?, String>(null,
            'کد برگشتی: ${response.statusCode} ${json.decode(response.body)}');
      }
    } catch (e) {
      return Tuple2<UserRecitationProfileViewModel?, String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// adds a new profile
  ///
  ///
  Future<Tuple2<UserRecitationProfileViewModel?, String>> addProfile(
      UserRecitationProfileViewModel profile, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response =
          await http.post(Uri.parse('$apiRoot/api/audio/profile'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
              },
              body: jsonEncode(profile.toJson()));

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<UserRecitationProfileViewModel?, String>(
              null, errSessionRenewal);
        }
        return await addProfile(profile, true);
      }

      if (response.statusCode == 200) {
        UserRecitationProfileViewModel ret =
            UserRecitationProfileViewModel.fromJson(json.decode(response.body));

        return Tuple2<UserRecitationProfileViewModel, String>(ret, '');
      } else {
        return Tuple2<UserRecitationProfileViewModel?, String>(
            null, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<UserRecitationProfileViewModel?, String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// updates an existing profile
  ///
  ///
  Future<Tuple2<UserRecitationProfileViewModel?, String>> updateProfile(
      UserRecitationProfileViewModel profile, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response =
          await http.put(Uri.parse('$apiRoot/api/audio/profile'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
              },
              body: jsonEncode(profile.toJson()));

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<UserRecitationProfileViewModel?, String>(
              null, errSessionRenewal);
        }
        return await updateProfile(profile, true);
      }

      if (response.statusCode == 200) {
        UserRecitationProfileViewModel ret =
            UserRecitationProfileViewModel.fromJson(json.decode(response.body));

        return Tuple2<UserRecitationProfileViewModel, String>(ret, '');
      } else {
        return Tuple2<UserRecitationProfileViewModel?, String>(
            null, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<UserRecitationProfileViewModel?, String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// delete an existing profile
  ///
  ///
  Future<Tuple2<bool, String>> deleteProfile(String id, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response = await http.delete(
        Uri.parse('$apiRoot/api/audio/profile/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
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
            false, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<bool, String>(false,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// Get User Uploads
  ///
  /// allUsers parameter is currently ignored
  Future<PaginatedItemsResponseModel<UploadedItemViewModel>> getUploads(
      int pageNumber, int pageSize, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response = await http.get(
          Uri.parse(
              '$apiRoot/api/audio/uploads?PageNumber=$pageNumber&PageSize=$pageSize'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
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
                json.decode(response.headers['paging-headers']!)),
            error: '',
            audioUploadEnabled:
                json.decode(response.headers['audio-upload-enabled']!));
      } else {
        return PaginatedItemsResponseModel<UploadedItemViewModel>(
            error: 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return PaginatedItemsResponseModel<UploadedItemViewModel>(
          error:
              'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  Future<Tuple2<List<RecitationVerseSync>?, String>> getVerses(int id) async {
    try {
      var apiRoot = GServiceAddress.url;
      http.Response response =
          await http.get(Uri.parse('$apiRoot/api/audio/verses/$id'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        List<RecitationVerseSync> ret = [];
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(RecitationVerseSync.fromJson(item));
        }
        return Tuple2<List<RecitationVerseSync>, String>(ret, '');
      } else {
        return Tuple2<List<RecitationVerseSync>?, String>(
            null, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<List<RecitationVerseSync>?, String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  ///Get mp3 url
  ///
  /// for the player
  String getAudioFileUrl(int id) {
    var apiRoot = GServiceAddress.url;
    return '$apiRoot/api/audio/file/$id.mp3';
  }

  /// Transfer Recitations Ownership
  ///
  ///
  Future<Tuple2<int, String>> transferRecitationsOwnership(
      String targetEmailAddress, String artistName, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response = await http.put(
        Uri.parse(
            '$apiRoot/api/audio/chown?targetEmailAddress=$targetEmailAddress&artistName=$artistName'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
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
            0, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<int, String>(
          0, 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// Get Synchronization Queue
  ///
  ///returns a Tuple2, if any error occurs Items1 is null and Item2 contains the error message
  ///Items1 is the actual response if the call is successful
  Future<Tuple2<List<RecitationViewModel>?, String>> getSynchronizationQueue(
      bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response =
          await http.get(Uri.parse('$apiRoot/api/audio/syncqueue'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
      });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<List<RecitationViewModel>?, String>(
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
        return Tuple2<List<RecitationViewModel>?, String>(
            null, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<List<RecitationViewModel>?, String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// Retry publish
  ///
  ///returns error string if any error occurs
  ///retrurns empty response if the call is successful
  Future<String> retryPublish(bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response = await http
          .post(Uri.parse('$apiRoot/api/audio/retrypublish'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
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
        return 'کد برگشتی: ${response.statusCode} ${response.body}';
      }
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e';
    }
  }

  Future<PaginatedItemsResponseModel<RecitationErrorReportViewModel>>
      getReportedRecitations(
          int pageNumber, int pageSize, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response = await http.get(
          Uri.parse(
              '$apiRoot/api/audio/errors/report?PageNumber=$pageNumber&PageSize=$pageSize'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
          });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return PaginatedItemsResponseModel<RecitationErrorReportViewModel>(
              error: errSessionRenewal);
        }
        return await getReportedRecitations(pageNumber, pageSize, true);
      }

      List<RecitationErrorReportViewModel> ret = [];
      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        for (var item in items) {
          ret.add(RecitationErrorReportViewModel.fromJson(item));
        }
        return PaginatedItemsResponseModel<RecitationErrorReportViewModel>(
          items: ret,
          paginationMetadata: PaginationMetadata.fromJson(
              json.decode(response.headers['paging-headers']!)),
          error: '',
        );
      } else {
        return PaginatedItemsResponseModel<RecitationErrorReportViewModel>(
            error: 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return PaginatedItemsResponseModel<RecitationErrorReportViewModel>(
          error:
              'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  Future<Tuple2<bool, String>> rejectReport(
      int id, String rejectionNote, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response = await http.delete(
        Uri.parse(
            '$apiRoot/api/audio/errors/report/$id?rejectionNote=$rejectionNote'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
        },
      );

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<bool, String>(false, errSessionRenewal);
        }
        return await rejectReport(id, rejectionNote, true);
      }

      if (response.statusCode == 200) {
        return const Tuple2<bool, String>(true, '');
      } else {
        return Tuple2<bool, String>(
            false, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<bool, String>(false,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  Future<Tuple2<bool, String>> approveReport(int id, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response = await http.delete(
        Uri.parse('$apiRoot/api/audio/errors/report/accept/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
        },
      );

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<bool, String>(false, errSessionRenewal);
        }
        return await approveReport(id, true);
      }

      if (response.statusCode == 200) {
        return const Tuple2<bool, String>(true, '');
      } else {
        return Tuple2<bool, String>(
            false, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<bool, String>(false,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  Future<Tuple2<bool, String>> saveRictationMistake(
      RecitationErrorReportViewModel report, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;

      var apiRoot = GServiceAddress.url;
      http.Response response =
          await http.put(Uri.parse('$apiRoot/api/audio/errors/report/save'),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
              },
              body: jsonEncode(report.toJson()));

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<bool, String>(false, errSessionRenewal);
        }
        return await saveRictationMistake(report, true);
      }

      if (response.statusCode == 200) {
        return const Tuple2<bool, String>(true, '');
      } else {
        return Tuple2<bool, String>(
            false, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<bool, String>(false,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// get publish queue
  ///
  Future<
      Tuple2<PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel>?,
          String>> getPublishQueue(bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response = await http.get(
          Uri.parse('$apiRoot/api/audio/publishqueue?unfinished=true'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
          });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<
              PaginatedItemsResponseModel<
                  RecitationPublishingTrackerViewModel>?,
              String>(null, errSessionRenewal);
        }
        return await getPublishQueue(true);
      }

      if (response.statusCode == 200) {
        List<RecitationPublishingTrackerViewModel> ret = [];
        List<dynamic> items = json.decode(response.body);

        for (var item in items) {
          ret.add(RecitationPublishingTrackerViewModel.fromJson(item));
        }
        return Tuple2<
                PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel>,
                String>(
            PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel>(
                items: ret,
                paginationMetadata: PaginationMetadata.fromJson(
                    json.decode(response.headers['paging-headers']!))),
            '');
      } else {
        return Tuple2<
            PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel>?,
            String>(null, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<
              PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel>?,
              String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// Makes recitations of فریدون فرح‌اندوز first recitations
  ///
  ///
  Future<Tuple2<int, String>> makeFFRecitationsFirst(bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;
      http.Response response = await http.put(
        Uri.parse('$apiRoot/api/audio/ff'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
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
            0, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<int, String>(
          0, 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }

  /// *
  /// published recitaions by id
  Future<Tuple2<PublicRecitationViewModel?, String>> getPublishedRecitationById(
      {required int id, required bool error401}) async {
    try {
      LoggedOnUserModel? userInfo = await _storageService.userInfo;
      var apiRoot = GServiceAddress.url;

      http.Response response = await http
          .get(Uri.parse('$apiRoot/api/audio/published/$id'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
      });

      if (!error401 && response.statusCode == 401) {
        String errSessionRenewal = await AuthService().relogin();
        if (errSessionRenewal.isNotEmpty) {
          return Tuple2<PublicRecitationViewModel?, String>(
              null, errSessionRenewal);
        }
        return await getPublishedRecitationById(id: id, error401: true);
      }

      if (response.statusCode == 200) {
        return Tuple2<PublicRecitationViewModel?, String>(
            PublicRecitationViewModel.fromJson(json.decode(response.body)), '');
      } else {
        return Tuple2<PublicRecitationViewModel?, String>(
            null, 'کد برگشتی: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return Tuple2<PublicRecitationViewModel?, String>(null,
          'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e');
    }
  }
}
