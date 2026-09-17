import 'dart:convert';

import 'package:gaudiopanel/models/auth/logged_on_user_model.dart';
import 'package:localstorage/localstorage.dart';

class StorageService {
  Future setUserInfo(LoggedOnUserModel? model) async {
    if (model == null) {
      localStorage.removeItem('login');
    } else {
      localStorage.setItem('login', json.encode(model.toJson()));
    }
  }

  Future delUserInfo() async {
    await setUserInfo(null);
  }

  Future<LoggedOnUserModel?> get userInfo async {
    String? raw = localStorage.getItem('login');
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return LoggedOnUserModel.fromJson(json.decode(raw));
  }
}
