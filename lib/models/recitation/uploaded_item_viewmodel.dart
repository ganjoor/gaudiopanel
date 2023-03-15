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
      {this.fileName,
      this.processResult,
      this.processResultMsg,
      this.uploadEndTime,
      this.userName,
      this.processStartTime,
      this.processProgress,
      this.processEndTime});

  factory UploadedItemViewModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
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
