import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/common/paginated_items_response_model.dart';
import 'package:gaudiopanel/models/recitation/recitation_publishing_tracker_viewmodel.dart';

class PublishQueueSection extends StatefulWidget {
  final PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel> queue;

  const PublishQueueSection({Key? key, required this.queue}) : super(key: key);

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
    return ListView.builder(
        itemCount: widget.queue.items!.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
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
              ]));
        });
  }
}
