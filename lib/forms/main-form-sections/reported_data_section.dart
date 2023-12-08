import 'package:flutter/material.dart';
import 'package:gaudiopanel/callbacks/g_ui_callbacks.dart';
import 'package:gaudiopanel/models/common/paginated_items_response_model.dart';
import 'package:gaudiopanel/models/recitation/recitation_error_report_viewmodel.dart';
import 'package:gaudiopanel/services/recitation_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportedDataSection extends StatefulWidget {
  final PaginatedItemsResponseModel<RecitationErrorReportViewModel>
      reportedRecitations;
  final LoadingStateChanged loadingStateChanged;
  final SnackbarNeeded snackbarNeeded;

  const ReportedDataSection(
      {Key? key,
      required this.reportedRecitations,
      required this.loadingStateChanged,
      required this.snackbarNeeded})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilesState();
}

class _ProfilesState extends State<ReportedDataSection> {
  Future<void> _showMyDialog(String error) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text('خطا'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(error)],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('تأیید'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> _input(String title, String field, String value) async {
    TextEditingController controller = TextEditingController();
    controller.text = value;

    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: controller,
                  obscureText: false,
                  readOnly: false,
                  keyboardType: TextInputType.multiline,
                  minLines: 4,
                  maxLines: 10,
                  onFieldSubmitted: (String value) => {
                    if (controller.text.trim().isEmpty)
                      {
                        _showMyDialog('$field نمی‌تواند خالی باشد.'),
                      }
                    else
                      {Navigator.of(context).pop(controller.text.trim())}
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('تأیید'),
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  _showMyDialog('$field نمی‌تواند خالی باشد.');
                  return;
                }
                Navigator.of(context).pop(controller.text.trim());
              },
            ),
            TextButton(
              child: const Text('انصراف'),
              onPressed: () {
                Navigator.of(context).pop('');
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.reportedRecitations.items!.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: IconButton(
                icon: const Icon(Icons.open_in_browser),
                onPressed: () async {
                  var url =
                      'http://ava.ganjoor.net/#/${widget.reportedRecitations.items![index].recitationId}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    throw 'خطا در نمایش نشانی $url';
                  }
                },
              ),
              title: Text(
                  '${widget.reportedRecitations.items![index].recitation.audioTitle} به خوانش ${widget.reportedRecitations.items![index].recitation.audioArtist}'),
              subtitle: Column(children: [
                Text(widget.reportedRecitations.items![index].reasonText ?? ''),
                Text(
                    'خط متناظر: ${widget.reportedRecitations.items![index].coupletIndex + 1}'),
                Text(widget
                    .reportedRecitations.items![index].recitation.audioArtist),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blueGrey)),
                  onPressed: () async {
                    String rejectionNote = (await _input('دلیل عدم پذیرش',
                            'دلیل', 'عدم تطابق با معیارهای حذف خوانش')) ??
                        '';
                    if (rejectionNote.isEmpty) return;
                    var res = await RecitationService().rejectReport(
                        widget.reportedRecitations.items![index].id,
                        rejectionNote,
                        false);
                    if (res.item1) {
                      widget.reportedRecitations.items!.removeAt(index);
                      setState(() {});
                    } else {
                      widget.snackbarNeeded(res.item2);
                    }
                  },
                  child: const Text('گزارش درست نیست'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red)),
                  onPressed: () async {
                    widget.loadingStateChanged(true);
                    var res = await RecitationService().approveReport(
                        widget.reportedRecitations.items![index].id, false);
                    if (res.item1) {
                      widget.reportedRecitations.items!.removeAt(index);
                      setState(() {});
                    } else {
                      widget.snackbarNeeded(res.item2);
                    }
                    widget.loadingStateChanged(false);
                  },
                  child: const Text('خوانش اشکال دارد و باید حذف شود'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.purple)),
                  onPressed: () async {
                    String mistake = (await _input(
                            'اشکال',
                            'اشکال',
                            widget.reportedRecitations.items![index]
                                .reasonText!)) ??
                        '';

                    if (mistake.isEmpty) return;
                    if (widget.reportedRecitations.items![index].coupletIndex !=
                        -1) {
                      String coupletIndex = (await _input(
                              'اندیس خط',
                              'اندیس خط',
                              widget.reportedRecitations.items![index]
                                  .coupletIndex
                                  .toString())) ??
                          '';
                      if (coupletIndex.isEmpty) {
                        widget.reportedRecitations.items![index].coupletIndex =
                            -1;
                      } else {
                        widget.reportedRecitations.items![index].coupletIndex =
                            int.parse(coupletIndex);
                      }
                    }
                    widget.reportedRecitations.items![index].reasonText =
                        mistake;
                    widget.loadingStateChanged(true);
                    var res = await RecitationService().saveRictationMistake(
                        widget.reportedRecitations.items![index], false);
                    if (res.item1) {
                      widget.reportedRecitations.items!.removeAt(index);
                      setState(() {});
                    } else {
                      widget.snackbarNeeded(res.item2);
                    }
                    widget.loadingStateChanged(false);
                  },
                  child: const Text('در فهرست اشکالات خوانش ثبت شود'),
                )
              ]),
              trailing: IconButton(
                icon: widget.reportedRecitations.items![index].isMarked
                    ? const Icon(Icons.check_box)
                    : const Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  setState(() {
                    widget.reportedRecitations.items![index].isMarked =
                        !widget.reportedRecitations.items![index].isMarked;
                  });
                },
              ));
        });
  }
}
