import 'package:gaudiopanel/models/auth/logged-on-user-model.dart';
import 'package:localstorage/localstorage.dart';

class StorageService {
  final LocalStorage _appStorage = LocalStorage('app');

  Future setUserInfo(LoggedOnUserModel model) async {
    await _appStorage.ready;
    if (model == null) {
      _appStorage.deleteItem('login');
    } else {
      _appStorage.setItem('login', model.toJson());
    }
  }

  Future delUserInfo() async {
    await setUserInfo(null);
  }

  Future<LoggedOnUserModel> get userInfo async {
    await _appStorage.ready;
    return LoggedOnUserModel.fromJson(_appStorage.getItem('login'));
  }
}
