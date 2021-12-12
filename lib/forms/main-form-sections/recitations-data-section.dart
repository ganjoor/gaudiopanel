import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaudiopanel/callbacks/g-ui-callbacks.dart';
import 'package:gaudiopanel/forms/narration-edit.dart';
import 'package:gaudiopanel/forms/reject-recitation.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/recitation/recitation-viewmodel.dart';
import 'package:gaudiopanel/services/recitation-service.dart';
import 'package:just_audio/just_audio.dart';

class RecitationsDataSection extends StatefulWidget {
  const RecitationsDataSection(
      {Key key,
      this.narrations,
      this.loadingStateChanged,
      this.snackbarNeeded,
      this.status})
      : super(key: key);

  final PaginatedItemsResponseModel<RecitationViewModel> narrations;
  final LoadingStateChanged loadingStateChanged;
  final SnackbarNeeded snackbarNeeded;
  final int status;

  @override
  _RecitationsState createState() => _RecitationsState();
}

class _RecitationsState extends State<RecitationsDataSection> {
  AudioPlayer _player;

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

  Icon getNarrationIcon(RecitationViewModel narration) {
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

  Future<RecitationViewModel> _edit(RecitationViewModel narration) async {
    return showDialog<RecitationViewModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        RecitationViewModel narrationCopy =
            RecitationViewModel.fromJson(narration.toJson());
        narrationCopy.isModified = false;
        NarrationEdit _narrationEdit = NarrationEdit(
          narration: narrationCopy,
          loadingStateChanged: widget.loadingStateChanged,
          snackbarNeeded: widget.snackbarNeeded,
        );
        return AlertDialog(
          title: Text('ویرایش خوانش'),
          content: SingleChildScrollView(
            child: _narrationEdit,
          ),
        );
      },
    );
  }

  Future<String> _reject(RecitationViewModel recitation) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        RejectRecitation _narrationReject =
            RejectRecitation(recitation: recitation);
        return AlertDialog(
          title: Text('رد خوانش'),
          content: SingleChildScrollView(
            child: _narrationReject,
          ),
        );
      },
    );
  }

  Future _doEdit(int index) async {
    final result = await _edit(widget.narrations.items[index]);
    if (result != null) {
      bool reject = result.reviewStatus == AudioReviewStatus.rejected &&
          ((widget.narrations.items[index].reviewStatus == 0) ||
              (widget.narrations.items[index].reviewStatus == 1));

      if (reject) {
        var rejectResult = await _reject(widget.narrations.items[index]);
        if (rejectResult == null) {
          return;
        }
        if (rejectResult.isNotEmpty) {
          if (widget.loadingStateChanged != null) {
            widget.loadingStateChanged(true);
          }
          var serviceResult = await RecitationService().moderateRecitation(
              result.id,
              RecitationModerationResult.Reject,
              rejectResult,
              false);
          if (widget.loadingStateChanged != null) {
            widget.loadingStateChanged(false);
          }
          if (serviceResult.item1 != null && serviceResult.item2 == '') {
            setState(() {
              if (widget.status == AudioReviewStatus.all) {
                widget.narrations.items[index] = serviceResult.item1;
              } else if (widget.status == AudioReviewStatus.draft ||
                  widget.status == AudioReviewStatus.pending) {
                if (serviceResult.item1.reviewStatus == widget.status) {
                  widget.narrations.items[index] = serviceResult.item1;
                } else {
                  widget.narrations.items.removeAt(index);
                }
              }
            });
          } else {
            if (widget.snackbarNeeded != null) {
              widget.snackbarNeeded('خطا در رد خوانش: ' + serviceResult.item2);
            }
          }
        }
      } else {
        bool approve = result.reviewStatus == AudioReviewStatus.approved &&
            ((widget.narrations.items[index].reviewStatus ==
                    AudioReviewStatus.draft) ||
                (widget.narrations.items[index].reviewStatus ==
                    AudioReviewStatus.pending));
        if (approve) {
          result.reviewStatus =
              1; //updateNarration does not support approve/reject operation directy
        }
        if (result.isModified) {
          if (widget.loadingStateChanged != null) {
            widget.loadingStateChanged(true);
          }
          var serviceResult =
              await RecitationService().updateRecitation(result, false);
          if (widget.loadingStateChanged != null) {
            widget.loadingStateChanged(false);
          }
          if (serviceResult.item1 != null && serviceResult.item2 == '') {
            setState(() {
              if (widget.status == AudioReviewStatus.all) {
                widget.narrations.items[index] = serviceResult.item1;
              } else if (widget.status == AudioReviewStatus.draft ||
                  widget.status == AudioReviewStatus.pending) {
                if (serviceResult.item1.reviewStatus == widget.status) {
                  widget.narrations.items[index] = serviceResult.item1;
                } else {
                  widget.narrations.items.removeAt(index);
                }
              }
            });
          } else {
            if (widget.snackbarNeeded != null) {
              widget.snackbarNeeded(
                  'خطا در ذخیرهٔ خوانش: ' + serviceResult.item2);
            }
          }
        }
        if (approve) {
          if (widget.loadingStateChanged != null) {
            widget.loadingStateChanged(true);
          }
          var serviceResult = await RecitationService().moderateRecitation(
              result.id, RecitationModerationResult.Approve, '', false);
          if (widget.loadingStateChanged != null) {
            widget.loadingStateChanged(false);
          }
          if (serviceResult.item1 != null && serviceResult.item2 == '') {
            setState(() {
              if (widget.status == AudioReviewStatus.all) {
                widget.narrations.items[index] = serviceResult.item1;
              } else if (widget.status == AudioReviewStatus.draft ||
                  widget.status == AudioReviewStatus.pending) {
                if (serviceResult.item1.reviewStatus == widget.status) {
                  widget.narrations.items[index] = serviceResult.item1;
                } else {
                  widget.narrations.items.removeAt(index);
                }
              }
            });
          } else {
            if (widget.snackbarNeeded != null) {
              widget
                  .snackbarNeeded('خطا در تأیید خوانش: ' + serviceResult.item2);
            }
          }
        }
      }
    }
  }

  String _getReviewMsg(String msg) {
    if (msg == null) return '';
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.narrations.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  await _doEdit(index);
                },
              ),
              title: Text(widget.narrations.items[index].audioTitle),
              subtitle: Column(children: [
                Text(widget.narrations.items[index].poemFullTitle),
                Text(widget.narrations.items[index].audioArtist),
                IconButton(
                    icon: getNarrationIcon(widget.narrations.items[index]),
                    onPressed: () async {
                      await _doEdit(index);
                    }),
                Visibility(
                    child: Text(_getReviewMsg(
                        widget.narrations.items[index].reviewMsg)),
                    visible: widget.narrations.items[index].reviewStatus ==
                            AudioReviewStatus.rejected ||
                        widget.narrations.items[index].reviewStatus ==
                            AudioReviewStatus.reported)
              ]),
              trailing: IconButton(
                icon: widget.narrations.items[index].isMarked
                    ? Icon(Icons.check_box)
                    : Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  setState(() {
                    widget.narrations.items[index].isMarked =
                        !widget.narrations.items[index].isMarked;
                  });
                },
              ));
        });
  }
}
