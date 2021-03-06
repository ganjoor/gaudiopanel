import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaudiopanel/callbacks/g-ui-callbacks.dart';
import 'package:gaudiopanel/models/recitation/recitation-viewmodel.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:gaudiopanel/widgets/audio-player-widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

class NarrationEdit extends StatefulWidget {
  final RecitationViewModel narration;
  final LoadingStateChanged loadingStateChanged;
  final SnackbarNeeded snackbarNeeded;

  const NarrationEdit(
      {Key key, this.narration, this.loadingStateChanged, this.snackbarNeeded})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _NarrationEditState();
}

class _NarrationEditState extends State<NarrationEdit>
    with AfterLayoutMixin<NarrationEdit> {
  AudioPlayer _player;
  bool _canPublish = false;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _artistNameController = TextEditingController();
  TextEditingController _artistUrlController = TextEditingController();
  TextEditingController _audioSrcController = TextEditingController();
  TextEditingController _audioSrcUrlController = TextEditingController();

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
    _titleController.dispose();
    _artistNameController.dispose();
    _artistUrlController.dispose();
    _audioSrcController.dispose();
    _audioSrcUrlController.dispose();
    super.dispose();
  }

  String getVerse(RecitationViewModel narration, Duration position) {
    if (position == null || narration == null || narration.verses == null) {
      return '';
    }
    var verse = narration.verses.lastWhere(
        (element) => element.audioStartMilliseconds <= position.inMilliseconds);
    if (verse == null) {
      return '';
    }
    return verse.verseText;
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    if (await AuthService().hasPermission('recitation', 'publish')) {
      setState(() {
        _canPublish = true;
      });
    }
  }

  void _setModifiedFlag() {
    if (widget.narration.audioTitle != _titleController.text ||
        widget.narration.audioArtist != _artistNameController.text ||
        widget.narration.audioArtistUrl != _artistUrlController.text ||
        widget.narration.audioSrc != _audioSrcController.text ||
        widget.narration.audioSrcUrl != _audioSrcUrlController.text) {
      widget.narration.isModified = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = widget.narration.audioTitle;
    _artistNameController.text = widget.narration.audioArtist;
    _artistUrlController.text = widget.narration.audioArtistUrl;
    _audioSrcController.text = widget.narration.audioSrc;
    _audioSrcUrlController.text = widget.narration.audioSrcUrl;
    return FocusTraversalGroup(
        child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                        labelText: 'عنوان',
                        hintText: 'عنوان',
                        prefixIcon: IconButton(
                          icon: Icon(Icons.open_in_browser),
                          onPressed: () async {
                            var url = 'https://ganjoor.net' +
                                widget.narration.poemFullUrl;
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'خطا در نمایش نشانی $url';
                            }
                          },
                        ))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _artistNameController,
                    decoration: InputDecoration(
                      labelText: 'نام خوانشگر',
                      hintText: 'نام خوانشگر را با حروف فارسی وارد کنید',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                        controller: _artistUrlController,
                        decoration: InputDecoration(
                            labelText: 'نشانی وب',
                            hintText: 'نشانی وب',
                            prefixIcon: IconButton(
                              icon: Icon(Icons.open_in_browser),
                              onPressed: () async {
                                var url = _artistUrlController.text;
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'خطا در نمایش نشانی $url';
                                }
                              },
                            )))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _audioSrcController,
                    decoration: InputDecoration(
                      labelText: 'نام منبع',
                      hintText: 'نام منبع',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                        controller: _audioSrcUrlController,
                        decoration: InputDecoration(
                            labelText: 'نشانی وب منبع',
                            hintText: 'نشانی وب منبع',
                            prefixIcon: IconButton(
                              icon: Icon(Icons.open_in_browser),
                              onPressed: () async {
                                var url = _audioSrcUrlController.text;
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'خطا در نمایش نشانی $url';
                                }
                              },
                            )))),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ControlButtons(_player, widget.narration,
                        widget.loadingStateChanged, widget.snackbarNeeded),
                    StreamBuilder<Duration>(
                      stream: _player.durationStream,
                      builder: (context, snapshot) {
                        final duration = snapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration>(
                          stream: _player.positionStream,
                          builder: (context, snapshot) {
                            var position = snapshot.data ?? Duration.zero;
                            if (position > duration) {
                              position = duration;
                            }
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SeekBar(
                                    duration: duration,
                                    position: position,
                                    onChangeEnd: (newPosition) {
                                      _player.seek(newPosition);
                                    },
                                  ),
                                  Text(getVerse(widget.narration, position))
                                ]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                          child: ElevatedButton(
                            child: Text('رد خوانش'),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red)),
                            onPressed: () {
                              widget.narration.reviewStatus =
                                  AudioReviewStatus.rejected; //Rejected
                              Navigator.of(context).pop(widget.narration);
                            },
                          ),
                          visible: _canPublish &&
                              ((widget.narration.reviewStatus ==
                                      AudioReviewStatus.draft /* Draft */) ||
                                  (widget.narration.reviewStatus ==
                                      AudioReviewStatus
                                          .pending /* Pending */))),
                      Visibility(
                          child: ElevatedButton(
                            child: Text('ذخیره و درخواست بررسی'),
                            onPressed: () {
                              widget.narration.audioTitle =
                                  _titleController.text;
                              widget.narration.audioArtist =
                                  _artistNameController.text;
                              widget.narration.audioArtistUrl =
                                  _artistUrlController.text;
                              widget.narration.audioSrc =
                                  _audioSrcController.text;
                              widget.narration.audioSrcUrl =
                                  _audioSrcUrlController.text;
                              widget.narration.reviewStatus =
                                  AudioReviewStatus.pending; //Pending
                              widget.narration.isModified = true;
                              Navigator.of(context).pop(widget.narration);
                            },
                          ),
                          visible: !_canPublish &&
                              widget.narration.reviewStatus ==
                                  AudioReviewStatus.draft /* Draft */),
                      Visibility(
                          child: ElevatedButton(
                            child: Text('ذخیره و انتشار'),
                            onPressed: () {
                              _setModifiedFlag();
                              widget.narration.audioTitle =
                                  _titleController.text;
                              widget.narration.audioArtist =
                                  _artistNameController.text;
                              widget.narration.audioArtistUrl =
                                  _artistUrlController.text;
                              widget.narration.audioSrc =
                                  _audioSrcController.text;
                              widget.narration.audioSrcUrl =
                                  _audioSrcUrlController.text;
                              widget.narration.reviewStatus =
                                  AudioReviewStatus.approved; //Approved
                              Navigator.of(context).pop(widget.narration);
                            },
                          ),
                          visible: _canPublish &&
                              ((widget.narration.reviewStatus ==
                                      AudioReviewStatus.draft /* Draft */) ||
                                  (widget.narration.reviewStatus ==
                                      AudioReviewStatus
                                          .pending /* Pending */))),
                      ElevatedButton(
                        child: Text('ذخیره'),
                        onPressed: () {
                          _setModifiedFlag();
                          widget.narration.audioTitle = _titleController.text;
                          widget.narration.audioArtist =
                              _artistNameController.text;
                          widget.narration.audioArtistUrl =
                              _artistUrlController.text;
                          widget.narration.audioSrc = _audioSrcController.text;
                          widget.narration.audioSrcUrl =
                              _audioSrcUrlController.text;
                          Navigator.of(context).pop(widget.narration);
                        },
                      ),
                      TextButton(
                        child: Text('انصراف'),
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                      )
                    ],
                  )),
            ])));
  }
}
