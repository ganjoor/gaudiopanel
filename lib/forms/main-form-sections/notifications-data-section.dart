import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/notifications/ruser-notification-viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsDataSection extends StatefulWidget {
  final PaginatedItemsResponseModel<RUserNotificationViewModel> notifications;

  const NotificationsDataSection({Key key, this.notifications})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _NotificationsState(this.notifications);
}

class _NotificationsState extends State<NotificationsDataSection> {
  final PaginatedItemsResponseModel<RUserNotificationViewModel> notifications;

  _NotificationsState(this.notifications);

  Icon getNotificationIcon(RUserNotificationViewModel notification) {
    return notification.status == NotificationStatus.Unread
        ? Icon(Icons.mail, color: Colors.yellow)
        : Icon(Icons.mark_as_unread);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notifications.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: getNotificationIcon(notifications.items[index]),
              title: Text(notifications.items[index].subject),
              subtitle: Html(
                data: notifications.items[index].htmlText,
                onLinkTap: (url) async {
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'خطا در نمایش نشانی $url';
                  }
                },
              ));
        });
  }
}
