import 'package:gaudiopanel/models/common/pagination-metadata.dart';
import 'package:gaudiopanel/models/narration/uploaded-item-viewmodel.dart';

class UploadedNarrationsResponseModel {
  final List<UploadedItemViewModel> uploads;
  final PaginationMetadata paginationMetadata;
  final String error;

  UploadedNarrationsResponseModel(
      {this.uploads, this.paginationMetadata, this.error});
}
