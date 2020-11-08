import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaudiopanel/models/narration/poem-narration-viewmodel.dart';
import 'package:gaudiopanel/widgets/audio-player-widgets.dart';
import 'package:just_audio/just_audio.dart';

class NarrationEdit extends StatefulWidget {
  final PoemNarrationViewModel narration;

  const NarrationEdit({Key key, this.narration}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NarrationEditState(this.narration);
}

class _NarrationEditState extends State<NarrationEdit> {
  final PoemNarrationViewModel narration;
  AudioPlayer _player;

  _NarrationEditState(this.narration);

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

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
        child: Form(
            autovalidateMode: AutovalidateMode.always,
            onChanged: () {
              setState(() {
                narration.modified = true;
              });
            },
            child: Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: narration.audioTitle,
                  style: TextStyle(
                      color: narration.modified
                          ? Theme.of(context).errorColor
                          : Theme.of(context).primaryColor),
                  decoration: InputDecoration(
                    labelText: 'عنوان',
                    hintText: 'عنوان',
                  ),
                  onSaved: (String value) {
                    setState(() {
                      narration.audioTitle = value;
                    });
                  },
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ControlButtons(_player, narration),
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
                                  Text(getVerse(narration, position))
                                ]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ])));
  }
}
