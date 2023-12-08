import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaudiopanel/callbacks/g_ui_callbacks.dart';
import 'package:gaudiopanel/forms/narration_edit.dart';
import 'package:gaudiopanel/forms/reject_recitation.dart';
import 'package:gaudiopanel/models/common/paginated_items_response_model.dart';
import 'package:gaudiopanel/models/recitation/recitation_viewmodel.dart';
import 'package:gaudiopanel/services/recitation_service.dart';
import 'package:just_audio/just_audio.dart';

class RecitationsDataSection extends StatefulWidget {
  const RecitationsDataSection(
      {super.key,
      required this.narrations,
      required this.loadingStateChanged,
      required this.snackbarNeeded,
      required this.status});

  final PaginatedItemsResponseModel<RecitationViewModel> narrations;
  final LoadingStateChanged loadingStateChanged;
  final SnackbarNeeded snackbarNeeded;
  final int status;

  @override
  State<RecitationsDataSection> createState() => _RecitationsState();
}

class _RecitationsState extends State<RecitationsDataSection> {
  AudioPlayer? _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
  }

  @override
  void dispose() {
    _player!.dispose();
    super.dispose();
  }

  Icon getNarrationIcon(RecitationViewModel narration) {
    switch (narration.reviewStatus) {
      case AudioReviewStatus.draft:
        return const Icon(Icons.edit);
      case AudioReviewStatus.pending:
        return const Icon(Icons.history, color: Colors.orange);
      case AudioReviewStatus.approved:
        return const Icon(
          Icons.verified,
          color: Colors.green,
        );
      case AudioReviewStatus.rejected:
        return const Icon(Icons.clear, color: Colors.red);
      default:
        return const Icon(Icons.circle);
    }
  }

  Future<RecitationViewModel?> _edit(RecitationViewModel narration) async {
    return showDialog<RecitationViewModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        RecitationViewModel narrationCopy =
            RecitationViewModel.fromJson(narration.toJson());
        narrationCopy.isModified = false;
        NarrationEdit narrationEdit = NarrationEdit(
          narration: narrationCopy,
          loadingStateChanged: widget.loadingStateChanged,
          snackbarNeeded: widget.snackbarNeeded,
        );
        return AlertDialog(
          title: const Text('ویرایش خوانش'),
          content: SingleChildScrollView(
            child: narrationEdit,
          ),
        );
      },
    );
  }

  Future<String?> _reject(RecitationViewModel recitation) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        RejectRecitation narrationReject =
            RejectRecitation(recitation: recitation);
        return AlertDialog(
          title: const Text('رد خوانش'),
          content: SingleChildScrollView(
            child: narrationReject,
          ),
        );
      },
    );
  }

  Future _doEdit(int index) async {
    final result = await _edit(widget.narrations.items![index]);
    bool reject = result!.reviewStatus == AudioReviewStatus.rejected &&
        ((widget.narrations.items![index].reviewStatus == 0) ||
            (widget.narrations.items![index].reviewStatus == 1));

    if (reject) {
      var rejectResult = await _reject(widget.narrations.items![index]);
      if (rejectResult!.isNotEmpty) {
        widget.loadingStateChanged(true);
        var serviceResult = await RecitationService().moderateRecitation(
            result.id, RecitationModerationResult.reject, rejectResult, false);
        widget.loadingStateChanged(false);
        if (serviceResult.item2 == '') {
          setState(() {
            if (widget.status == AudioReviewStatus.all) {
              widget.narrations.items![index] = serviceResult.item1!;
            } else if (widget.status == AudioReviewStatus.draft ||
                widget.status == AudioReviewStatus.pending) {
              if (serviceResult.item1!.reviewStatus == widget.status) {
                widget.narrations.items![index] = serviceResult.item1!;
              } else {
                widget.narrations.items!.removeAt(index);
              }
            }
          });
        } else {
          widget.snackbarNeeded('خطا در رد خوانش: ${serviceResult.item2}');
        }
      }
    } else {
      bool approve = result.reviewStatus == AudioReviewStatus.approved &&
          ((widget.narrations.items![index].reviewStatus ==
                  AudioReviewStatus.draft) ||
              (widget.narrations.items![index].reviewStatus ==
                  AudioReviewStatus.pending));
      if (approve) {
        result.reviewStatus =
            1; //updateNarration does not support approve/reject operation directy
      }
      if (result.isModified) {
        widget.loadingStateChanged(true);
        var serviceResult =
            await RecitationService().updateRecitation(result, false);
        widget.loadingStateChanged(false);
        if (serviceResult.item2 == '') {
          setState(() {
            if (widget.status == AudioReviewStatus.all) {
              widget.narrations.items![index] = serviceResult.item1!;
            } else if (widget.status == AudioReviewStatus.draft ||
                widget.status == AudioReviewStatus.pending) {
              if (serviceResult.item1!.reviewStatus == widget.status) {
                widget.narrations.items![index] = serviceResult.item1!;
              } else {
                widget.narrations.items!.removeAt(index);
              }
            }
          });
        } else {
          widget.snackbarNeeded('خطا در ذخیرهٔ خوانش: ${serviceResult.item2}');
        }
      }
      if (approve) {
        widget.loadingStateChanged(true);
        var serviceResult = await RecitationService().moderateRecitation(
            result.id, RecitationModerationResult.approve, '', false);
        widget.loadingStateChanged(false);
        if (serviceResult.item2 == '') {
          setState(() {
            if (widget.status == AudioReviewStatus.all) {
              widget.narrations.items![index] = serviceResult.item1!;
            } else if (widget.status == AudioReviewStatus.draft ||
                widget.status == AudioReviewStatus.pending) {
              if (serviceResult.item1!.reviewStatus == widget.status) {
                widget.narrations.items![index] = serviceResult.item1!;
              } else {
                widget.narrations.items!.removeAt(index);
              }
            }
          });
        } else {
          widget.snackbarNeeded('خطا در تأیید خوانش: ${serviceResult.item2}');
        }
      }
    }
  }

  String _getReviewMsg(String msg) {
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.narrations.items!.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await _doEdit(index);
                },
              ),
              title: Text(widget.narrations.items![index].audioTitle),
              subtitle: Column(children: [
                Text(widget.narrations.items![index].poemFullTitle),
                Text(widget.narrations.items![index].audioArtist),
                IconButton(
                    icon: getNarrationIcon(widget.narrations.items![index]),
                    onPressed: () async {
                      await _doEdit(index);
                    }),
                Visibility(
                    visible: widget.narrations.items![index].reviewStatus ==
                            AudioReviewStatus.rejected ||
                        widget.narrations.items![index].reviewStatus ==
                            AudioReviewStatus.reported ||
                        widget.status == AudioReviewStatus.mistakes,
                    child: Text(_getReviewMsg(
                        widget.narrations.items![index].reviewMsg)))
              ]),
              trailing: IconButton(
                icon: widget.narrations.items![index].isMarked
                    ? const Icon(Icons.check_box)
                    : const Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  setState(() {
                    widget.narrations.items![index].isMarked =
                        !widget.narrations.items![index].isMarked;
                  });
                },
              ));
        });
  }
}
