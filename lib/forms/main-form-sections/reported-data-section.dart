import 'package:flutter/material.dart';
import 'package:gaudiopanel/callbacks/g-ui-callbacks.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/recitation/recitation_error_report_viewmodel.dart';
import 'package:gaudiopanel/services/recitation-service.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportedDataSection extends StatefulWidget {
  final PaginatedItemsResponseModel<RecitationErrorReportViewModel>
      reportedRecitations;
  final LoadingStateChanged loadingStateChanged;
  final SnackbarNeeded snackbarNeeded;

  const ReportedDataSection(
      {Key key,
      this.reportedRecitations,
      this.loadingStateChanged,
      this.snackbarNeeded})
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
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text('خطا'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(error)],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('تأیید'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _input(String title, String field, String value) async {
    TextEditingController controller = TextEditingController();
    controller.text = value;

    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(
            title,
            style: Theme.of(context).textTheme.headline2,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: controller,
                  obscureText: false,
                  readOnly: false,
                  onFieldSubmitted: (String value) => {
                    if (controller.text.trim().isEmpty)
                      {
                        _showMyDialog('$field نمی‌تواند خالی باشد.'),
                      }
                    else
                      {Navigator.of(context).pop(controller.text.trim())}
                  },
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: field,
                      labelText: field,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('تأیید'),
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  _showMyDialog('$field نمی‌تواند خالی باشد.');
                  return;
                }
                Navigator.of(context).pop(controller.text.trim());
              },
            ),
            TextButton(
              child: Text('انصراف'),
              onPressed: () {
                Navigator.of(context).pop();
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
        itemCount: widget.reportedRecitations.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: IconButton(
                icon: Icon(Icons.open_in_browser),
                onPressed: () async {
                  var url = 'http://ava.ganjoor.net/#/' +
                      widget.reportedRecitations.items[index].recitationId
                          .toString();
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'خطا در نمایش نشانی $url';
                  }
                },
              ),
              title: Text(widget
                      .reportedRecitations.items[index].recitation.audioTitle +
                  ' به خوانش ' +
                  widget
                      .reportedRecitations.items[index].recitation.audioArtist),
              subtitle: Column(children: [
                Text(widget.reportedRecitations.items[index].reasonText == null
                    ? ''
                    : widget.reportedRecitations.items[index].reasonText),
                Text(widget
                    .reportedRecitations.items[index].recitation.audioArtist),
                ElevatedButton(
                  child: Text('گزارش درست نیست'),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue)),
                  onPressed: () async {
                    String rejectionNote = await _input('دلیل عدم پذیرش',
                        'دلیل', 'عدم تطابق با معیارهای حذف خوانش');
                    var res = await RecitationService().rejectReport(
                        widget.reportedRecitations.items[index].id,
                        rejectionNote,
                        false);
                    if (res.item1) {
                      widget.reportedRecitations.items.removeAt(index);
                      setState(() {});
                    } else {
                      widget.snackbarNeeded(res.item2);
                    }
                  },
                ),
                ElevatedButton(
                  child: Text('خوانش اشکال دارد'),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red)),
                  onPressed: () {},
                )
              ]),
              trailing: IconButton(
                icon: widget.reportedRecitations.items[index].isMarked
                    ? Icon(Icons.check_box)
                    : Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  setState(() {
                    widget.reportedRecitations.items[index].isMarked =
                        !widget.reportedRecitations.items[index].isMarked;
                  });
                },
              ));
        });
  }
}
