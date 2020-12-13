import 'package:gaudiopanel/models/common/pagination-metadata.dart';

class PaginatedItemsResponseModel<T> {
  final List<T> items;
  PaginationMetadata paginationMetadata;
  final String error;
  bool audioUploadEnabled;

  PaginatedItemsResponseModel(
      {this.items,
      this.paginationMetadata,
      this.error,
      this.audioUploadEnabled});
}
