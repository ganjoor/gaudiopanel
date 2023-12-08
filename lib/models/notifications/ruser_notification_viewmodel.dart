class NotificationStatus {
  static const int unread = 0;
  static const int read = 1;
}

class RUserNotificationViewModel {
  final String id;
  final String dateTime;
  int status;
  final String subject;
  final String htmlText;
  bool isMarked = false;

  RUserNotificationViewModel(
      {required this.id,
      required this.dateTime,
      required this.status,
      required this.subject,
      required this.htmlText});

  factory RUserNotificationViewModel.fromJson(Map<String, dynamic> json) {
    return RUserNotificationViewModel(
      id: json['id'],
      dateTime: json['dateTime'],
      status: json['status'],
      subject: json['subject'],
      htmlText: json['htmlText'],
    );
  }
}
