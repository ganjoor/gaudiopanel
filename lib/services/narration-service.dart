import 'dart:convert';
import 'dart:io';

import 'package:gaudiopanel/models/auth/logged-on-user-model.dart';
import 'package:gaudiopanel/models/common/pagination-metadata.dart';
import 'package:gaudiopanel/models/narration/poem-narration-viewmodel.dart';
import 'package:gaudiopanel/models/narration/poem-narrations-response-model.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:gaudiopanel/services/gservice-address.dart';
import 'package:gaudiopanel/services/storage-service.dart';
import 'package:http/http.dart' as http;

class NarrationService {
  final StorageService _storageService = StorageService();

  Future<PoemNarrationsResponseModel> getNarrations(
      int pageNumber, int pageSize, bool error401) async {
    LoggedOnUserModel userInfo = await _storageService.userInfo;
    if (userInfo == null) {
      return PoemNarrationsResponseModel(error: 'کاربر وارد سیستم نشده است.');
    }
    var apiRoot = GServiceAddress.Url;
    http.Response response = await http.get(
        '$apiRoot/api/audio?PageNumber=$pageNumber&PageSize=$pageSize',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
        });

    if (!error401 && response.statusCode == 401) {
      String errSessionRenewal = await AuthService().relogin();
      if (errSessionRenewal.isNotEmpty) {
        return PoemNarrationsResponseModel(error: errSessionRenewal);
      }
      return await getNarrations(pageNumber, pageSize, true);
    }

    List<PoemNarrationViewModel> ret = [];
    if (response.statusCode == 200) {
      List<dynamic> items = json.decode(response.body);
      for (var item in items) {
        ret.add(PoemNarrationViewModel.fromJson(item));
      }
      return PoemNarrationsResponseModel(
          narrations: ret,
          paginationMetadata: PaginationMetadata.fromJson(
              json.decode(response.headers['paging-headers'])),
          error: '');
    } else {
      return PoemNarrationsResponseModel(error: response.body);
    }
  }
}
