import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/generic_lookups.dart';
import 'package:gaudiopanel/models/common/paginated_items_response_model.dart';
import 'package:gaudiopanel/models/recitation/recitation_publishing_tracker_viewmodel.dart';

class PublishQueueSection extends StatefulWidget {
  final PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel> queue;

  const PublishQueueSection({super.key, required this.queue});

  @override
  State<StatefulWidget> createState() => _PublishQueueSectionState();
}

class _PublishQueueSectionState extends State<PublishQueueSection> {
  Icon getStatusIcon(RecitationPublishingTrackerViewModel tracker) {
    return tracker.succeeded
        ? const Icon(Icons.check, color: Colors.green)
        : tracker.error
            ? const Icon(Icons.error, color: Colors.red)
            : const Icon(Icons.query_builder, color: Colors.orange);
  }

  String _lastException(index) {
    return widget.queue.items![index].lastException == null
        ? ''
        : 'خطا: ${widget.queue.items![index].lastException}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.queue.items == null || widget.queue.items!.isEmpty) {
      return const EmptyState(
        icon: Icons.publish_outlined,
        message: 'صف انتشار خالی است؛ در حال حاضر موردی در حال ارسال به گنجور نیست.',
      );
    }
    return ListView.builder(
        itemCount: widget.queue.items!.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListTile(
              leading: getStatusIcon(widget.queue.items![index]),
              title: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(widget.queue.items![index].poemFullTitle)),
              subtitle: Column(children: [
                Text(widget.queue.items![index].artistName),
                Text(widget.queue.items![index].operation),
                Visibility(
                  visible: widget.queue.items![index].error,
                  child: Text(_lastException(index)),
                )
              ])));
        });
  }
}
