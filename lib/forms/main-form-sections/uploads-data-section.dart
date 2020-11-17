import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/recitation/uploaded-item-viewmodel.dart';

class UploadsDataSection extends StatefulWidget {
  final PaginatedItemsResponseModel<UploadedItemViewModel> uploads;

  const UploadsDataSection({Key key, this.uploads}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UploadsState(this.uploads);
}

class _UploadsState extends State<UploadsDataSection> {
  final PaginatedItemsResponseModel<UploadedItemViewModel> uploads;

  _UploadsState(this.uploads);

  Icon getUploadIcon(UploadedItemViewModel upload) {
    return upload.processResult
        ? upload.processProgress == 100
            ? Icon(Icons.check, color: Colors.green)
            : Icon(Icons.query_builder, color: Colors.orange)
        : upload.processResultMsg.isNotEmpty
            ? Icon(Icons.error, color: Colors.red)
            : Icon(Icons.query_builder, color: Colors.orange);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: uploads.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: getUploadIcon(uploads.items[index]),
              title: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(uploads.items[index].fileName)),
              subtitle: Text(uploads.items[index].processResultMsg));
        });
  }
}
