import 'package:gaudiopanel/models/recitation/recitation-viewmodel.dart';

class RecitationErrorReportViewModel {
  final int id;
  final int recitationId;
  final String reasonText;
  final RecitationViewModel recitation;
  final String dateTime;
  bool isMarked = false;

  RecitationErrorReportViewModel(
      {this.id,
      this.recitationId,
      this.reasonText,
      this.recitation,
      this.dateTime});

  factory RecitationErrorReportViewModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return RecitationErrorReportViewModel(
        id: json['id'],
        recitationId: json['recitationId'],
        reasonText: json['reasonText'],
        recitation: RecitationViewModel.fromJson(json['recitation']),
        dateTime: json['dateTime']);
  }
}
