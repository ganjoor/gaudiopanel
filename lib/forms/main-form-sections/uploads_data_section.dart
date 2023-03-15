import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/common/paginated_items_response_model.dart';
import 'package:gaudiopanel/models/recitation/uploaded_item_viewmodel.dart';

class UploadsDataSection extends StatefulWidget {
  final PaginatedItemsResponseModel<UploadedItemViewModel> uploads;

  const UploadsDataSection({Key key, this.uploads}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UploadsState();
}

class _UploadsState extends State<UploadsDataSection> {
  Icon getUploadIcon(UploadedItemViewModel upload) {
    return upload.processResult
        ? upload.processProgress == 100
            ? const Icon(Icons.check, color: Colors.green)
            : const Icon(Icons.query_builder, color: Colors.orange)
        : upload.processResultMsg.isNotEmpty
            ? const Icon(Icons.error, color: Colors.red)
            : const Icon(Icons.query_builder, color: Colors.orange);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.uploads.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: getUploadIcon(widget.uploads.items[index]),
              title: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(widget.uploads.items[index].fileName)),
              subtitle: Text(widget.uploads.items[index].processResultMsg));
        });
  }
}
