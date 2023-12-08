import 'package:gaudiopanel/models/recitation/recitation_viewmodel.dart';

class RecitationErrorReportViewModel {
  final int id;
  final int recitationId;
  String? reasonText;
  final RecitationViewModel recitation;
  final int numberOfLinesAffected;
  int coupletIndex;
  final String dateTime;
  bool isMarked = false;

  RecitationErrorReportViewModel(
      {required this.id,
      required this.recitationId,
      required this.reasonText,
      required this.recitation,
      required this.numberOfLinesAffected,
      required this.coupletIndex,
      required this.dateTime});

  factory RecitationErrorReportViewModel.fromJson(Map<String, dynamic> json) {
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
    Map<String, dynamic> m = {};
    m['id'] = id;
    m['recitationId'] = recitationId;
    m['reasonText'] = reasonText;
    m['numberOfLinesAffected'] = numberOfLinesAffected;
    m['coupletIndex'] = coupletIndex;
    return m;
  }
}
