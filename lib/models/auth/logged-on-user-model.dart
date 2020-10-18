import 'package:gaudiopanel/models/auth/public-rapp-user.dart';
import 'package:gaudiopanel/models/auth/securable-item.dart';

class LoggedOnUserModel {
  final String sessionId;
  final String token;
  final PublicRAppUser user;
  final List<SecurableItem> securableItem;

  LoggedOnUserModel(this.sessionId, this.token, this.user, this.securableItem);
}
