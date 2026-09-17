import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:gaudiopanel/models/auth/logged_on_user_model.dart';
import 'package:gaudiopanel/services/storage_service.dart';
import 'package:http/http.dart' as http;

import 'package:gaudiopanel/services/gservice_address.dart';

class UploadRecitationService {
  Future<String> uploadFiles(List<PlatformFile> files, bool replace,
      bool commentary, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await StorageService().userInfo;

      int recitationType = commentary ? 1 : 0;

      var baseUrl = GServiceAddress.url;
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              '$baseUrl/api/audio?replace=$replace&recitationType=$recitationType'));
      for (var file in files) {
        request.files.add(http.MultipartFile.fromBytes(file.name, file.bytes!,
            filename: file.name));
      }

      request.headers.addAll({
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
      });

      var response = await request.send();

      if (!error401 && response.statusCode == 401) {
        return await uploadFiles(files, replace, commentary, true);
      }

      if (response.statusCode == 200) {
        return '';
      }

      return await response.stream.bytesToString();
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e';
    }
  }

  /// Replace only the synchronization (xml) file of an existing, approved
  /// recitation owned by the current user. The server rejects the request
  /// (returning the error text) unless the uploaded xml matches the
  /// recitation's already-uploaded mp3 exactly. On acceptance the xml is
  /// queued for publishing to the external FTP server(s); the final
  /// success/failure of that step arrives later as a notification, not as
  /// part of this call's result.
  Future<String> replaceRecitationXml(
      int recitationId, PlatformFile xmlFile, bool error401) async {
    try {
      LoggedOnUserModel? userInfo = await StorageService().userInfo;

      var baseUrl = GServiceAddress.url;
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/api/audio/$recitationId/xml'));
      request.files.add(http.MultipartFile.fromBytes(
          xmlFile.name, xmlFile.bytes!,
          filename: xmlFile.name));

      request.headers.addAll({
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'bearer ${userInfo!.token}'
      });

      var response = await request.send();

      if (!error401 && response.statusCode == 401) {
        return await replaceRecitationXml(recitationId, xmlFile, true);
      }

      if (response.statusCode == 200) {
        return '';
      }

      return await response.stream.bytesToString();
    } catch (e) {
      return 'سرور مشخص شده در تنظیمات در دسترس نیست.\u200Fجزئیات بیشتر: $e';
    }
  }
}
