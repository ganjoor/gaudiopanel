import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gaudiopanel/callbacks/g_ui_callbacks.dart';
import 'package:gaudiopanel/models/common/paginated_items_response_model.dart';
import 'package:gaudiopanel/models/notifications/ruser_notification_viewmodel.dart';
import 'package:gaudiopanel/services/notification_service.dart';
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
  State<StatefulWidget> createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsDataSection> {
  Icon getNotificationIcon(RUserNotificationViewModel notification) {
    return notification.status == NotificationStatus.Unread
        ? const Icon(Icons.mail, color: Colors.yellow)
        : const Icon(Icons.mark_as_unread);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.notifications.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: getNotificationIcon(widget.notifications.items[index]),
              title: Text(widget.notifications.items[index].subject),
              subtitle: Html(
                data: widget.notifications.items[index].htmlText,
                onLinkTap: (url, context, map, element) async {
                  if (await canLaunch(url)) {
                    await launch(url);
                    if (widget.notifications.items[index].status ==
                        NotificationStatus.Unread) {
                      widget.loadingStateChanged(true);
                      String error = await NotificationService().switchStatus(
                          widget.notifications.items[index].id, false);
                      if (error.isNotEmpty) {
                        widget.snackbarNeeded(
                            'خطا در تغییر وضعیت اعلان  ${widget.notifications.items[index].subject}، اطلاعات بیشتر $error');
                      } else {
                        setState(() {
                          widget.notifications.items[index].status =
                              NotificationStatus.Read;
                        });
                      }
                      widget.loadingStateChanged(false);

                      if (widget.updateUnreadNotificationsCount != null) {
                        widget.updateUnreadNotificationsCount(widget
                            .notifications.items
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
                icon: widget.notifications.items[index].isMarked
                    ? const Icon(Icons.check_box)
                    : const Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  setState(() {
                    widget.notifications.items[index].isMarked =
                        !widget.notifications.items[index].isMarked;
                  });
                },
              ));
        });
  }
}
