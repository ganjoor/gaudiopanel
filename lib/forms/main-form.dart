import 'package:after_layout/after_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/login.dart';
import 'package:gaudiopanel/forms/main-form-sections/profiles-data-section.dart';
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

enum NarrationsActiveFormSection { Narrations, Uploads, Profiles }

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
      NarrationsActiveFormSection.Uploads;
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
        return 'پیشخان خوانشگران گنجور » بارگذاری‌ها';
      case NarrationsActiveFormSection.Profiles:
        return 'پیشخان خوانشگران گنجور » نمایه‌ها';
      default:
        return 'پیشخان خوانشگران گنجور » خوانش‌ها';
    }
  }

  Future<void> _loadNarrationsData() async {
    setState(() {
      _isLoading = true;
    });
    var narrations = await NarrationService()
        .getNarrations(_narrationsPageNumber, _pageSize, false);
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
        _profiles.items.addAll(profiles.item1.sublist(0, 5));
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
      case NarrationsActiveFormSection.Narrations:
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

  Widget get items {
    switch (_activeSection) {
      case NarrationsActiveFormSection.Narrations:
        return NarrationsDataSection(narrations: _narrations);
      case NarrationsActiveFormSection.Profiles:
        return ProfilesDataSection(profiles: _profiles);
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
                      title: Text('خوانش‌ها'),
                      leading: Icon(Icons.music_note,
                          color: Theme.of(context).primaryColor),
                      selected: _activeSection ==
                          NarrationsActiveFormSection.Narrations,
                      onTap: () async {
                        if (_activeSection !=
                            NarrationsActiveFormSection.Narrations) {
                          setState(() {
                            _activeSection =
                                NarrationsActiveFormSection.Narrations;
                          });
                          if (_narrations.items.length == 0) {
                            await _loadData();
                          }

                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: Text('بارگذاری‌ها'),
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
                      title: Text('نمایه‌ها'),
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
                                  case NarrationsActiveFormSection.Narrations:
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
                  FilePickerResult result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: ['mp3', 'xml'],
                  );
                  if (result != null) {
                    setState(() {
                      _isLoading = true;
                    });

                    String err = await UploadNarrationService()
                        .uploadFiles(result.files, false);

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
                },
                child: Icon(Icons.add),
                tooltip: 'ارسال خوانش‌های جدید',
              ),
            )));
  }
}
