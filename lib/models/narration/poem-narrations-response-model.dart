import 'package:gaudiopanel/models/common/pagination-metadata.dart';
import 'package:gaudiopanel/models/narration/poem-narration-viewmodel.dart';

class PoemNarrationsResponseModel {
  final List<PoemNarrationViewModel> narrations;
  final PaginationMetadata paginationMetadata;
  final String error;

  PoemNarrationsResponseModel(
      {this.narrations, this.paginationMetadata, this.error});
}
