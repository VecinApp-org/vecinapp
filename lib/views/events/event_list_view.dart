import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:intl/intl.dart';

class EventListView extends StatelessWidget {
  final List<Event> events;

  const EventListView({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events.elementAt(index);
        return Card(
          child: ListTile(
            onTap: () {
              context.read<AppBloc>().add(
                    AppEventGoToEventDetailsView(
                      event: event,
                    ),
                  );
            },
            title: Text(
              event.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📅  ${DateFormat.EEEE().add_d().add_MMMM().add_jm().format(event.dateStart)}',
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
        );
      },
    );
  }
}
