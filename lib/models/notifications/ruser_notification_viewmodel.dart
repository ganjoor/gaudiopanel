class NotificationStatus {
  static const int Unread = 0;
  static const int Read = 1;
}

class RUserNotificationViewModel {
  final String id;
  final String dateTime;
  int status;
  final String subject;
  final String htmlText;
  bool isMarked = false;

  RUserNotificationViewModel(
      {this.id, this.dateTime, this.status, this.subject, this.htmlText});

  factory RUserNotificationViewModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return RUserNotificationViewModel(
      id: json['id'],
      dateTime: json['dateTime'],
      status: json['status'],
      subject: json['subject'],
      htmlText: json['htmlText'],
    );
  }
}
