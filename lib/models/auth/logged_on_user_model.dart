import 'package:gaudiopanel/models/auth/public_rapp_user.dart';
import 'package:gaudiopanel/models/auth/securable_item.dart';

class LoggedOnUserModel {
  final String sessionId;
  final String token;
  final PublicRAppUser user;
  final List<SecurableItem> securableItem;

  LoggedOnUserModel(
      {required this.sessionId,
      required this.token,
      required this.user,
      required this.securableItem});

  factory LoggedOnUserModel.fromJson(Map<String, dynamic> json) {
    return LoggedOnUserModel(
        sessionId: json['sessionId'],
        token: json['token'],
        user: PublicRAppUser.fromJson(json['user']),
        securableItem: (json['securableItem'] as List)
            .map((i) => SecurableItem.fromJson(i))
            .toList());
  }

  toJson() {
    Map<String, dynamic> m = {};
    m['sessionId'] = sessionId;
    m['token'] = token;
    m['user'] = user.toJson();
    m['securableItem'] = securableItem.map((e) => e.toJson()).toList();
    return m;
  }
}
