import 'package:after_layout/after_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/login.dart';
import 'package:gaudiopanel/forms/main-form-sections/profiles-data-section.dart';
import 'package:gaudiopanel/forms/profile-edit.dart';
import 'package:gaudiopanel/forms/upload-files.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/recitation/recitation-viewmodel.dart';
import 'package:gaudiopanel/models/recitation/uploaded-item-viewmodel.dart';
import 'package:gaudiopanel/models/recitation/user-recitation-profile-viewmodel.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:gaudiopanel/services/upload-recitation-service.dart';
import 'package:gaudiopanel/services/recitation-service.dart';
import 'package:gaudiopanel/forms/main-form-sections/recitations-data-section.dart';
import 'package:gaudiopanel/forms/main-form-sections/uploads-data-section.dart';
import 'package:loading_overlay/loading_overlay.dart';

enum GActiveFormSection {
  DraftRecitations,
  AllMyRecitations,
  AllUsersPendingRecitations,
  Uploads,
  Profiles
}

class MainForm extends StatefulWidget {
  @override
  MainFormWidgetState createState() => MainFormWidgetState();
}

class MainFormWidgetState extends State<MainForm>
    with AfterLayoutMixin<MainForm> {
  final GlobalKey<ScaffoldMessengerState> _key =
      GlobalKey<ScaffoldMessengerState>();
  bool _canModerate = false;
  bool _isLoading = false;
  GActiveFormSection _activeSection = GActiveFormSection.DraftRecitations;
  int _narrationsPageNumber = 1;
  int _uploadsPageNumber = 1;
  int _pageSize = 20;
  PaginatedItemsResponseModel<RecitationViewModel> _narrations =
      PaginatedItemsResponseModel<RecitationViewModel>(items: []);
  PaginatedItemsResponseModel<UploadedItemViewModel> _uploads =
      PaginatedItemsResponseModel<UploadedItemViewModel>(items: []);
  PaginatedItemsResponseModel<UserRecitationProfileViewModel> _profiles =
      PaginatedItemsResponseModel<UserRecitationProfileViewModel>(items: []);
  String get title {
    switch (_activeSection) {
      case GActiveFormSection.Uploads:
        return 'پیشخان خوانشگران گنجور » بارگذاری‌های من';
      case GActiveFormSection.Profiles:
        return 'پیشخان خوانشگران گنجور » نمایه‌های من';
      case GActiveFormSection.DraftRecitations:
        return 'پیشخان خوانشگران گنجور » خوانش‌های پیش‌نویس من';
      case GActiveFormSection.AllMyRecitations:
        return 'پیشخان خوانشگران گنجور » همهٔ خوانش‌های من';
      case GActiveFormSection.AllUsersPendingRecitations:
        return 'پیشخان خوانشگران گنجور » خوانش‌های در انتظار تأیید';
    }
    return '';
  }

  Future<void> _loadNarrationsData() async {
    setState(() {
      _isLoading = true;
    });
    var narrations = await RecitationService().getRecitations(
        _narrationsPageNumber,
        _pageSize,
        _activeSection == GActiveFormSection.AllUsersPendingRecitations,
        _activeSection == GActiveFormSection.AllMyRecitations
            ? -1
            : _activeSection == GActiveFormSection.AllUsersPendingRecitations
                ? 1
                : 0,
        false);
    if (narrations.error.isEmpty) {
      setState(() {
        _narrations.items.clear();
        _narrations.items.addAll(narrations.items);
        _narrations.paginationMetadata = narrations.paginationMetadata;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _key.currentState.showSnackBar(SnackBar(
        content: Text("خطا در دریافت خوانش‌ها: " + narrations.error),
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

    if (uploads.error.isEmpty) {
      setState(() {
        _uploads.items.clear();
        _uploads.items.addAll(uploads.items);
        _uploads.paginationMetadata = uploads.paginationMetadata;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _key.currentState.showSnackBar(SnackBar(
        content: Text("خطا در دریافت بارگذاری‌ها: " + uploads.error),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _loadProfilesData() async {
    setState(() {
      _isLoading = true;
    });
    var profiles = await RecitationService().getProfiles(false);

    if (profiles.item2.isEmpty) {
      setState(() {
        _profiles.items.addAll(profiles.item1);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _key.currentState.showSnackBar(SnackBar(
        content: Text("خطا در دریافت نمایه‌ها: " + profiles.item2),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _loadData() async {
    switch (_activeSection) {
      case GActiveFormSection.DraftRecitations:
      case GActiveFormSection.AllMyRecitations:
      case GActiveFormSection.AllUsersPendingRecitations:
        await _loadNarrationsData();
        break;
      case GActiveFormSection.Uploads:
        await _loadUploadsData();
        break;
      case GActiveFormSection.Profiles:
        await _loadProfilesData();
        break;
    }
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    if (await AuthService().hasPermission('narration', 'moderate')) {
      setState(() {
        _canModerate = true;
      });
    }
    await _loadData();
  }

  void _loadingStateChanged(bool isLoading) {
    setState(() {
      this._isLoading = isLoading;
    });
  }

  void _snackbarNeeded(String msg) {
    _key.currentState.showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    ));
  }

  Future<UserRecitationProfileViewModel> _newProfile() async {
    return showDialog<UserRecitationProfileViewModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        ProfileEdit _profileEdit = ProfileEdit(
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
          title: Text('نمایهٔ جدید'),
          content: SingleChildScrollView(
            child: _profileEdit,
          ),
        );
      },
    );
  }

  Future<bool> _getNewRecitationParams(
      UserRecitationProfileViewModel profile) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        UploadFiles _uploadFiles = UploadFiles(profile: profile);
        return AlertDialog(
          title: Text('ارسال خوانش‌های جدید'),
          content: SingleChildScrollView(
            child: _uploadFiles,
          ),
        );
      },
    );
  }

  Future<bool> _confirm(String title, String text) async {
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
              child: Text('بله'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text('خیر'),
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
    setState(() {
      _isLoading = true;
    });
    var profileResult = await RecitationService().getDefProfile(false);
    setState(() {
      _isLoading = false;
    });
    if (profileResult.item2.isNotEmpty) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text('خطا در یافتن نمایهٔ پیش‌فرض ' +
            '، اطلاعات بیشتر ' +
            profileResult.item2),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (profileResult.item1 == null) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text(
            'برای ارسال خوانش لازم است ابتدا نمایه‌ای پیش‌فرض تعریف کنید.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    var replace = await _getNewRecitationParams(profileResult.item1);
    if (replace == null) {
      return;
    }
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'xml'],
    );
    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      String err = await UploadRecitationService()
          .uploadFiles(result.files, replace, false);

      if (err.isNotEmpty) {
        _key.currentState.showSnackBar(SnackBar(
          content: Text("خطا در ارسال خوانش‌های جدید: " + err),
          backgroundColor: Colors.red,
        ));
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _deleteMarkedProfiles() async {
    var markedProfiles =
        _profiles.items.where((element) => element.isMarked).toList();
    if (markedProfiles.isEmpty) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text('لطفاً نمایه‌های مد نظر را علامتگذاری کنید.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    String confirmation = markedProfiles.length > 1
        ? 'آیا از حذف ' +
            markedProfiles.length.toString() +
            ' نمایهٔ علامتگذاری شده اطمینان دارید؟'
        : 'آیا از حذف نمایهٔ «' + markedProfiles[0].name + '» اطمینان دارید؟';
    if (await _confirm('تأییدیه', confirmation)) {
      for (var item in markedProfiles) {
        var delRes = await RecitationService().deleteProfile(item.id, false);
        if (delRes.item2.isNotEmpty) {
          _key.currentState.showSnackBar(SnackBar(
            content: Text('خطا در حذف نمایهٔ ' +
                item.name +
                '، اطلاعات بیشتر ' +
                delRes.item2),
            backgroundColor: Colors.red,
          ));
        }
        if (delRes.item1) {
          setState(() {
            _profiles.items.remove(item);
          });
        }
      }
    }
  }

  Future _deleteMarkedRecitations() async {
    var markedRecitations =
        _narrations.items.where((element) => element.isMarked).toList();
    if (markedRecitations.isEmpty) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text('لطفاً خوانش‌های مد نظر را علامتگذاری کنید.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    String confirmation = markedRecitations.length > 1
        ? 'آیا از حذف ' +
            markedRecitations.length.toString() +
            ' خوانش علامتگذاری شده اطمینان دارید؟'
        : 'آیا از حذف خوامش «' +
            markedRecitations[0].audioTitle +
            '» اطمینان دارید؟';
    if (await _confirm('تأییدیه', confirmation)) {
      for (var item in markedRecitations) {
        var delRes = await RecitationService().deleteRecitation(item.id, false);
        if (delRes.item2.isNotEmpty) {
          _key.currentState.showSnackBar(SnackBar(
            content: Text('خطا در حذف خوانش ' +
                item.audioTitle +
                '، اطلاعات بیشتر ' +
                delRes.item2),
            backgroundColor: Colors.red,
          ));
        }
        if (delRes.item1) {
          setState(() {
            _narrations.items.remove(item);
          });
        }
      }
    }
  }

  Widget get items {
    switch (_activeSection) {
      case GActiveFormSection.DraftRecitations:
      case GActiveFormSection.AllMyRecitations:
      case GActiveFormSection.AllUsersPendingRecitations:
      case GActiveFormSection.DraftRecitations:
        return RecitationsDataSection(
          narrations: _narrations,
          loadingStateChanged: _loadingStateChanged,
          snackbarNeeded: _snackbarNeeded,
          status: _activeSection == GActiveFormSection.DraftRecitations
              ? 0
              : _activeSection == GActiveFormSection.AllUsersPendingRecitations
                  ? 1
                  : -1,
        );
      case GActiveFormSection.Profiles:
        return ProfilesDataSection(
            profiles: _profiles,
            loadingStateChanged: _loadingStateChanged,
            snackbarNeeded: _snackbarNeeded);
      case GActiveFormSection.Uploads:
      default:
        return UploadsDataSection(uploads: _uploads);
    }
  }

  String get currentPageText {
    if (_narrations != null &&
        _narrations.paginationMetadata != null &&
        (_activeSection == GActiveFormSection.DraftRecitations ||
            _activeSection == GActiveFormSection.AllMyRecitations ||
            _activeSection == GActiveFormSection.AllUsersPendingRecitations)) {
      return 'صفحهٔ ' +
          _narrations.paginationMetadata.currentPage.toString() +
          ' از ' +
          _narrations.paginationMetadata.totalPages.toString() +
          ' (' +
          _narrations.items.length.toString() +
          ' از ' +
          _narrations.paginationMetadata.totalCount.toString() +
          ')';
    }
    if (_activeSection == GActiveFormSection.Uploads &&
        _uploads != null &&
        _uploads.paginationMetadata != null) {
      return 'صفحهٔ ' +
          _uploads.paginationMetadata.currentPage.toString() +
          ' از ' +
          _uploads.paginationMetadata.totalPages.toString() +
          ' (' +
          _uploads.items.length.toString() +
          ' از ' +
          _uploads.paginationMetadata.totalCount.toString() +
          ')';
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
                  Visibility(
                    child: IconButton(
                        icon: Icon(Icons.check_box),
                        tooltip: 'علامتگذاری همه',
                        onPressed: () {
                          if (_activeSection == GActiveFormSection.Profiles) {
                            for (var item in _profiles.items) {
                              setState(() {
                                item.isMarked = true;
                              });
                            }
                          } else {
                            for (var item in _narrations.items) {
                              setState(() {
                                item.isMarked = true;
                              });
                            }
                          }
                        }),
                    visible: _activeSection != GActiveFormSection.Uploads,
                  ),
                  Visibility(
                    child: IconButton(
                        icon: Icon(Icons.check_box_outline_blank),
                        tooltip: 'برداشتن علامت همه',
                        onPressed: () {
                          if (_activeSection == GActiveFormSection.Profiles) {
                            for (var item in _profiles.items) {
                              setState(() {
                                item.isMarked = false;
                              });
                            }
                          } else {
                            for (var item in _narrations.items) {
                              setState(() {
                                item.isMarked = false;
                              });
                            }
                          }
                        }),
                    visible: _activeSection != GActiveFormSection.Uploads,
                  ),
                  Visibility(
                      child: IconButton(
                        icon: Icon(Icons.delete),
                        tooltip: 'حذف',
                        onPressed: () async {
                          if (_activeSection == GActiveFormSection.Profiles) {
                            await _deleteMarkedProfiles();
                          } else {
                            await _deleteMarkedRecitations();
                          }
                        },
                      ),
                      visible: _activeSection != GActiveFormSection.Uploads),
                  Visibility(
                      child: IconButton(
                        icon: Icon(Icons.publish),
                        tooltip: 'درخواست بررسی',
                        onPressed: () async {
                          var markedNarrations = _narrations.items
                              .where((element) => element.isMarked)
                              .toList();
                          if (markedNarrations.isEmpty) {
                            _key.currentState.showSnackBar(SnackBar(
                              content: Text(
                                  'لطفاً خوانش‌های مد نظر را علامتگذاری کنید.'),
                              backgroundColor: Colors.red,
                            ));
                            return;
                          }
                          String confirmation = markedNarrations.length > 1
                              ? 'آیا از تغییر وضعیت به درخواست بررسی ' +
                                  markedNarrations.length.toString() +
                                  ' خوانش علامتگذاری شده اطمینان دارید؟'
                              : 'آیا از تغییر وضعیت به درخواست بررسی «' +
                                  markedNarrations[0].audioTitle +
                                  '» اطمینان دارید؟';
                          if (await _confirm('تأییدیه', confirmation)) {
                            setState(() {
                              _isLoading = true;
                            });
                            for (var item in markedNarrations) {
                              item.reviewStatus = 1;
                              var updateRes = await RecitationService()
                                  .updateRecitation(item, false);
                              if (updateRes.item2.isNotEmpty) {
                                _key.currentState.showSnackBar(SnackBar(
                                  content: Text('خطا در تغییر وضعیت خوانش ' +
                                      item.audioTitle +
                                      '، اطلاعات بیشتر ' +
                                      updateRes.item2),
                                  backgroundColor: Colors.red,
                                ));
                              }
                              if (updateRes.item1 != null) {
                                setState(() {
                                  _narrations.items.remove(item);
                                });
                              }
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                      ),
                      visible: _activeSection ==
                              GActiveFormSection.DraftRecitations &&
                          !_canModerate),
                  Visibility(
                      child: IconButton(
                        icon: Icon(Icons.publish),
                        tooltip: 'انتشار',
                        onPressed: () async {
                          var markedNarrations = _narrations.items
                              .where((element) => element.isMarked)
                              .toList();
                          if (markedNarrations.isEmpty) {
                            _key.currentState.showSnackBar(SnackBar(
                              content: Text(
                                  'لطفاً خوانش‌های مد نظر را علامتگذاری کنید.'),
                              backgroundColor: Colors.red,
                            ));
                            return;
                          }
                          String confirmation = markedNarrations.length > 1
                              ? 'آیا از انتشار ' +
                                  markedNarrations.length.toString() +
                                  ' خوانش علامتگذاری شده اطمینان دارید؟'
                              : 'آیا از انتشار «' +
                                  markedNarrations[0].audioTitle +
                                  '» اطمینان دارید؟';
                          if (await _confirm('تأییدیه', confirmation)) {
                            setState(() {
                              _isLoading = true;
                            });
                            for (var item in markedNarrations) {
                              item.reviewStatus = 1;
                              var updateRes = await RecitationService()
                                  .moderateRecitation(
                                      item.id,
                                      RecitationModerationResult.Approve,
                                      '',
                                      false);
                              if (updateRes.item2.isNotEmpty) {
                                _key.currentState.showSnackBar(SnackBar(
                                  content: Text('خطا در تغییر وضعیت خوانش ' +
                                      item.audioTitle +
                                      '، اطلاعات بیشتر ' +
                                      updateRes.item2),
                                  backgroundColor: Colors.red,
                                ));
                              }
                              if (updateRes.item1 != null) {
                                setState(() {
                                  _narrations.items.remove(item);
                                });
                              }
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                      ),
                      visible: (_activeSection ==
                                  GActiveFormSection.DraftRecitations &&
                              _canModerate) ||
                          _activeSection ==
                              GActiveFormSection.AllUsersPendingRecitations)
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
                            'سلام!',
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text('خوانش‌های پیش‌نویس من'),
                      leading: Icon(Icons.music_note,
                          color: Theme.of(context).primaryColor),
                      selected:
                          _activeSection == GActiveFormSection.DraftRecitations,
                      onTap: () async {
                        if (_activeSection !=
                            GActiveFormSection.DraftRecitations) {
                          setState(() {
                            _narrations.items.clear();
                            _narrationsPageNumber = 1;
                            _activeSection =
                                GActiveFormSection.DraftRecitations;
                          });
                          await _loadData();

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: Text('بارگذاری‌های من'),
                      leading: Icon(Icons.upload_file,
                          color: Theme.of(context).primaryColor),
                      selected: _activeSection == GActiveFormSection.Uploads,
                      onTap: () async {
                        if (_activeSection != GActiveFormSection.Uploads) {
                          setState(() {
                            _activeSection = GActiveFormSection.Uploads;
                          });
                          if (_uploads.items.length == 0) {
                            await _loadData();
                          }

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: Text('همهٔ خوانش‌های من'),
                      leading: Icon(Icons.music_note,
                          color: Theme.of(context).primaryColor),
                      selected:
                          _activeSection == GActiveFormSection.AllMyRecitations,
                      onTap: () async {
                        if (_activeSection !=
                            GActiveFormSection.AllMyRecitations) {
                          setState(() {
                            _narrationsPageNumber = 1;
                            _narrations.items.clear();
                            _activeSection =
                                GActiveFormSection.AllMyRecitations;
                          });
                          await _loadData();

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    Visibility(
                        child: ListTile(
                          title: Text('خوانش‌های در انتظار تأیید'),
                          leading: Icon(Icons.music_note,
                              color: Theme.of(context).primaryColor),
                          selected: _activeSection ==
                              GActiveFormSection.AllUsersPendingRecitations,
                          onTap: () async {
                            if (_activeSection !=
                                GActiveFormSection.AllUsersPendingRecitations) {
                              setState(() {
                                _narrationsPageNumber = 1;
                                _narrations.items.clear();
                                _activeSection = GActiveFormSection
                                    .AllUsersPendingRecitations;
                              });
                              await _loadData();

                              Navigator.of(context).pop(); //close drawer
                            }
                          },
                        ),
                        visible: _canModerate),
                    ListTile(
                      title: Text('نمایه‌های من'),
                      leading: Icon(Icons.people,
                          color: Theme.of(context).primaryColor),
                      selected: _activeSection == GActiveFormSection.Profiles,
                      onTap: () async {
                        if (_activeSection != GActiveFormSection.Profiles) {
                          setState(() {
                            _activeSection = GActiveFormSection.Profiles;
                          });
                          if (_profiles.items.length == 0) {
                            await _loadData();
                          }

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: Text('خروج'),
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

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginForm()));
                      },
                    ),
                  ],
                ),
              ),
              persistentFooterButtons: [
                Text(currentPageText),
                Visibility(
                    child: IconButton(
                      icon: Icon(Icons.first_page),
                      onPressed: () async {
                        if (_activeSection ==
                                GActiveFormSection.DraftRecitations ||
                            _activeSection ==
                                GActiveFormSection.AllMyRecitations ||
                            _activeSection ==
                                GActiveFormSection.AllUsersPendingRecitations) {
                          _narrationsPageNumber = 1;
                          await _loadData();
                        } else if (_activeSection ==
                            GActiveFormSection.Uploads) {
                          _uploadsPageNumber = 1;
                          await _loadData();
                        }
                      },
                    ),
                    visible: _activeSection != GActiveFormSection.Profiles),
                Visibility(
                    child: IconButton(
                      icon: Icon(Icons.navigate_before),
                      onPressed: () async {
                        if (_activeSection ==
                                GActiveFormSection.DraftRecitations ||
                            _activeSection ==
                                GActiveFormSection.AllMyRecitations ||
                            _activeSection ==
                                GActiveFormSection.AllUsersPendingRecitations) {
                          _narrationsPageNumber =
                              _narrations.paginationMetadata == null
                                  ? 1
                                  : _narrations.paginationMetadata.currentPage -
                                      1;
                          if (_narrationsPageNumber <= 0)
                            _narrationsPageNumber = 1;
                          await _loadData();
                        } else if (_activeSection ==
                            GActiveFormSection.Uploads) {
                          _uploadsPageNumber =
                              _uploads.paginationMetadata == null
                                  ? 1
                                  : _uploads.paginationMetadata.currentPage - 1;
                          if (_uploadsPageNumber <= 0) _uploadsPageNumber = 1;
                          await _loadData();
                        }
                      },
                    ),
                    visible: _activeSection != GActiveFormSection.Profiles),
                Visibility(
                    child: IconButton(
                      icon: Icon(Icons.navigate_next),
                      onPressed: () async {
                        if (_activeSection ==
                                GActiveFormSection.DraftRecitations ||
                            _activeSection ==
                                GActiveFormSection.AllMyRecitations ||
                            _activeSection ==
                                GActiveFormSection.AllUsersPendingRecitations) {
                          _narrationsPageNumber =
                              _narrations.paginationMetadata == null
                                  ? 1
                                  : _narrations.paginationMetadata.currentPage +
                                      1;
                          await _loadData();
                        } else if (_activeSection ==
                            GActiveFormSection.Uploads) {
                          _uploadsPageNumber =
                              _uploads.paginationMetadata == null
                                  ? 1
                                  : _uploads.paginationMetadata.currentPage + 1;
                          await _loadData();
                        }
                      },
                    ),
                    visible: _activeSection != GActiveFormSection.Profiles),
                Visibility(
                    child: IconButton(
                      icon: Icon(Icons.last_page),
                      onPressed: () async {
                        if (_activeSection ==
                                GActiveFormSection.DraftRecitations ||
                            _activeSection ==
                                GActiveFormSection.AllMyRecitations ||
                            _activeSection ==
                                GActiveFormSection.AllUsersPendingRecitations) {
                          _narrationsPageNumber =
                              _narrations.paginationMetadata == null
                                  ? 1
                                  : _narrations.paginationMetadata.totalPages;
                          await _loadData();
                        } else if (_activeSection ==
                            GActiveFormSection.Uploads) {
                          _uploadsPageNumber =
                              _uploads.paginationMetadata == null
                                  ? 1
                                  : _uploads.paginationMetadata.totalPages;
                          await _loadData();
                        }
                      },
                    ),
                    visible: _activeSection != GActiveFormSection.Profiles),
              ],
              body: Builder(builder: (context) => Center(child: items)),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  switch (_activeSection) {
                    case GActiveFormSection.DraftRecitations:
                    case GActiveFormSection.AllMyRecitations:
                    case GActiveFormSection.AllUsersPendingRecitations:
                    case GActiveFormSection.Uploads:
                      await _newNarrations();
                      if (_activeSection == GActiveFormSection.Uploads) {
                        await _loadData();
                      }
                      break;
                    case GActiveFormSection.Profiles:
                      var result = await _newProfile();
                      if (result != null) {
                        setState(() {
                          _isLoading = true;
                        });
                        var serviceResult =
                            await RecitationService().addProfile(result, false);
                        setState(() {
                          _isLoading = false;
                        });
                        if (serviceResult.item2 == '') {
                          setState(() {
                            if (serviceResult.item1.isDefault) {
                              for (var item in _profiles.items) {
                                item.isDefault = false;
                              }
                            }
                            _profiles.items.insert(0, serviceResult.item1);
                          });
                        } else {
                          _key.currentState.showSnackBar(SnackBar(
                            content: Text(
                                'خطا در ایجاد نمایه: ' + serviceResult.item2),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                      break;
                  }
                },
                child: Icon(Icons.add),
                tooltip: _activeSection == GActiveFormSection.Profiles
                    ? 'ایجاد نمایهٔ جدید'
                    : 'ارسال خوانش‌های جدید',
              ),
            )));
  }
}
