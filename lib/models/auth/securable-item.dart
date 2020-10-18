import 'package:gaudiopanel/models/auth/securable-item-operation.dart';

class SecurableItem {
  final String shortName;
  final String description;
  final List<SecurableItemOperation> operations;

  SecurableItem(this.shortName, this.description, this.operations);
}
