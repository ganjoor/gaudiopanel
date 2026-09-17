import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/generic_lookups.dart';
import 'package:gaudiopanel/models/common/paginated_items_response_model.dart';
import 'package:gaudiopanel/models/recitation/uploaded_item_viewmodel.dart';

class UploadsDataSection extends StatefulWidget {
  final PaginatedItemsResponseModel<UploadedItemViewModel> uploads;

  const UploadsDataSection({super.key, required this.uploads});

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
    return (widget.uploads.items == null || widget.uploads.items!.isEmpty)
        ? const EmptyState(
            icon: Icons.cloud_upload_outlined,
            message: 'هنوز فایلی بارگذاری نکرده‌اید.\n'
                'برای شروع، از دکمهٔ + در پایین صفحه استفاده کنید.',
          )
        : ListView.builder(
            itemCount: widget.uploads.items!.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  leading: getUploadIcon(widget.uploads.items![index]),
                  title: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(widget.uploads.items![index].fileName)),
                  subtitle:
                      Text(widget.uploads.items![index].processResultMsg));
            });
  }
}
