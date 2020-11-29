import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gaudiopanel/callbacks/g-ui-callbacks.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/notifications/ruser-notification-viewmodel.dart';
import 'package:gaudiopanel/services/notification-service.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsDataSection extends StatefulWidget {
  final PaginatedItemsResponseModel<RUserNotificationViewModel> notifications;
  final LoadingStateChanged loadingStateChanged;
  final SnackbarNeeded snackbarNeeded;
  final UpdateUnreadNotificationsCount updateUnreadNotificationsCount;

  const NotificationsDataSection(
      {Key key,
      this.notifications,
      this.loadingStateChanged,
      this.snackbarNeeded,
      this.updateUnreadNotificationsCount})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotificationsState(
      this.notifications,
      this.loadingStateChanged,
      this.snackbarNeeded,
      this.updateUnreadNotificationsCount);
}

class _NotificationsState extends State<NotificationsDataSection> {
  final PaginatedItemsResponseModel<RUserNotificationViewModel> notifications;
  final LoadingStateChanged loadingStateChanged;
  final SnackbarNeeded snackbarNeeded;
  final UpdateUnreadNotificationsCount updateUnreadNotificationsCount;

  _NotificationsState(this.notifications, this.loadingStateChanged,
      this.snackbarNeeded, this.updateUnreadNotificationsCount);

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
                    if (notifications.items[index].status ==
                        NotificationStatus.Unread) {
                      this.loadingStateChanged(true);
                      String error = await NotificationService()
                          .switchStatus(notifications.items[index].id, false);
                      if (error.isNotEmpty) {
                        this.snackbarNeeded('خطا در تغییر وضعیت اعلان  ' +
                            notifications.items[index].subject +
                            '، اطلاعات بیشتر ' +
                            error);
                      } else
                        setState(() {
                          notifications.items[index].status =
                              NotificationStatus.Read;
                        });
                      this.loadingStateChanged(false);

                      if (this.updateUnreadNotificationsCount != null) {
                        this.updateUnreadNotificationsCount(notifications.items
                            .where((element) =>
                                element.status == NotificationStatus.Unread)
                            .length);
                      }
                    }
                  } else {
                    throw 'خطا در نمایش نشانی $url';
                  }
                },
              ),
              trailing: IconButton(
                icon: notifications.items[index].isMarked
                    ? Icon(Icons.check_box)
                    : Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  setState(() {
                    notifications.items[index].isMarked =
                        !notifications.items[index].isMarked;
                  });
                },
              ));
        });
  }
}
