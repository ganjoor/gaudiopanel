import 'package:after_layout/after_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/login.dart';
import 'package:gaudiopanel/forms/main-form-sections/profiles-data-section.dart';
import 'package:gaudiopanel/forms/profile-edit.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/narration/poem-narration-viewmodel.dart';
import 'package:gaudiopanel/models/narration/uploaded-item-viewmodel.dart';
import 'package:gaudiopanel/models/narration/user-narration-profile-viewmodel.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:gaudiopanel/services/upload-narration-service.dart';
import 'package:gaudiopanel/services/narration-service.dart';
import 'package:gaudiopanel/forms/main-form-sections/narrtions-data-section.dart';
import 'package:gaudiopanel/forms/main-form-sections/uploads-data-section.dart';
import 'package:loading_overlay/loading_overlay.dart';

enum NarrationsActiveFormSection {
  DraftNarrations,
  AllMyNarrations,
  AllUsersPendingNarrations,
  Uploads,
  Profiles
}

class MainForm extends StatefulWidget {
  @override
  NarrationWidgetState createState() => NarrationWidgetState();
}

class NarrationWidgetState extends State<MainForm>
    with AfterLayoutMixin<MainForm> {
  final GlobalKey<ScaffoldMessengerState> _key =
      GlobalKey<ScaffoldMessengerState>();
  bool _isLoading = false;
  NarrationsActiveFormSection _activeSection =
      NarrationsActiveFormSection.DraftNarrations;
  int _narrationsPageNumber = 1;
  int _uploadsPageNumber = 1;
  int _pageSize = 20;
  PaginatedItemsResponseModel<PoemNarrationViewModel> _narrations =
      PaginatedItemsResponseModel<PoemNarrationViewModel>(items: []);
  PaginatedItemsResponseModel<UploadedItemViewModel> _uploads =
      PaginatedItemsResponseModel<UploadedItemViewModel>(items: []);
  PaginatedItemsResponseModel<UserNarrationProfileViewModel> _profiles =
      PaginatedItemsResponseModel<UserNarrationProfileViewModel>(items: []);
  String get title {
    switch (_activeSection) {
      case NarrationsActiveFormSection.Uploads:
        return 'پیشخان خوانشگران گنجور » بارگذاری‌های من';
      case NarrationsActiveFormSection.Profiles:
        return 'پیشخان خوانشگران گنجور » نمایه‌های من';
      case NarrationsActiveFormSection.DraftNarrations:
        return 'پیشخان خوانشگران گنجور » خوانش‌های پیش‌نویس من';
      case NarrationsActiveFormSection.AllMyNarrations:
        return 'پیشخان خوانشگران گنجور » همهٔ خوانش‌های من';
      case NarrationsActiveFormSection.AllUsersPendingNarrations:
        return 'پیشخان خوانشگران گنجور » خوانش‌های در انتظار تأیید';
    }
    return '';
  }

  Future<void> _loadNarrationsData() async {
    setState(() {
      _isLoading = true;
    });
    var narrations = await NarrationService().getNarrations(
        _narrationsPageNumber,
        _pageSize,
        _activeSection == NarrationsActiveFormSection.AllUsersPendingNarrations,
        _activeSection == NarrationsActiveFormSection.AllMyNarrations
            ? -1
            : _activeSection ==
                    NarrationsActiveFormSection.AllUsersPendingNarrations
                ? 1
                : 0,
        false);
    if (narrations.error.isEmpty) {
      setState(() {
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
    var uploads = await NarrationService()
        .getUploads(_uploadsPageNumber, _pageSize, false);

    if (uploads.error.isEmpty) {
      setState(() {
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
    var profiles = await NarrationService().getProfiles(false);

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
      case NarrationsActiveFormSection.DraftNarrations:
      case NarrationsActiveFormSection.AllMyNarrations:
      case NarrationsActiveFormSection.AllUsersPendingNarrations:
        await _loadNarrationsData();
        break;
      case NarrationsActiveFormSection.Uploads:
        await _loadUploadsData();
        break;
      case NarrationsActiveFormSection.Profiles:
        await _loadProfilesData();
        break;
    }
  }

  @override
  void afterFirstLayout(BuildContext context) async {
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

  Future<UserNarrationProfileViewModel> _newProfile() async {
    return showDialog<UserNarrationProfileViewModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        ProfileEdit _profileEdit = ProfileEdit(
            profile: UserNarrationProfileViewModel(
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
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'xml'],
    );
    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      String err =
          await UploadNarrationService().uploadFiles(result.files, false);

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

  Widget get items {
    switch (_activeSection) {
      case NarrationsActiveFormSection.DraftNarrations:
      case NarrationsActiveFormSection.AllMyNarrations:
      case NarrationsActiveFormSection.AllUsersPendingNarrations:
      case NarrationsActiveFormSection.DraftNarrations:
        return NarrationsDataSection(
          narrations: _narrations,
          loadingStateChanged: _loadingStateChanged,
          snackbarNeeded: _snackbarNeeded,
          status: _activeSection == NarrationsActiveFormSection.DraftNarrations
              ? 0
              : _activeSection ==
                      NarrationsActiveFormSection.AllUsersPendingNarrations
                  ? 1
                  : -1,
        );
      case NarrationsActiveFormSection.Profiles:
        return ProfilesDataSection(
            profiles: _profiles,
            loadingStateChanged: _loadingStateChanged,
            snackbarNeeded: _snackbarNeeded);
      case NarrationsActiveFormSection.Uploads:
      default:
        return UploadsDataSection(uploads: _uploads);
    }
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
                        icon: Icon(Icons.delete),
                        tooltip: 'حذف',
                        onPressed: () async {
                          var markedProfiles = _profiles.items
                              .where((element) => element.isMarked)
                              .toList();
                          if (markedProfiles.isEmpty) {
                            _key.currentState.showSnackBar(SnackBar(
                              content: Text(
                                  'لطفاً نمایه‌های مد نظر را علامتگذاری کنید.'),
                              backgroundColor: Colors.red,
                            ));
                            return;
                          }
                          String confirmation = markedProfiles.length > 1
                              ? 'آیا از حذف ' +
                                  markedProfiles.length.toString() +
                                  ' نمایهٔ علامتگذاری شده اطمینان دارید؟'
                              : 'آیا از حذف نمایهٔ «' +
                                  markedProfiles[0].name +
                                  '» اطمینان دارید؟';
                          if (await _confirm('تأییدیه', confirmation)) {
                            for (var item in markedProfiles) {
                              var delRes = await NarrationService()
                                  .deleteProfile(item.id, false);
                              if (delRes.item2.isNotEmpty) {
                                _key.currentState.showSnackBar(SnackBar(
                                  content: Text('خطا در حذف نمایهٔ ' +
                                      item.name +
                                      '، اطلاعات بیستر ' +
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
                        },
                      ),
                      visible: _activeSection ==
                          NarrationsActiveFormSection.Profiles)
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
                      selected: _activeSection ==
                          NarrationsActiveFormSection.DraftNarrations,
                      onTap: () async {
                        if (_activeSection !=
                            NarrationsActiveFormSection.DraftNarrations) {
                          setState(() {
                            _narrations.items.clear();
                            _narrationsPageNumber = 1;
                            _activeSection =
                                NarrationsActiveFormSection.DraftNarrations;
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
                      selected:
                          _activeSection == NarrationsActiveFormSection.Uploads,
                      onTap: () async {
                        if (_activeSection !=
                            NarrationsActiveFormSection.Uploads) {
                          setState(() {
                            _activeSection =
                                NarrationsActiveFormSection.Uploads;
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
                      selected: _activeSection ==
                          NarrationsActiveFormSection.AllMyNarrations,
                      onTap: () async {
                        if (_activeSection !=
                            NarrationsActiveFormSection.AllMyNarrations) {
                          setState(() {
                            _narrationsPageNumber = 1;
                            _narrations.items.clear();
                            _activeSection =
                                NarrationsActiveFormSection.AllMyNarrations;
                          });
                          await _loadData();

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: Text('خوانش‌های در انتظار تأیید'),
                      leading: Icon(Icons.music_note,
                          color: Theme.of(context).primaryColor),
                      selected: _activeSection ==
                          NarrationsActiveFormSection.AllUsersPendingNarrations,
                      onTap: () async {
                        if (_activeSection !=
                            NarrationsActiveFormSection
                                .AllUsersPendingNarrations) {
                          setState(() {
                            _narrationsPageNumber = 1;
                            _narrations.items.clear();
                            _activeSection = NarrationsActiveFormSection
                                .AllUsersPendingNarrations;
                          });
                          await _loadData();

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: Text('نمایه‌های من'),
                      leading: Icon(Icons.people,
                          color: Theme.of(context).primaryColor),
                      selected: _activeSection ==
                          NarrationsActiveFormSection.Profiles,
                      onTap: () async {
                        if (_activeSection !=
                            NarrationsActiveFormSection.Profiles) {
                          setState(() {
                            _activeSection =
                                NarrationsActiveFormSection.Profiles;
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
              body: Builder(
                  builder: (context) => Center(
                      child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (!_isLoading &&
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                              setState(() {
                                switch (_activeSection) {
                                  case NarrationsActiveFormSection
                                      .DraftNarrations:
                                  case NarrationsActiveFormSection
                                      .AllMyNarrations:
                                  case NarrationsActiveFormSection
                                      .AllUsersPendingNarrations:
                                    _narrationsPageNumber =
                                        _narrations.paginationMetadata == null
                                            ? 1
                                            : _narrations.paginationMetadata
                                                    .currentPage +
                                                1;
                                    break;
                                  case NarrationsActiveFormSection.Uploads:
                                    _uploadsPageNumber =
                                        _uploads.paginationMetadata == null
                                            ? 1
                                            : _uploads.paginationMetadata
                                                    .currentPage +
                                                1;
                                    break;
                                  case NarrationsActiveFormSection.Profiles:
                                    //do nothing
                                    break;
                                }
                              });
                              _loadData();
                            }
                            return true;
                          },
                          child: items))),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  switch (_activeSection) {
                    case NarrationsActiveFormSection.DraftNarrations:
                    case NarrationsActiveFormSection.AllMyNarrations:
                    case NarrationsActiveFormSection.AllUsersPendingNarrations:
                    case NarrationsActiveFormSection.Uploads:
                      await _newNarrations();
                      if (_activeSection ==
                          NarrationsActiveFormSection.Uploads) {
                        await _loadData();
                      }
                      break;
                    case NarrationsActiveFormSection.Profiles:
                      var result = await _newProfile();
                      if (result != null) {
                        setState(() {
                          _isLoading = true;
                        });
                        var serviceResult =
                            await NarrationService().addProfile(result, false);
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
                tooltip: _activeSection == NarrationsActiveFormSection.Profiles
                    ? 'ایجاد نمایهٔ جدید'
                    : 'ارسال خوانش‌های جدید',
              ),
            )));
  }
}
