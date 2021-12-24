import 'package:gaudiopanel/models/recitation/recitation-viewmodel.dart';

class RecitationErrorReportViewModel {
  final int id;
  final int recitationId;
  String reasonText;
  final RecitationViewModel recitation;
  final int numberOfLinesAffected;
  int coupletIndex;
  final String dateTime;
  bool isMarked = false;

  RecitationErrorReportViewModel(
      {this.id,
      this.recitationId,
      this.reasonText,
      this.recitation,
      this.numberOfLinesAffected,
      this.coupletIndex,
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
        numberOfLinesAffected: json['numberOfLinesAffected'],
        coupletIndex: json['coupletIndex'],
        dateTime: json['dateTime']);
  }
  toJson() {
    Map<String, dynamic> m = new Map();
    m['id'] = id;
    m['recitationId'] = recitationId;
    m['reasonText'] = reasonText;
    m['numberOfLinesAffected'] = numberOfLinesAffected;
    m['coupletIndex'] = coupletIndex;
    return m;
  }
}
