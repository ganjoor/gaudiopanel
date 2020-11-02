import 'package:after_layout/after_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/login.dart';
import 'package:gaudiopanel/models/narration/poem-narrations-response-model.dart';
import 'package:gaudiopanel/models/narration/uploaded-narrations-response-model.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:gaudiopanel/services/upload-narration-service.dart';
import 'package:gaudiopanel/services/narration-service.dart';
import 'package:loading_overlay/loading_overlay.dart';

enum NarrationsActiveFormSection { Narrations, Uploads }

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
      NarrationsActiveFormSection.Narrations;
  int _pageNumber = 1;
  int _pageSize = 20;
  PoemNarrationsResponseModel _narrations;
  UploadedNarrationsResponseModel _uploads;

  String get title {
    switch (_activeSection) {
      case NarrationsActiveFormSection.Uploads:
        return 'پیشخان خوانشگران گنجور » بارگذاریها';
      default:
        return 'پیشخان خوانشگران گنجور » خوانشها';
    }
  }

  Future<void> loadData() async {
    switch (_activeSection) {
      case NarrationsActiveFormSection.Narrations:
        {
          setState(() {
            _isLoading = true;
          });
          var narrations = await NarrationService()
              .getNarrations(_pageNumber, _pageSize, false);
          setState(() {
            _narrations = narrations;
            _isLoading = false;
          });
          if (_narrations.error.isNotEmpty) {
            _key.currentState.showSnackBar(SnackBar(
              content: Text("خطا در دریافت خوانشها: " + _narrations.error),
              backgroundColor: Colors.red,
            ));
          }
        }
        break;
      case NarrationsActiveFormSection.Uploads:
        {
          setState(() {
            _isLoading = true;
          });
          var uploads = await NarrationService()
              .getUploads(_pageNumber, _pageSize, false);
          setState(() {
            _uploads = uploads;
            _isLoading = false;
          });
          if (_uploads.error.isNotEmpty) {
            _key.currentState.showSnackBar(SnackBar(
              content: Text("خطا در دریافت بارگذاریها: " + _uploads.error),
              backgroundColor: Colors.red,
            ));
          }
        }
        break;
    }
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await loadData();
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
                      title: Text('خوانشها'),
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
                          await loadData();
                          Navigator.of(context).pop(); //close drawer
                        }
                      },
                    ),
                    ListTile(
                      title: Text('بارگذاریها'),
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
                          await loadData();
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
                        child: ListView.builder(
                            itemCount: _activeSection ==
                                    NarrationsActiveFormSection.Narrations
                                ? (_narrations == null
                                    ? 0
                                    : _narrations.narrations == null
                                        ? 0
                                        : _narrations.narrations.length)
                                : (_uploads == null
                                    ? 0
                                    : _uploads.uploads == null
                                        ? 0
                                        : _uploads.uploads.length),
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                  title: Text(_activeSection ==
                                          NarrationsActiveFormSection.Narrations
                                      ? _narrations
                                          .narrations[index].poemFullTitle
                                      : _uploads.uploads[index].fileName),
                                  subtitle: Text(_activeSection ==
                                          NarrationsActiveFormSection.Narrations
                                      ? _narrations
                                          .narrations[index].audioArtist
                                      : _uploads
                                          .uploads[index].processResultMsg));
                            }),
                      )),
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
                        content: Text("خطا در ارسال خوانشهای جدید: " + err),
                        backgroundColor: Colors.red,
                      ));
                    }

                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: Icon(Icons.add),
                tooltip: 'خوانشهای جدید',
              ),
            )));
  }
}
