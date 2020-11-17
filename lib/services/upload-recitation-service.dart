import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:gaudiopanel/models/auth/logged-on-user-model.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:gaudiopanel/services/storage-service.dart';
import 'package:http/http.dart' as http;

import 'package:gaudiopanel/services/gservice-address.dart';

class UploadRecitationService {
  Future<String> uploadFiles(List<PlatformFile> files, bool error401) async {
    try {
      LoggedOnUserModel userInfo = await StorageService().userInfo;

      var baseUrl = GServiceAddress.Url;
      var request =
          new http.MultipartRequest("POST", Uri.parse('$baseUrl/api/audio'));
      for (var file in files) {
        request.files.add(http.MultipartFile.fromBytes(file.name, file.bytes,
            filename: file.name));
      }

      request.headers.addAll({
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ' + userInfo.token
      });

      var response = await request.send();

      if (!error401 && response.statusCode == 401) {
        if ((await AuthService().relogin()) != null) {
          return await uploadFiles(files, true);
        }
      }

      if (response.statusCode == 200) {
        return '';
      }

      return await response.stream.bytesToString();
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: ' +
          e.toString();
    }
  }
}
