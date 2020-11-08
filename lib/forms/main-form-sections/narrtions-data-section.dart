import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaudiopanel/forms/narration-edit.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/narration/poem-narration-viewmodel.dart';
import 'package:gaudiopanel/widgets/audio-player-widgets.dart';
import 'package:just_audio/just_audio.dart';

class NarrationsDataSection extends StatefulWidget {
  const NarrationsDataSection({Key key, this.narrations}) : super(key: key);

  final PaginatedItemsResponseModel<PoemNarrationViewModel> narrations;

  @override
  _NarrationsState createState() => _NarrationsState(this.narrations);
}

class _NarrationsState extends State<NarrationsDataSection> {
  _NarrationsState(this.narrations);
  AudioPlayer _player;

  final PaginatedItemsResponseModel<PoemNarrationViewModel> narrations;

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

  Future<PoemNarrationViewModel> _edit(PoemNarrationViewModel narration) async {
    return showDialog<PoemNarrationViewModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        NarrationEdit _narrationEdit = NarrationEdit(narration: narration);
        return AlertDialog(
          title: Text('ویرایش خوانش'),
          content: SingleChildScrollView(
            child: _narrationEdit,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Padding(
          padding: EdgeInsets.all(10.0),
          child: ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  narrations.items[index].isExpanded =
                      !narrations.items[index].isExpanded;
                });
              },
              children: narrations.items
                  .map((e) => ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                            leading: IconButton(
                                icon: getNarrationIcon(e),
                                onPressed: () async {
                                  await _edit(e);
                                }),
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
                                            : Theme.of(context).primaryColor),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ControlButtons(_player, e),
                                      StreamBuilder<Duration>(
                                        stream: _player.durationStream,
                                        builder: (context, snapshot) {
                                          final duration =
                                              snapshot.data ?? Duration.zero;
                                          return StreamBuilder<Duration>(
                                            stream: _player.positionStream,
                                            builder: (context, snapshot) {
                                              var position = snapshot.data ??
                                                  Duration.zero;
                                              if (position > duration) {
                                                position = duration;
                                              }
                                              return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SeekBar(
                                                      duration: duration,
                                                      position: position,
                                                      onChangeEnd:
                                                          (newPosition) {
                                                        _player
                                                            .seek(newPosition);
                                                      },
                                                    ),
                                                    Text(getVerse(e, position))
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
  }
}
