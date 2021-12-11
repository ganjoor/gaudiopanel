import 'package:flutter/material.dart';
import 'package:gaudiopanel/callbacks/g-ui-callbacks.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/recitation/recitation_error_report_viewmodel.dart';
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
                Text(widget.reportedRecitations.items[index].reasonText),
                Text(widget
                    .reportedRecitations.items[index].recitation.audioArtist),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(widget.reportedRecitations.items[index]
                        .recitation.audioArtistUrl))
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
