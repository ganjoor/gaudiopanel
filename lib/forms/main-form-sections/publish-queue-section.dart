import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/recitation/recitation-publishing-tracker-viewmodel.dart';

class PublishQueueSection extends StatefulWidget {
  final PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel> queue;

  const PublishQueueSection({Key key, this.queue}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PublishQueueSectionState(this.queue);
}

class _PublishQueueSectionState extends State<PublishQueueSection> {
  final PaginatedItemsResponseModel<RecitationPublishingTrackerViewModel> queue;

  _PublishQueueSectionState(this.queue);

  Icon getStatusIcon(RecitationPublishingTrackerViewModel tracker) {
    return tracker.succeeded
        ? Icon(Icons.check, color: Colors.green)
        : tracker.error
            ? Icon(Icons.error, color: Colors.red)
            : Icon(Icons.query_builder, color: Colors.orange);
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
                  child: Text('خطا: ' + queue.items[index].lastException),
                  visible: queue.items[index].error,
                )
              ]));
        });
  }
}
