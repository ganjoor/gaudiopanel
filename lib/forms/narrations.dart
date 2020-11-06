import 'package:after_layout/after_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaudiopanel/forms/login.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/narration/poem-narration-viewmodel.dart';
import 'package:gaudiopanel/models/narration/uploaded-item-viewmodel.dart';
import 'package:gaudiopanel/models/narration/user-narration-profile-viewmodel.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:gaudiopanel/services/upload-narration-service.dart';
import 'package:gaudiopanel/services/narration-service.dart';
import 'package:gaudiopanel/widgets/audio-player-widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_overlay/loading_overlay.dart';

enum NarrationsActiveFormSection { Narrations, Uploads, Profiles }

class NarrationsWidget extends StatefulWidget {
  @override
  NarrationWidgetState createState() => NarrationWidgetState();
}

class NarrationWidgetState extends State<NarrationsWidget>
    with AfterLayoutMixin<NarrationsWidget> {
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
  List<UserNarrationProfileViewModel> _profiles = [];
  AudioPlayer _player;

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
        _profiles = profiles.item1.sublist(0, 5);
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

  Icon getNarrationIcon(PoemNarrationViewModel narration) {
    switch (narration.reviewStatus) {
      case AudioReviewStatus.draft:
        return Icon(Icons.edit);
      case AudioReviewStatus.pending:
        return Icon(Icons.history, color: Colors.orange);
      case AudioReviewStatus.approved:
        return Icon(
          Icons.verified,
          color: Colors.green,
        );
      case AudioReviewStatus.rejected:
        return Icon(Icons.clear, color: Colors.red);
      default:
        return Icon(Icons.circle);
    }
  }

  Icon getUploadIcon(UploadedItemViewModel upload) {
    return upload.processResult
        ? upload.processProgress == 100
            ? Icon(Icons.check, color: Colors.green)
            : Icon(Icons.query_builder, color: Colors.orange)
        : upload.processResultMsg.isNotEmpty
            ? Icon(Icons.error, color: Colors.red)
            : Icon(Icons.query_builder, color: Colors.orange);
  }

  String getVerse(PoemNarrationViewModel narration, Duration position) {
    if (position == null || narration == null || narration.verses == null) {
      return '';
    }
    var verse = narration.verses
        .where((element) =>
            element.audioStartMilliseconds < position.inMilliseconds)
        .last;
    if (verse == null) {
      return '';
    }
    return verse.verseText;
  }

  Widget get items {
    switch (_activeSection) {
      case NarrationsActiveFormSection.Narrations:
        return ListView(children: [
          Padding(
              padding: EdgeInsets.all(10.0),
              child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _narrations.items[index].isExpanded =
                          !_narrations.items[index].isExpanded;
                    });
                  },
                  children: _narrations.items
                      .map((e) => ExpansionPanel(
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return ListTile(
                                leading: getNarrationIcon(e),
                                title: Text(e.poemFullTitle),
                                trailing: IconButton(
                                  icon: e.isMarked
                                      ? Icon(Icons.check_box)
                                      : Icon(Icons.check_box_outline_blank),
                                  onPressed: () {
                                    setState(() {
                                      e.isMarked = !e.isMarked;
                                    });
                                  },
                                ),
                                subtitle: Text(e.audioArtist));
                          },
                          isExpanded: e.isExpanded,
                          body: FocusTraversalGroup(
                              child: Form(
                                  autovalidateMode: AutovalidateMode.always,
                                  onChanged: () {
                                    setState(() {
                                      e.modified = true;
                                    });
                                  },
                                  child: Wrap(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        initialValue: e.audioTitle,
                                        style: TextStyle(
                                            color: e.modified
                                                ? Theme.of(context).errorColor
                                                : Theme.of(context)
                                                    .primaryColor),
                                        decoration: InputDecoration(
                                          labelText: 'عنوان',
                                          hintText: 'عنوان',
                                        ),
                                        onSaved: (String value) {
                                          setState(() {
                                            e.audioTitle = value;
                                          });
                                        },
                                      ),
                                    ),
                                    SafeArea(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ControlButtons(_player, e),
                                          StreamBuilder<Duration>(
                                            stream: _player.durationStream,
                                            builder: (context, snapshot) {
                                              final duration = snapshot.data ??
                                                  Duration.zero;
                                              return StreamBuilder<Duration>(
                                                stream: _player.positionStream,
                                                builder: (context, snapshot) {
                                                  var position =
                                                      snapshot.data ??
                                                          Duration.zero;
                                                  if (position > duration) {
                                                    position = duration;
                                                  }
                                                  return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SeekBar(
                                                          duration: duration,
                                                          position: position,
                                                          onChangeEnd:
                                                              (newPosition) {
                                                            _player.seek(
                                                                newPosition);
                                                          },
                                                        ),
                                                        Text(getVerse(
                                                            e, position))
                                                      ]);
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ])))))
                      .toList()))
        ]);
      case NarrationsActiveFormSection.Profiles:
        return ListView(children: [
          Padding(
              padding: EdgeInsets.all(10.0),
              child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _profiles[index].isExpanded =
                          !_profiles[index].isExpanded;
                    });
                  },
                  children: _profiles
                      .map((e) => ExpansionPanel(
                          headerBuilder:
                              (BuildContext context, bool isExpanded) {
                            return ListTile(
                                leading: Icon(
                                  Icons.people,
                                  color: e.isDefault
                                      ? Colors.red
                                      : Theme.of(context).disabledColor,
                                ),
                                title: Text(e.name),
                                trailing: IconButton(
                                  icon: e.modified
                                      ? Icon(Icons.save,
                                          color: Theme.of(context).primaryColor)
                                      : e.isMarked
                                          ? Icon(Icons.check_box)
                                          : Icon(Icons.check_box_outline_blank),
                                  onPressed: () {
                                    setState(() {
                                      e.isMarked = !e.isMarked;
                                    });
                                  },
                                ),
                                subtitle: Text(e.artistName));
                          },
                          isExpanded: e.isExpanded,
                          body: FocusTraversalGroup(
                              child: Form(
                                  autovalidateMode: AutovalidateMode.always,
                                  onChanged: () {
                                    setState(() {
                                      e.modified = true;
                                    });
                                  },
                                  child: Wrap(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        initialValue: e.name,
                                        decoration: InputDecoration(
                                          labelText: 'نام نمایه',
                                          hintText: 'نامه نمایه',
                                        ),
                                        onSaved: (String value) {
                                          setState(() {
                                            e.name = value;
                                          });
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        initialValue: e.artistName,
                                        decoration: InputDecoration(
                                          labelText: 'نام خوانشگر',
                                          hintText: 'نام خوانشگر',
                                        ),
                                        onSaved: (String value) {
                                          setState(() {
                                            e.artistName = value;
                                          });
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: TextFormField(
                                            initialValue: e.artistUrl,
                                            decoration: InputDecoration(
                                              labelText: 'نشانی وب',
                                              hintText: 'نشانی وب',
                                            ),
                                            onSaved: (String value) {
                                              setState(() {
                                                e.artistUrl = value;
                                              });
                                            },
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        initialValue: e.audioSrc,
                                        decoration: InputDecoration(
                                          labelText: 'نام منبع',
                                          hintText: 'نام منبع',
                                        ),
                                        onSaved: (String value) {
                                          setState(() {
                                            e.audioSrc = value;
                                          });
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: TextFormField(
                                            initialValue: e.audioSrcUrl,
                                            decoration: InputDecoration(
                                              labelText: 'نشانی وب منبع',
                                              hintText: 'نشانی وب منبع',
                                            ),
                                            onSaved: (String value) {
                                              setState(() {
                                                e.audioSrcUrl = value;
                                              });
                                            },
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: TextFormField(
                                            initialValue:
                                                e.fileSuffixWithoutDash,
                                            decoration: InputDecoration(
                                              labelText: 'پسوند یکتاساز فایل',
                                              hintText: 'پسوند یکتاساز فایل',
                                            ),
                                            onSaved: (String value) {
                                              setState(() {
                                                e.fileSuffixWithoutDash = value;
                                              });
                                            },
                                          )),
                                    ),
                                  ])))))
                      .toList()))
        ]);
      case NarrationsActiveFormSection.Uploads:
      default:
        return ListView.builder(
            itemCount: _uploads.items.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  leading: getUploadIcon(_uploads.items[index]),
                  title: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(_uploads.items[index].fileName)),
                  subtitle: Text(_uploads.items[index].processResultMsg));
            });
    }
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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
                          if (_profiles.length == 0) {
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
