import 'package:after_layout/after_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/chwon_to_email.dart';
import 'package:gaudiopanel/forms/login.dart';
import 'package:gaudiopanel/forms/main-form-sections/notifications_data_section.dart';
import 'package:gaudiopanel/forms/main-form-sections/profiles_data_section.dart';
import 'package:gaudiopanel/forms/profile_edit.dart';
import 'package:gaudiopanel/forms/search_params.dart';
import 'package:gaudiopanel/forms/upload_files.dart';
import 'package:gaudiopanel/models/common/paginated_items_response_model.dart';
import 'package:gaudiopanel/models/notifications/ruser_notification_viewmodel.dart';
import 'package:gaudiopanel/models/recitation/recitation_viewmodel.dart';
import 'package:gaudiopanel/models/recitation/recitation_error_report_viewmodel.dart';
import 'package:gaudiopanel/models/recitation/uploaded_item_viewmodel.dart';
import 'package:gaudiopanel/models/recitation/user_recitation_profile_viewmodel.dart';
import 'package:gaudiopanel/services/auth_service.dart';
import 'package:gaudiopanel/services/notification_service.dart';
import 'package:gaudiopanel/services/storage_service.dart';
import 'package:gaudiopanel/services/upload_recitation_service.dart';
import 'package:gaudiopanel/services/recitation_service.dart';
import 'package:gaudiopanel/forms/main-form-sections/recitations_data_section.dart';
import 'package:gaudiopanel/forms/main-form-sections/uploads_data_section.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/recitation/recitation_publishing_tracker_viewmodel.dart';
import 'main-form-sections/publish_queue_section.dart';
import 'main-form-sections/reported_data_section.dart';

enum GActiveFormSection {
  draftRecitations,
  allMyRecitations,
  allUsersPendingRecitations,
  uploads,
  profiles,
  synchronizationQueue,
  notifications,
  reportedRecitations,
  rejectedRecitaions,
  recitationsWithMistakes,
}

class MainForm extends StatefulWidget {
  const MainForm({super.key});

  @override
  MainFormWidgetState createState() => MainFormWidgetState();
}

class MainFormWidgetState extends State<MainForm>
    with AfterLayoutMixin<MainForm> {
  final GlobalKey<ScaffoldMessengerState> _key =
      GlobalKey<ScaffoldMessengerState>();
  bool _canPublish = false;
  bool _canModerate = false;
  bool _canReOrder = false;
  String _userFrinedlyName = '';
  bool _isLoading = false;
  GActiveFormSection _activeSection = GActiveFormSection.draftRecitations;
  int _narrationsPageNumber = 1;
  int _uploadsPageNumber = 1;
  int _pageSize = 20;
  String _searchTerm = '';
  int _unreadNotificationsCount = 0;
  bool _audioUpdateEnabled = true;

  final PaginatedItemsResponseModel<RecitationViewModel> _narrations =
      PaginatedItemsResponseModel<RecitationViewModel>(items: []);
  final PaginatedItemsResponseModel<UploadedItemViewModel> _uploads =
      PaginatedItemsResponseModel<UploadedItemViewModel>(items: []);
  final PaginatedItemsResponseModel<UserRecitationProfileViewModel> _profiles =
      PaginatedItemsResponseModel<UserRecitationProfileViewModel>(items: []);
  final PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel>
      _queue =
      PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel>(
          items: []);
  final PaginatedItemsResponseModel<RUserNotificationViewModel> _notifications =
      PaginatedItemsResponseModel<RUserNotificationViewModel>(items: []);
  final PaginatedItemsResponseModel<RecitationErrorReportViewModel> _reporteds =
      PaginatedItemsResponseModel<RecitationErrorReportViewModel>(items: []);
  String get title {
    switch (_activeSection) {
      case GActiveFormSection.uploads:
        return 'بارگذاری‌های من';
      case GActiveFormSection.profiles:
        return 'نمایه‌های من';
      case GActiveFormSection.draftRecitations:
        return 'خوانش‌های پیش‌نویس من';
      case GActiveFormSection.allMyRecitations:
        return 'همهٔ خوانش‌های من';
      case GActiveFormSection.allUsersPendingRecitations:
        return 'خوانش‌های در انتظار تأیید';
      case GActiveFormSection.notifications:
        return 'اعلان‌های من';
      case GActiveFormSection.reportedRecitations:
        return 'خوانش‌های گزارش شده';
      case GActiveFormSection.rejectedRecitaions:
        return 'خوانش‌های برگشت‌خورده';
      case GActiveFormSection.recitationsWithMistakes:
        return 'خوانش‌های دارای اشکال';
      case GActiveFormSection.synchronizationQueue:
        return 'صف انتشار در گنجور';
    }
  }

  Future<void> _loadNarrationsData() async {
    setState(() {
      _isLoading = true;
    });
    var narrations = await RecitationService().getRecitations(
        _narrationsPageNumber,
        _pageSize,
        _activeSection == GActiveFormSection.allUsersPendingRecitations,
        _activeSection == GActiveFormSection.allMyRecitations ||
                _activeSection == GActiveFormSection.recitationsWithMistakes
            ? -1
            : _activeSection == GActiveFormSection.allUsersPendingRecitations
                ? 1
                : _activeSection == GActiveFormSection.rejectedRecitaions
                    ? 4
                    : 0,
        _searchTerm,
        _activeSection == GActiveFormSection.recitationsWithMistakes,
        false);
    if (narrations.error!.isEmpty) {
      setState(() {
        _narrations.items!.clear();
        _narrations.items!.addAll(narrations.items!);
        _narrations.paginationMetadata = narrations.paginationMetadata;
        _audioUpdateEnabled = narrations.audioUploadEnabled;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _key.currentState!.showSnackBar(SnackBar(
        content: Text('خطا در دریافت خوانش‌ها: ${narrations.error}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _loadReportedRecitationsData() async {
    setState(() {
      _isLoading = true;
    });
    var reportedOnes = await RecitationService()
        .getReportedRecitations(_narrationsPageNumber, _pageSize, false);
    if (reportedOnes.error!.isEmpty) {
      setState(() {
        _reporteds.items!.clear();
        _reporteds.items!.addAll(reportedOnes.items!);
        _narrations.paginationMetadata = reportedOnes.paginationMetadata;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _key.currentState!.showSnackBar(SnackBar(
        content: Text('خطا در دریافت اطلاعات: ${reportedOnes.error}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _loadUploadsData() async {
    setState(() {
      _isLoading = true;
    });
    var uploads = await RecitationService()
        .getUploads(_uploadsPageNumber, _pageSize, false);

    if (uploads.error!.isEmpty) {
      setState(() {
        _uploads.items!.clear();
        _uploads.items!.addAll(uploads.items!);
        _uploads.paginationMetadata = uploads.paginationMetadata;
        _audioUpdateEnabled = uploads.audioUploadEnabled;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _key.currentState!.showSnackBar(SnackBar(
        content: Text('خطا در دریافت بارگذاری‌ها: ${uploads.error}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _loadProfilesData() async {
    setState(() {
      _isLoading = true;
    });
    var profiles = await RecitationService().getProfiles(_searchTerm, false);

    if (profiles.item2.isEmpty) {
      setState(() {
        _profiles.items!.clear();
        _profiles.items!.addAll(profiles.item1!);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _key.currentState!.showSnackBar(SnackBar(
        content: Text('خطا در دریافت نمایه‌ها: ${profiles.item2}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _loadSyncronizationQueueData() async {
    setState(() {
      _isLoading = true;
    });
    var publishQueue = await RecitationService().getPublishQueue(false);
    setState(() {
      _isLoading = false;
    });
    if (publishQueue.item2.isEmpty) {
      setState(() {
        _queue.items!.clear();
        _queue.items!.addAll(publishQueue.item1!.items!);
        _queue.paginationMetadata = publishQueue.item1!.paginationMetadata;
      });
    } else {
      _key.currentState!.showSnackBar(SnackBar(
        content: Text('خطا در دریافت صف انتشار در سایت: ${publishQueue.item2}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _loadNotificationsData() async {
    setState(() {
      _isLoading = true;
    });
    var notificationsList = await NotificationService().getNotifications(false);
    setState(() {
      _isLoading = false;
    });
    if (notificationsList.item2.isEmpty) {
      setState(() {
        _notifications.items!.clear();
        _notifications.items!.addAll(notificationsList.item1!);
      });
    } else {
      _key.currentState!.showSnackBar(SnackBar(
        content: Text('خطا در دریافت اعلان‌ها: ${notificationsList.item2}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future _loadNotificationsCount() async {
    setState(() {
      _isLoading = true;
    });

    var retNotificationsCount =
        await NotificationService().getUnreadNotificationsCount(false);
    if (retNotificationsCount.item1 != -1) {
      setState(() {
        _unreadNotificationsCount = retNotificationsCount.item1;
      });
    } else {
      _key.currentState!.showSnackBar(SnackBar(
        content: Text(
            'خطا در دریافت تعداد اعلان‌ها: ${retNotificationsCount.item2}'),
        backgroundColor: Colors.red,
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadData() async {
    switch (_activeSection) {
      case GActiveFormSection.draftRecitations:
      case GActiveFormSection.allMyRecitations:
      case GActiveFormSection.allUsersPendingRecitations:
      case GActiveFormSection.rejectedRecitaions:
      case GActiveFormSection.recitationsWithMistakes:
        await _loadNarrationsData();
        break;
      case GActiveFormSection.uploads:
        await _loadUploadsData();
        break;
      case GActiveFormSection.profiles:
        await _loadProfilesData();
        break;
      case GActiveFormSection.notifications:
        await _loadNotificationsData();
        break;
      case GActiveFormSection.synchronizationQueue:
        await _loadSyncronizationQueueData();
        break;
      case GActiveFormSection.reportedRecitations:
        await _loadReportedRecitationsData();
        break;
    }
    await _loadNotificationsCount();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    var user = await StorageService().userInfo;
    _userFrinedlyName = '${user!.user.firstName} ${user.user.sureName}';

    if (await AuthService().hasPermission('recitation', 'reorder')) {
      _canReOrder = true;
    }

    if (await AuthService().hasPermission('recitation', 'publish')) {
      _canPublish = true;
    }

    if (await AuthService().hasPermission('recitation', 'moderate')) {
      _canModerate = true;
    }

    await _loadData();
  }

  void _loadingStateChanged(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _snackbarNeeded(String msg) {
    _key.currentState!.showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    ));
  }

  void _updateUnreadNotificationsCount(int count) {
    setState(() {
      _unreadNotificationsCount = count;
    });
  }

  Future<UserRecitationProfileViewModel?> _newProfile() async {
    return showDialog<UserRecitationProfileViewModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        ProfileEdit profileEdit = ProfileEdit(
            profile: UserRecitationProfileViewModel(
                id: '00000000-0000-0000-0000-000000000000',
                name: '',
                artistName: '',
                artistUrl: '',
                audioSrc: '',
                audioSrcUrl: '',
                fileSuffixWithoutDash: '',
                isDefault: true));
        return AlertDialog(
          title: const Text('نمایهٔ جدید'),
          content: SingleChildScrollView(
            child: profileEdit,
          ),
        );
      },
    );
  }

  Future<bool?> _getNewRecitationParams(
      UserRecitationProfileViewModel profile) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        UploadFiles uploadFiles = UploadFiles(profile: profile);
        return AlertDialog(
          title: const Text('ارسال خوانش‌های جدید'),
          content: SingleChildScrollView(
            child: uploadFiles,
          ),
        );
      },
    );
  }

  Future<Tuple2<int, String>?> _getSearchParams() async {
    return showDialog<Tuple2<int, String>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        SearchParams searchParams =
            SearchParams(sparams: Tuple2<int, String>(_pageSize, _searchTerm));
        return AlertDialog(
          title: const Text('جستجو'),
          content: SingleChildScrollView(
            child: searchParams,
          ),
        );
      },
    );
  }

  Future<bool?> _confirm(String title, String text) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(text),
          ),
          actions: [
            ElevatedButton(
              child: const Text('بله'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('خیر'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            )
          ],
        );
      },
    );
  }

  Future _newNarrations() async {
    if (!_audioUpdateEnabled) return;
    setState(() {
      _isLoading = true;
    });
    var profileResult = await RecitationService().getDefProfile(false);
    setState(() {
      _isLoading = false;
    });
    if (profileResult.item2.isNotEmpty) {
      _key.currentState!.showSnackBar(SnackBar(
        content: Text(
            'خطا در یافتن نمایهٔ پیش‌فرض ، اطلاعات بیشتر ${profileResult.item2}'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    var replace = await _getNewRecitationParams(profileResult.item1!);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'xml'],
    );
    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      String err = await UploadRecitationService()
          .uploadFiles(result.files, replace!, false);

      if (err.isNotEmpty) {
        _key.currentState!.showSnackBar(SnackBar(
          content: Text('خطا در ارسال خوانش‌های جدید: $err'),
          backgroundColor: Colors.red,
        ));
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _changeMarkedNotificationsStatus(bool read) async {
    var markedNotifications =
        _notifications.items!.where((element) => element.isMarked).toList();
    if (markedNotifications.isEmpty) {
      _key.currentState!.showSnackBar(const SnackBar(
        content: Text('لطفاً اعلان‌های مد نظر را علامتگذاری کنید.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    setState(() {
      _isLoading = true;
    });
    for (var item in markedNotifications) {
      if (read && item.status == NotificationStatus.read) {
        continue;
      }
      if (!read && item.status == NotificationStatus.unread) {
        continue;
      }
      String error = await NotificationService().switchStatus(item.id, false);
      if (error.isNotEmpty) {
        _key.currentState!.showSnackBar(SnackBar(
          content: Text(
              'خطا در تغییر وضعیت اعلان  ${item.subject}، اطلاعات بیشتر $error'),
          backgroundColor: Colors.red,
        ));
        break;
      }
      setState(() {
        item.status =
            read ? NotificationStatus.read : NotificationStatus.unread;
      });
    }
    setState(() {
      _isLoading = false;
      _unreadNotificationsCount = _notifications.items!
          .where((element) => element.status == NotificationStatus.unread)
          .length;
    });
  }

  Future _deleteMarkedNotificaions() async {
    var markedNotifications =
        _notifications.items!.where((element) => element.isMarked).toList();
    if (markedNotifications.isEmpty) {
      _key.currentState!.showSnackBar(const SnackBar(
        content: Text('لطفاً اعلان‌های مد نظر را علامتگذاری کنید.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    String confirmation = markedNotifications.length > 1
        ? 'آیا از حذف ${markedNotifications.length} اعلان علامتگذاری شده اطمینان دارید؟'
        : 'آیا از حذف اعلان «${markedNotifications[0].subject}» اطمینان دارید؟';
    if (await _confirm('تأییدیه', confirmation) == true) {
      setState(() {
        _isLoading = true;
      });
      for (var item in markedNotifications) {
        var delRes =
            await NotificationService().deleteNotification(item.id, false);
        if (delRes.item2.isNotEmpty) {
          _key.currentState!.showSnackBar(SnackBar(
            content: Text(
                'خطا در حذف اعلان ${item.subject}، اطلاعات بیشتر ${delRes.item2}'),
            backgroundColor: Colors.red,
          ));
          break;
        }
        if (delRes.item1) {
          setState(() {
            _notifications.items!.remove(item);
          });
        }
      }
      setState(() {
        _isLoading = false;
        _unreadNotificationsCount = _notifications.items!
            .where((element) => element.status == NotificationStatus.unread)
            .length;
      });
    }
  }

  Future _deleteMarkedProfiles() async {
    var markedProfiles =
        _profiles.items!.where((element) => element.isMarked).toList();
    if (markedProfiles.isEmpty) {
      _key.currentState!.showSnackBar(const SnackBar(
        content: Text('لطفاً نمایه‌های مد نظر را علامتگذاری کنید.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    String confirmation = markedProfiles.length > 1
        ? 'آیا از حذف ${markedProfiles.length} نمایهٔ علامتگذاری شده اطمینان دارید؟'
        : 'آیا از حذف نمایهٔ «${markedProfiles[0].name}» اطمینان دارید؟';
    if (await _confirm('تأییدیه', confirmation) == true) {
      setState(() {
        _isLoading = true;
      });
      for (var item in markedProfiles) {
        var delRes = await RecitationService().deleteProfile(item.id!, false);
        if (delRes.item2.isNotEmpty) {
          _key.currentState!.showSnackBar(SnackBar(
            content: Text(
                'خطا در حذف نمایهٔ ${item.name}، اطلاعات بیشتر ${delRes.item2}'),
            backgroundColor: Colors.red,
          ));
          break;
        }
        if (delRes.item1) {
          setState(() {
            _profiles.items!.remove(item);
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _deleteMarkedRecitations() async {
    var markedRecitations =
        _narrations.items!.where((element) => element.isMarked).toList();
    if (markedRecitations.isEmpty) {
      _key.currentState!.showSnackBar(const SnackBar(
        content: Text('لطفاً خوانش‌های مد نظر را علامتگذاری کنید.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    String confirmation = markedRecitations.length > 1
        ? 'آیا از حذف ${markedRecitations.length} خوانش علامتگذاری شده اطمینان دارید؟'
        : 'آیا از حذف خوانش «${markedRecitations[0].audioTitle}» اطمینان دارید؟';
    if (await _confirm('تأییدیه', confirmation) == true) {
      setState(() {
        _isLoading = true;
      });
      for (var item in markedRecitations) {
        var delRes = await RecitationService().deleteRecitation(item.id, false);
        if (delRes.item2.isNotEmpty) {
          _key.currentState!.showSnackBar(SnackBar(
            content: Text(
                'خطا در حذف خوانش ${item.audioTitle}، اطلاعات بیشتر ${delRes.item2}'),
            backgroundColor: Colors.red,
          ));
          break;
        }
        if (delRes.item1) {
          setState(() {
            _narrations.items!.remove(item);
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _applyDefProfileToMarkedRecitations() async {
    var markedRecitations =
        _narrations.items!.where((element) => element.isMarked).toList();
    if (markedRecitations.isEmpty) {
      _key.currentState!.showSnackBar(const SnackBar(
        content: Text('لطفاً خوانش‌های مد نظر را علامتگذاری کنید.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });
    var defProfile = await RecitationService().getDefProfile(false);
    setState(() {
      _isLoading = false;
    });
    if (defProfile.item2.isNotEmpty) {
      _key.currentState!.showSnackBar(SnackBar(
        content: Text(
            'خطا در دریافت نمایهٔ فعال ، اطلاعات بیشتر ${defProfile.item2}'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    bool confirmed = true ==
        await _confirm('تأییدیه',
            'آیا از اعمال نمایهٔ ${defProfile.item1!.name} به خوانش‌های علامتگذاری شده اطمینان دارید؟');
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });
    var service = RecitationService();
    var profile = defProfile.item1;
    for (var recitation in markedRecitations) {
      recitation.audioArtist = profile!.artistName;
      recitation.audioArtistUrl = profile.artistUrl;
      recitation.audioSrc = profile.audioSrc;
      recitation.audioSrcUrl = profile.audioSrcUrl;

      var res = await service.updateRecitation(recitation, false);
      if (res.item2.isNotEmpty) {
        _key.currentState!.showSnackBar(SnackBar(
          content: Text(res.item2),
          backgroundColor: Colors.red,
        ));
        break;
      }
    }
    setState(() {
      _isLoading = false;
    });

    await _loadData();
  }

  Future<String?> _getEmail() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('انتقال مالکیت خوانش‌های تأیید شده'),
          content: SingleChildScrollView(
            child: ChownToEmail(),
          ),
        );
      },
    );
  }

  Future _transferOwnership() async {
    var markedProfiles =
        _profiles.items!.where((element) => element.isMarked).toList();
    if (markedProfiles.isEmpty) {
      _key.currentState!.showSnackBar(const SnackBar(
        content: Text('لطفاً نمایه‌های مد نظر را علامتگذاری کنید.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    String email = (await _getEmail())!;
    int transfered = 0;
    for (var profile in markedProfiles) {
      setState(() {
        _isLoading = true;
      });

      var ret = await RecitationService()
          .transferRecitationsOwnership(email, profile.artistName, false);

      setState(() {
        _isLoading = false;
      });

      if (ret.item2.isNotEmpty) {
        _key.currentState!.showSnackBar(SnackBar(
          content: Text(ret.item2),
          backgroundColor: Colors.red,
        ));
        break;
      } else {
        transfered += ret.item1;
      }
    }

    _key.currentState!.showSnackBar(SnackBar(
      content: Text('موارد منتقل شده: $transfered'),
      backgroundColor: Colors.green,
    ));

    await _loadData();
  }

  Widget get items {
    switch (_activeSection) {
      case GActiveFormSection.draftRecitations:
      case GActiveFormSection.allMyRecitations:
      case GActiveFormSection.allUsersPendingRecitations:
      case GActiveFormSection.rejectedRecitaions:
      case GActiveFormSection.recitationsWithMistakes:
        return RecitationsDataSection(
          narrations: _narrations,
          loadingStateChanged: _loadingStateChanged,
          snackbarNeeded: _snackbarNeeded,
          status: _activeSection == GActiveFormSection.draftRecitations
              ? 0
              : _activeSection == GActiveFormSection.allUsersPendingRecitations
                  ? 1
                  : _activeSection == GActiveFormSection.recitationsWithMistakes
                      ? 5
                      : -1,
        );
      case GActiveFormSection.reportedRecitations:
        return ReportedDataSection(
            reportedRecitations: _reporteds,
            loadingStateChanged: _loadingStateChanged,
            snackbarNeeded: _snackbarNeeded);
      case GActiveFormSection.profiles:
        return ProfilesDataSection(
            profiles: _profiles,
            loadingStateChanged: _loadingStateChanged,
            snackbarNeeded: _snackbarNeeded);
      case GActiveFormSection.notifications:
        return NotificationsDataSection(
            notifications: _notifications,
            loadingStateChanged: _loadingStateChanged,
            snackbarNeeded: _snackbarNeeded,
            updateUnreadNotificationsCount: _updateUnreadNotificationsCount);
      case GActiveFormSection.synchronizationQueue:
        return PublishQueueSection(queue: _queue);
      case GActiveFormSection.uploads:
      default:
        return UploadsDataSection(uploads: _uploads);
    }
  }

  String get currentPageText {
    if ((_activeSection == GActiveFormSection.draftRecitations ||
        _activeSection == GActiveFormSection.allMyRecitations ||
        _activeSection == GActiveFormSection.allUsersPendingRecitations)) {
      return 'صفحهٔ ${_narrations.paginationMetadata!.currentPage} از ${_narrations.paginationMetadata!.totalPages} (${_narrations.items!.length} از ${_narrations.paginationMetadata!.totalCount})';
    }
    if (_activeSection == GActiveFormSection.uploads) {
      return 'صفحهٔ ${_uploads.paginationMetadata!.currentPage} از ${_uploads.paginationMetadata!.totalPages} (${_uploads.items!.length} از ${_uploads.paginationMetadata!.totalCount})';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: _key,
        child: LoadingOverlay(
            isLoading: _isLoading,
            child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'تازه‌سازی',
                      onPressed: () async {
                        await _loadData();
                      }),
                  Visibility(
                    visible: _activeSection != GActiveFormSection.uploads,
                    child: IconButton(
                        icon: const Icon(Icons.check_box),
                        tooltip: 'علامتگذاری همه',
                        onPressed: () {
                          if (_activeSection == GActiveFormSection.profiles) {
                            for (var item in _profiles.items!) {
                              setState(() {
                                item.isMarked = true;
                              });
                            }
                          } else if (_activeSection ==
                              GActiveFormSection.notifications) {
                            for (var item in _notifications.items!) {
                              setState(() {
                                item.isMarked = true;
                              });
                            }
                          } else {
                            for (var item in _narrations.items!) {
                              setState(() {
                                item.isMarked = true;
                              });
                            }
                          }
                        }),
                  ),
                  Visibility(
                    visible: _activeSection != GActiveFormSection.uploads,
                    child: IconButton(
                        icon: const Icon(Icons.check_box_outline_blank),
                        tooltip: 'برداشتن علامت همه',
                        onPressed: () {
                          if (_activeSection == GActiveFormSection.profiles) {
                            for (var item in _profiles.items!) {
                              setState(() {
                                item.isMarked = false;
                              });
                            }
                          } else if (_activeSection ==
                              GActiveFormSection.notifications) {
                            for (var item in _notifications.items!) {
                              setState(() {
                                item.isMarked = false;
                              });
                            }
                          } else {
                            for (var item in _narrations.items!) {
                              setState(() {
                                item.isMarked = false;
                              });
                            }
                          }
                        }),
                  ),
                  Visibility(
                      visible: _activeSection ==
                              GActiveFormSection.allMyRecitations ||
                          _activeSection == GActiveFormSection.draftRecitations,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'اعمال نمایهٔ پیش‌فرض',
                        onPressed: () async {
                          await _applyDefProfileToMarkedRecitations();
                        },
                      )),
                  Visibility(
                      visible:
                          _activeSection == GActiveFormSection.notifications,
                      child: IconButton(
                        icon: const Icon(Icons.mark_as_unread),
                        tooltip: 'خواندم',
                        onPressed: () async {
                          await _changeMarkedNotificationsStatus(true);
                        },
                      )),
                  Visibility(
                      visible:
                          _activeSection == GActiveFormSection.notifications,
                      child: IconButton(
                        icon: const Icon(Icons.mail),
                        tooltip: 'نخوانده بماند',
                        onPressed: () async {
                          await _changeMarkedNotificationsStatus(false);
                        },
                      )),
                  Visibility(
                      visible: _activeSection != GActiveFormSection.uploads &&
                          _activeSection !=
                              GActiveFormSection.reportedRecitations,
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'حذف',
                        onPressed: () async {
                          if (_activeSection == GActiveFormSection.profiles) {
                            await _deleteMarkedProfiles();
                          } else if (_activeSection ==
                              GActiveFormSection.notifications) {
                            await _deleteMarkedNotificaions();
                          } else {
                            await _deleteMarkedRecitations();
                          }
                        },
                      )),
                  Visibility(
                      visible: _activeSection ==
                              GActiveFormSection.draftRecitations &&
                          !_canPublish,
                      child: IconButton(
                        icon: const Icon(Icons.publish),
                        tooltip: 'درخواست بررسی',
                        onPressed: () async {
                          var markedNarrations = _narrations.items!
                              .where((element) => element.isMarked)
                              .toList();
                          if (markedNarrations.isEmpty) {
                            _key.currentState!.showSnackBar(const SnackBar(
                              content: Text(
                                  'لطفاً خوانش‌های مد نظر را علامتگذاری کنید.'),
                              backgroundColor: Colors.red,
                            ));
                            return;
                          }
                          String confirmation = markedNarrations.length > 1
                              ? 'آیا از تغییر وضعیت به درخواست بررسی ${markedNarrations.length} خوانش علامتگذاری شده اطمینان دارید؟'
                              : 'آیا از تغییر وضعیت به درخواست بررسی «${markedNarrations[0].audioTitle}» اطمینان دارید؟';
                          if (await _confirm('تأییدیه', confirmation) == true) {
                            setState(() {
                              _isLoading = true;
                            });
                            for (var item in markedNarrations) {
                              item.reviewStatus = 1;
                              var updateRes = await RecitationService()
                                  .updateRecitation(item, false);
                              if (updateRes.item2.isNotEmpty) {
                                _key.currentState!.showSnackBar(SnackBar(
                                  content: Text(
                                      'خطا در تغییر وضعیت خوانش ${item.audioTitle}، اطلاعات بیشتر ${updateRes.item2}'),
                                  backgroundColor: Colors.red,
                                ));
                              }
                              setState(() {
                                _narrations.items!.remove(item);
                              });
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                      )),
                  Visibility(
                      visible: (_activeSection ==
                                  GActiveFormSection.draftRecitations &&
                              _canPublish) ||
                          (_activeSection ==
                              GActiveFormSection.allUsersPendingRecitations),
                      child: IconButton(
                        icon: const Icon(Icons.publish),
                        tooltip: 'انتشار',
                        onPressed: () async {
                          var markedNarrations = _narrations.items!
                              .where((element) => element.isMarked)
                              .toList();
                          if (markedNarrations.isEmpty) {
                            _key.currentState!.showSnackBar(const SnackBar(
                              content: Text(
                                  'لطفاً خوانش‌های مد نظر را علامتگذاری کنید.'),
                              backgroundColor: Colors.red,
                            ));
                            return;
                          }
                          String confirmation = markedNarrations.length > 1
                              ? 'آیا از انتشار ${markedNarrations.length} خوانش علامتگذاری شده اطمینان دارید؟'
                              : 'آیا از انتشار «${markedNarrations[0].audioTitle}» اطمینان دارید؟';
                          if (await _confirm('تأییدیه', confirmation) == true) {
                            setState(() {
                              _isLoading = true;
                            });
                            for (var item in markedNarrations) {
                              item.reviewStatus = 1;
                              var updateRes = await RecitationService()
                                  .moderateRecitation(
                                      item.id,
                                      RecitationModerationResult.approve,
                                      '',
                                      false);
                              if (updateRes.item2.isNotEmpty) {
                                _key.currentState!.showSnackBar(SnackBar(
                                  content: Text(
                                      'خطا در تغییر وضعیت خوانش ${item.audioTitle}، اطلاعات بیشتر ${updateRes.item2}'),
                                  backgroundColor: Colors.red,
                                ));
                              }
                              setState(() {
                                _narrations.items!.remove(item);
                              });
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                      )),
                  Visibility(
                    visible: _activeSection == GActiveFormSection.profiles,
                    child: IconButton(
                      tooltip: 'انتقال مالکیت',
                      icon: const Icon(Icons.transfer_within_a_station),
                      onPressed: () async {
                        await _transferOwnership();
                      },
                    ),
                  ),
                  Visibility(
                    visible: _canPublish &&
                        _activeSection ==
                            GActiveFormSection.synchronizationQueue,
                    child: IconButton(
                      icon: const Icon(Icons.upload_file),
                      tooltip: 'تلاش مجدد',
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        var ret = await RecitationService().retryPublish(false);
                        setState(() {
                          _isLoading = false;
                        });
                        if (ret.isNotEmpty) {
                          _key.currentState!.showSnackBar(SnackBar(
                            content: Text('خطا در تلاش مجدد: $ret'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                    ),
                  ),
                  Visibility(
                    visible: _canReOrder &&
                        _activeSection == GActiveFormSection.profiles,
                    child: IconButton(
                        icon: const Icon(Icons.people),
                        tooltip: 'انتقال خوانش‌های فریدون فرح‌اندوز',
                        onPressed: () async {
                          if (await _confirm('انتقال به بالا',
                                  'از انتقال خوانشهای فریدون فرح‌اندوز به بالا اطمینان دارید؟') ==
                              true) {
                            setState(() {
                              _isLoading = true;
                            });

                            var ret = await RecitationService()
                                .makeFFRecitationsFirst(false);

                            setState(() {
                              _isLoading = false;
                            });

                            if (ret.item2.isNotEmpty) {
                              _key.currentState!.showSnackBar(SnackBar(
                                content: Text(ret.item2),
                                backgroundColor: Colors.red,
                              ));
                            } else {
                              _key.currentState!.showSnackBar(SnackBar(
                                content: Text(
                                    'تعداد خوانش‌های تحت تأثیر قرار گرفته: ${ret.item1}'),
                                backgroundColor: Colors.green,
                              ));
                            }
                          }
                        }),
                  ),
                ],
              ),
              drawer: Drawer(
                // Add a ListView to the drawer. This ensures the user can scroll
                // through the options in the drawer if there isn't enough vertical
                // space to fit everything.
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      child: Column(
                        children: [
                          Text(
                            'سلام $_userFrinedlyName',
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text('خوانش‌های پیش‌نویس من'),
                      leading: Icon(Icons.music_note,
                          color: Theme.of(context).primaryColor),
                      selected:
                          _activeSection == GActiveFormSection.draftRecitations,
                      onTap: () async {
                        if (_activeSection !=
                            GActiveFormSection.draftRecitations) {
                          setState(() {
                            _narrations.items!.clear();
                            _narrationsPageNumber = 1;
                            _activeSection =
                                GActiveFormSection.draftRecitations;
                          });
                          await _loadData();

                          if (!mounted) return;

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('بارگذاری‌های من'),
                      leading: Icon(Icons.upload_file,
                          color: Theme.of(context).primaryColor),
                      selected: _activeSection == GActiveFormSection.uploads,
                      onTap: () async {
                        if (_activeSection != GActiveFormSection.uploads) {
                          setState(() {
                            _activeSection = GActiveFormSection.uploads;
                          });
                          await _loadData();

                          if (!mounted) return;

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('همهٔ خوانش‌های من'),
                      leading: Icon(Icons.music_note,
                          color: Theme.of(context).primaryColor),
                      selected:
                          _activeSection == GActiveFormSection.allMyRecitations,
                      onTap: () async {
                        if (_activeSection !=
                            GActiveFormSection.allMyRecitations) {
                          setState(() {
                            _narrationsPageNumber = 1;
                            _narrations.items!.clear();
                            _activeSection =
                                GActiveFormSection.allMyRecitations;
                          });
                          await _loadData();

                          if (!mounted) return;

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    Visibility(
                        visible: _canModerate,
                        child: ListTile(
                          title: const Text('خوانش‌های در انتظار تأیید'),
                          leading: Icon(Icons.music_note,
                              color: Theme.of(context).primaryColor),
                          selected: _activeSection ==
                              GActiveFormSection.allUsersPendingRecitations,
                          onTap: () async {
                            if (_activeSection !=
                                GActiveFormSection.allUsersPendingRecitations) {
                              setState(() {
                                _narrationsPageNumber = 1;
                                _narrations.items!.clear();
                                _activeSection = GActiveFormSection
                                    .allUsersPendingRecitations;
                              });
                              await _loadData();

                              if (!mounted) return;

                              Navigator.of(context).pop(); //close drawer
                            }
                          },
                        )),
                    Visibility(
                        visible: _canModerate,
                        child: ListTile(
                          title: const Text('خوانش‌های گزارش شده'),
                          leading: Icon(Icons.flag,
                              color: Theme.of(context).primaryColor),
                          selected: _activeSection ==
                              GActiveFormSection.reportedRecitations,
                          onTap: () async {
                            if (_activeSection !=
                                GActiveFormSection.reportedRecitations) {
                              setState(() {
                                _narrationsPageNumber = 1;
                                _reporteds.items!.clear();
                                _activeSection =
                                    GActiveFormSection.reportedRecitations;
                              });
                              await _loadData();

                              if (!mounted) return;

                              Navigator.of(context).pop(); //close drawer
                            }
                          },
                        )),
                    ListTile(
                      title: const Text('نمایه‌های من'),
                      leading: Icon(Icons.people,
                          color: Theme.of(context).primaryColor),
                      selected: _activeSection == GActiveFormSection.profiles,
                      onTap: () async {
                        if (_activeSection != GActiveFormSection.profiles) {
                          setState(() {
                            _activeSection = GActiveFormSection.profiles;
                          });
                          await _loadData();

                          if (!mounted) return;
                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('اعلان‌های من'),
                      leading: Stack(children: <Widget>[
                        Icon(Icons.notifications,
                            color: Theme.of(context).primaryColor),
                        Visibility(
                            visible: _unreadNotificationsCount > 0,
                            child: Positioned(
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                child: Text(
                                  '$_unreadNotificationsCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )),
                      ]),
                      selected:
                          _activeSection == GActiveFormSection.notifications,
                      onTap: () async {
                        if (_activeSection !=
                            GActiveFormSection.notifications) {
                          setState(() {
                            _activeSection = GActiveFormSection.notifications;
                          });
                          await _loadData();

                          if (!mounted) return;

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('صف انتشار در گنجور'),
                      leading: Icon(Icons.send_to_mobile,
                          color: Theme.of(context).primaryColor),
                      selected: _activeSection ==
                          GActiveFormSection.synchronizationQueue,
                      onTap: () async {
                        if (_activeSection !=
                            GActiveFormSection.synchronizationQueue) {
                          setState(() {
                            _activeSection =
                                GActiveFormSection.synchronizationQueue;
                          });
                          await _loadData();

                          if (!mounted) return;

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('خوانش‌های دارای اشکال'),
                      leading: Icon(Icons.music_note,
                          color: Theme.of(context).primaryColor),
                      selected: _activeSection ==
                          GActiveFormSection.recitationsWithMistakes,
                      onTap: () async {
                        if (_activeSection !=
                            GActiveFormSection.recitationsWithMistakes) {
                          setState(() {
                            _narrationsPageNumber = 1;
                            _narrations.items!.clear();
                            _activeSection =
                                GActiveFormSection.recitationsWithMistakes;
                          });
                          await _loadData();

                          if (!mounted) return;

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('خوانش‌های برگشت‌خورده'),
                      leading: Icon(Icons.music_note,
                          color: Theme.of(context).primaryColor),
                      selected: _activeSection ==
                          GActiveFormSection.rejectedRecitaions,
                      onTap: () async {
                        if (_activeSection !=
                            GActiveFormSection.rejectedRecitaions) {
                          setState(() {
                            _narrationsPageNumber = 1;
                            _narrations.items!.clear();
                            _activeSection =
                                GActiveFormSection.rejectedRecitaions;
                          });
                          await _loadData();

                          if (!mounted) return;

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('مشخصات کاربری'),
                      leading: Icon(Icons.person,
                          color: Theme.of(context).primaryColor),
                      onTap: () async {
                        var url = 'https://museum.ganjoor.net/profile';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        } else {
                          throw 'خطا در نمایش نشانی $url';
                        }
                        if (!mounted) return;
                        Navigator.of(context).pop(); //close drawer
                      },
                    ),
                    ListTile(
                      title: const Text('خروج'),
                      leading: Icon(Icons.logout,
                          color: Theme.of(context).primaryColor),
                      onTap: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        await AuthService().logout();

                        setState(() {
                          _isLoading = false;
                        });

                        if (!mounted) return;

                        await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginForm()));
                      },
                    ),
                  ],
                ),
              ),
              persistentFooterButtons: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(currentPageText),
                  Visibility(
                      visible: _activeSection != GActiveFormSection.profiles &&
                          _activeSection != GActiveFormSection.notifications,
                      child: IconButton(
                        icon: const Icon(Icons.first_page),
                        tooltip: 'اولین صفحه',
                        onPressed: () async {
                          if (_activeSection ==
                                  GActiveFormSection.draftRecitations ||
                              _activeSection ==
                                  GActiveFormSection.allMyRecitations ||
                              _activeSection ==
                                  GActiveFormSection
                                      .allUsersPendingRecitations ||
                              _activeSection ==
                                  GActiveFormSection.recitationsWithMistakes ||
                              _activeSection ==
                                  GActiveFormSection.rejectedRecitaions ||
                              _activeSection ==
                                  GActiveFormSection.reportedRecitations) {
                            _narrationsPageNumber = 1;
                            await _loadData();
                          } else if (_activeSection ==
                              GActiveFormSection.uploads) {
                            _uploadsPageNumber = 1;
                            await _loadData();
                          }
                        },
                      )),
                  Visibility(
                      visible: _activeSection != GActiveFormSection.profiles &&
                          _activeSection != GActiveFormSection.notifications,
                      child: IconButton(
                        icon: const Icon(Icons.navigate_before),
                        tooltip: 'صفحهٔ قبل',
                        onPressed: () async {
                          if (_activeSection ==
                                  GActiveFormSection.draftRecitations ||
                              _activeSection ==
                                  GActiveFormSection.allMyRecitations ||
                              _activeSection ==
                                  GActiveFormSection
                                      .allUsersPendingRecitations ||
                              _activeSection ==
                                  GActiveFormSection.recitationsWithMistakes ||
                              _activeSection ==
                                  GActiveFormSection.rejectedRecitaions ||
                              _activeSection ==
                                  GActiveFormSection.reportedRecitations) {
                            _narrationsPageNumber =
                                _narrations.paginationMetadata == null
                                    ? 1
                                    : _narrations
                                            .paginationMetadata!.currentPage -
                                        1;
                            if (_narrationsPageNumber <= 0) {
                              _narrationsPageNumber = 1;
                            }
                            await _loadData();
                          } else if (_activeSection ==
                              GActiveFormSection.uploads) {
                            _uploadsPageNumber = _uploads.paginationMetadata ==
                                    null
                                ? 1
                                : _uploads.paginationMetadata!.currentPage - 1;
                            if (_uploadsPageNumber <= 0) _uploadsPageNumber = 1;
                            await _loadData();
                          }
                        },
                      )),
                  Visibility(
                      visible: _activeSection != GActiveFormSection.profiles &&
                          _activeSection != GActiveFormSection.notifications,
                      child: IconButton(
                        icon: const Icon(Icons.navigate_next),
                        tooltip: 'صفحهٔ بعد',
                        onPressed: () async {
                          if (_activeSection ==
                                  GActiveFormSection.draftRecitations ||
                              _activeSection ==
                                  GActiveFormSection.allMyRecitations ||
                              _activeSection ==
                                  GActiveFormSection
                                      .allUsersPendingRecitations ||
                              _activeSection ==
                                  GActiveFormSection.recitationsWithMistakes ||
                              _activeSection ==
                                  GActiveFormSection.rejectedRecitaions ||
                              _activeSection ==
                                  GActiveFormSection.reportedRecitations) {
                            _narrationsPageNumber =
                                _narrations.paginationMetadata == null
                                    ? 1
                                    : _narrations
                                            .paginationMetadata!.currentPage +
                                        1;
                            await _loadData();
                          } else if (_activeSection ==
                              GActiveFormSection.uploads) {
                            _uploadsPageNumber = _uploads.paginationMetadata ==
                                    null
                                ? 1
                                : _uploads.paginationMetadata!.currentPage + 1;
                            await _loadData();
                          }
                        },
                      )),
                  Visibility(
                      visible: _activeSection != GActiveFormSection.profiles &&
                          _activeSection != GActiveFormSection.notifications,
                      child: IconButton(
                        icon: const Icon(Icons.last_page),
                        tooltip: 'صفحهٔ آخر',
                        onPressed: () async {
                          if (_activeSection ==
                                  GActiveFormSection.draftRecitations ||
                              _activeSection ==
                                  GActiveFormSection.allMyRecitations ||
                              _activeSection ==
                                  GActiveFormSection
                                      .allUsersPendingRecitations ||
                              _activeSection ==
                                  GActiveFormSection.recitationsWithMistakes ||
                              _activeSection ==
                                  GActiveFormSection.rejectedRecitaions ||
                              _activeSection ==
                                  GActiveFormSection.reportedRecitations) {
                            _narrationsPageNumber =
                                _narrations.paginationMetadata == null
                                    ? 1
                                    : _narrations
                                        .paginationMetadata!.totalPages;
                            await _loadData();
                          } else if (_activeSection ==
                              GActiveFormSection.uploads) {
                            _uploadsPageNumber =
                                _uploads.paginationMetadata == null
                                    ? 1
                                    : _uploads.paginationMetadata!.totalPages;
                            await _loadData();
                          }
                        },
                      )),
                  Visibility(
                      visible: _activeSection != GActiveFormSection.uploads &&
                          _activeSection != GActiveFormSection.notifications &&
                          _activeSection !=
                              GActiveFormSection.recitationsWithMistakes &&
                          _activeSection !=
                              GActiveFormSection.rejectedRecitaions &&
                          _activeSection !=
                              GActiveFormSection.reportedRecitations,
                      child: IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: 'جستجو',
                        onPressed: () async {
                          var res = await _getSearchParams();
                          setState(() {
                            _pageSize = res!.item1;
                            _searchTerm = res.item2;
                          });
                          await _loadData();
                        },
                      )),
                  IconButton(
                    icon: Stack(children: <Widget>[
                      const Icon(Icons.notifications),
                      Visibility(
                          visible: _unreadNotificationsCount > 0,
                          child: Positioned(
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                '$_unreadNotificationsCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )),
                    ]),
                    tooltip: 'اعلان‌های من',
                    onPressed: () async {
                      if (_activeSection != GActiveFormSection.notifications) {
                        setState(() {
                          _activeSection = GActiveFormSection.notifications;
                        });
                        await _loadData();
                      }
                    },
                  ),
                ])
              ],
              body: Builder(builder: (context) => Center(child: items)),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  switch (_activeSection) {
                    case GActiveFormSection.draftRecitations:
                    case GActiveFormSection.allMyRecitations:
                    case GActiveFormSection.allUsersPendingRecitations:
                    case GActiveFormSection.uploads:
                    case GActiveFormSection.notifications:
                    case GActiveFormSection.reportedRecitations:
                    case GActiveFormSection.rejectedRecitaions:
                    case GActiveFormSection.recitationsWithMistakes:
                    case GActiveFormSection.synchronizationQueue:
                      if (!_audioUpdateEnabled) {
                        _key.currentState!.showSnackBar(const SnackBar(
                          content: Text(
                              'ارسال خوانش جدید به دلیل تغییرات فنی سایت موقتاً غیرفعال است.'),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      }
                      await _newNarrations();
                      if (_activeSection == GActiveFormSection.uploads) {
                        await _loadData();
                      }
                      break;
                    case GActiveFormSection.profiles:
                      var result = await _newProfile();
                      setState(() {
                        _isLoading = true;
                      });
                      var serviceResult =
                          await RecitationService().addProfile(result!, false);
                      setState(() {
                        _isLoading = false;
                      });
                      if (serviceResult.item2 == '') {
                        setState(() {
                          if (serviceResult.item1!.isDefault) {
                            for (var item in _profiles.items!) {
                              item.isDefault = false;
                            }
                          }
                          _profiles.items!.insert(0, serviceResult.item1!);
                        });
                      } else {
                        _key.currentState!.showSnackBar(SnackBar(
                          content: Text(
                              'خطا در ایجاد نمایه: ${serviceResult.item2}'),
                          backgroundColor: Colors.red,
                        ));
                      }
                      break;
                  }
                },
                tooltip: _activeSection == GActiveFormSection.profiles
                    ? 'ایجاد نمایهٔ جدید'
                    : 'ارسال خوانش‌های جدید',
                child: const Icon(Icons.add),
              ),
            )));
  }
}
