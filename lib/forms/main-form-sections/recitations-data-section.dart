import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaudiopanel/callbacks/g-ui-callbacks.dart';
import 'package:gaudiopanel/forms/narration-edit.dart';
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
  _RecitationsState createState() => _RecitationsState(this.narrations,
      this.loadingStateChanged, this.snackbarNeeded, this.status);
}

class _RecitationsState extends State<RecitationsDataSection> {
  _RecitationsState(this.narrations, this.loadingStateChanged,
      this.snackbarNeeded, this.status);
  AudioPlayer _player;

  final PaginatedItemsResponseModel<RecitationViewModel> narrations;
  final LoadingStateChanged loadingStateChanged;
  final SnackbarNeeded snackbarNeeded;
  final int status;

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
        NarrationEdit _narrationEdit = NarrationEdit(narration: narrationCopy);
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
    return ListView.builder(
        itemCount: narrations.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  final result = await _edit(narrations.items[index]);
                  if (result != null) {
                    bool approve = result.reviewStatus == 2 &&
                        ((narrations.items[index].reviewStatus == 0) ||
                            (narrations.items[index].reviewStatus == 1));
                    if (approve) {
                      result.reviewStatus =
                          1; //updateNarration does not support approve/reject operation directy
                    }
                    if (result.isModified) {
                      if (this.loadingStateChanged != null) {
                        this.loadingStateChanged(true);
                      }
                      var serviceResult = await RecitationService()
                          .updateNarration(result, false);
                      if (this.loadingStateChanged != null) {
                        this.loadingStateChanged(false);
                      }
                      if (serviceResult.item1 != null &&
                          serviceResult.item2 == '') {
                        setState(() {
                          if (status == -1) {
                            narrations.items[index] = serviceResult.item1;
                          } else if (status == 0 || status == 1) {
                            if (serviceResult.item1.reviewStatus == status) {
                              narrations.items[index] = serviceResult.item1;
                            } else {
                              narrations.items.removeAt(index);
                            }
                          }
                        });
                      } else {
                        if (this.snackbarNeeded != null) {
                          this.snackbarNeeded(
                              'خطا در ذخیرهٔ خوانش: ' + serviceResult.item2);
                        }
                      }
                    }
                    if (approve) {
                      if (this.loadingStateChanged != null) {
                        this.loadingStateChanged(true);
                      }
                      var serviceResult = await RecitationService()
                          .moderateNarration(result.id,
                              RecitationModerationResult.Approve, '', false);
                      if (this.loadingStateChanged != null) {
                        this.loadingStateChanged(false);
                      }
                      if (serviceResult.item1 != null &&
                          serviceResult.item2 == '') {
                        setState(() {
                          if (status == -1) {
                            narrations.items[index] = serviceResult.item1;
                          } else if (status == 0 || status == 1) {
                            if (serviceResult.item1.reviewStatus == status) {
                              narrations.items[index] = serviceResult.item1;
                            } else {
                              narrations.items.removeAt(index);
                            }
                          }
                        });
                      } else {
                        if (this.snackbarNeeded != null) {
                          this.snackbarNeeded(
                              'خطا در تأیید خوانش: ' + serviceResult.item2);
                        }
                      }
                    }
                  }
                },
              ),
              title: Text(narrations.items[index].audioTitle),
              subtitle: Column(children: [
                Text(narrations.items[index].poemFullTitle),
                Text(narrations.items[index].audioArtist),
                getNarrationIcon(narrations.items[index])
              ]),
              trailing: IconButton(
                icon: narrations.items[index].isMarked
                    ? Icon(Icons.check_box)
                    : Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  setState(() {
                    narrations.items[index].isMarked =
                        !narrations.items[index].isMarked;
                  });
                },
              ));
        });
  }
}
