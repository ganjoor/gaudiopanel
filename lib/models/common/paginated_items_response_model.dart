import 'package:gaudiopanel/models/common/pagination_metadata.dart';

class PaginatedItemsResponseModel<T> {
  List<T>? items;
  PaginationMetadata? paginationMetadata;
  String? error;
  bool audioUploadEnabled;

  PaginatedItemsResponseModel(
      {this.items,
      this.paginationMetadata,
      this.error,
      this.audioUploadEnabled = true});
}
