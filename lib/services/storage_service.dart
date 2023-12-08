import 'package:gaudiopanel/models/auth/logged_on_user_model.dart';
import 'package:localstorage/localstorage.dart';

class StorageService {
  final LocalStorage _appStorage = LocalStorage('app');

  Future setUserInfo(LoggedOnUserModel? model) async {
    await _appStorage.ready;
    await _appStorage.setItem('login', model?.toJson());
  }

  Future delUserInfo() async {
    await setUserInfo(null);
  }

  Future<LoggedOnUserModel?> get userInfo async {
    await _appStorage.ready;
    return LoggedOnUserModel.fromJson(_appStorage.getItem('login'));
  }
}
