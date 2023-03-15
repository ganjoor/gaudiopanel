import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/common/paginated_items_response_model.dart';
import 'package:gaudiopanel/models/recitation/recitation_publishing_tracker_viewmodel.dart';

class PublishQueueSection extends StatefulWidget {
  final PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel> queue;

  const PublishQueueSection({Key key, this.queue}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PublishQueueSectionState(queue);
}

class _PublishQueueSectionState extends State<PublishQueueSection> {
  final PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel> queue;

  _PublishQueueSectionState(this.queue);

  Icon getStatusIcon(RecitationPublishingTrackerViewModel tracker) {
    return tracker.succeeded
        ? const Icon(Icons.check, color: Colors.green)
        : tracker.error
            ? const Icon(Icons.error, color: Colors.red)
            : const Icon(Icons.query_builder, color: Colors.orange);
  }

  String _lastException(index) {
    return queue.items[index].lastException == null
        ? ''
        : 'خطا: ${queue.items[index].lastException}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: queue.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: getStatusIcon(queue.items[index]),
              title: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(queue.items[index].poemFullTitle)),
              subtitle: Column(children: [
                Text(queue.items[index].artistName),
                Text(queue.items[index].operation),
                Visibility(
                  visible: queue.items[index].error,
                  child: Text(_lastException(index)),
                )
              ]));
        });
  }
}
