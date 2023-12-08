import 'package:gaudiopanel/models/auth/securable_item_operation.dart';

class SecurableItem {
  final String shortName;
  final String description;
  final List<SecurableItemOperation> operations;

  SecurableItem(
      {required this.shortName,
      required this.description,
      required this.operations});

  factory SecurableItem.fromJson(Map<String, dynamic> json) {
    return SecurableItem(
        shortName: json['shortName'],
        description: json['description'],
        operations: (json['operations'] as List)
            .map((i) => SecurableItemOperation.fromJson(i))
            .toList());
  }

  toJson() {
    Map<String, dynamic> m = {};
    m['shortName'] = shortName;
    m['description'] = description;
    m['operations'] = operations.map((e) => e.toJson()).toList();
    return m;
  }
}
