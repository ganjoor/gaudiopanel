class UploadedItemViewModel {
  final String fileName;
  final bool processResult;
  final String processResultMsg;
  final String uploadEndTime;
  final String userName;
  final String processStartTime;
  final int processProgress;
  final String processEndTime;

  UploadedItemViewModel(
      {required this.fileName,
      required this.processResult,
      required this.processResultMsg,
      required this.uploadEndTime,
      required this.userName,
      required this.processStartTime,
      required this.processProgress,
      required this.processEndTime});

  factory UploadedItemViewModel.fromJson(Map<String, dynamic> json) {
    return UploadedItemViewModel(
      fileName: json['fileName'],
      processResult: json['processResult'],
      processResultMsg: json['processResultMsg'],
      uploadEndTime: json['uploadEndTime'],
      userName: json['userName'],
      processStartTime: json['processStartTime'],
      processProgress: json['processProgress'],
      processEndTime: json['processEndTime'],
    );
  }
}
