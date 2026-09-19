import 'package:flutter/material.dart';
import 'package:gaudiopanel/callbacks/g_ui_callbacks.dart';
import 'package:gaudiopanel/forms/generic_lookups.dart';
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
      {super.key,
      required this.reportedRecitations,
      required this.loadingStateChanged,
      required this.snackbarNeeded});

  @override
  State<StatefulWidget> createState() => _ProfilesState();
}

class _ProfilesState extends State<ReportedDataSection> {
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
                        errorAlert(context, '$field نمی‌تواند خالی باشد.'),
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
                  errorAlert(context, '$field نمی‌تواند خالی باشد.');
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

  Future<bool?> _confirm(String title, String text) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(text),
          ),
          actions: [
            ElevatedButton(
              child: const Text('بله'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('خیر'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reportedRecitations.items == null ||
        widget.reportedRecitations.items!.isEmpty) {
      return const EmptyState(
        icon: Icons.flag_outlined,
        message: 'خوانش گزارش‌شده‌ای برای بررسی وجود ندارد.',
      );
    }
    return ListView.builder(
        itemCount: widget.reportedRecitations.items!.length,
        itemBuilder: (BuildContext context, int index) {
          bool marked = widget.reportedRecitations.items![index].isMarked;
          return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: marked ? 3 : 1,
              color: marked
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: marked
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: marked ? 1.5 : 1,
                ),
              ),
              child: ListTile(
              leading: IconButton(
                icon: const Icon(Icons.open_in_browser),
                onPressed: () async {
                  var res = await RecitationService()
                      .getPublishedRecitationById(
                          id: widget
                              .reportedRecitations.items![index].recitationId,
                          error401: false);
                  if (!context.mounted) return;
                  if (res.item2.isNotEmpty) {
                    await errorAlert(context, res.item2);
                    return;
                  }
                  var url = widget
                              .reportedRecitations.items![index].coupletIndex ==
                          -1
                      ? 'https://ganjoor.net${res.item1!.poemFullUrl}?allaudio=1#${res.item1!.id}'
                      : 'https://ganjoor.net${res.item1!.poemFullUrl}#bn${widget.reportedRecitations.items![index].coupletIndex + 1}';
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
                ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.blueGrey)),
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
                  icon: const Icon(Icons.thumb_down_alt_outlined),
                  label: const Text('گزارش درست نیست'),
                ),
                ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.red)),
                  onPressed: () async {
                    if (true !=
                        await _confirm('تأییدیه',
                            'آیا اطمینان دارید که این خوانش باید حذف شود؟')) {
                      return;
                    }
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
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('خوانش اشکال دارد و باید حذف شود'),
                ),
                ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.yellow)),
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
                  icon: const Icon(Icons.bug_report_outlined),
                  label: const Text('در فهرست اشکالات خوانش ثبت شود'),
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
              )));
        });
  }
}
