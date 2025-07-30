import 'package:flutter/material.dart';
import 'package:vecinapp/extensions/formatting/format_date_time.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:vecinapp/utilities/widgets/custom_card.dart';
import 'package:vecinapp/views/events/event_details_view.dart';

class EventListView extends StatelessWidget {
  final List<Event> events;

  const EventListView({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events.elementAt(index);
        return CustomCard(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return EventDetailsView(event: event);
              }));
            },
            title: Text(
              event.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📅  ${formatDateTime(event.dateStart, endTime: event.dateEnd)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '📍  ${event.placeName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
