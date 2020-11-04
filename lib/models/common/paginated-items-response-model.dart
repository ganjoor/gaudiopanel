import 'package:gaudiopanel/models/common/pagination-metadata.dart';

class PaginatedItemsResponseModel<T> {
  final List<T> items;
  PaginationMetadata paginationMetadata;
  final String error;

  PaginatedItemsResponseModel(
      {this.items, this.paginationMetadata, this.error});
}
