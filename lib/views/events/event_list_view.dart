import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/event.dart';

class EventListView extends StatelessWidget {
  final Iterable<Event> events;

  const EventListView({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events.elementAt(index);
          return Column(
            children: [
              ListTile(
                onTap: () {
                  context.read<AppBloc>().add(
                        AppEventGoToEventDetailsView(
                          event: event,
                        ),
                      );
                },
                title: Text(
                  event.title,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(),
            ],
          );
        });
  }
}
