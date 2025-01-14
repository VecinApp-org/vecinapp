import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/views/events/event_list_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EventsView extends HookWidget {
  const EventsView({super.key, required this.cloudUser});
  final CloudUser cloudUser;
  @override
  Widget build(BuildContext context) {
    final stream = useMemoized(() => context.watch<AppBloc>().events);
    final events = useStream(stream);
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
              onPressed: () => context
                  .read<AppBloc>()
                  .add(const AppEventGoToNeighborhoodView())),
        ),
        floatingActionButton: Visibility(
          visible: cloudUser.isNeighborhoodAdmin,
          child: FloatingActionButton(
              onPressed: () => context
                  .read<AppBloc>()
                  .add(const AppEventGoToEditEventView()),
              child: const Icon(Icons.add)),
        ),
        body: EventListView(events: events.data ?? []));
  }
}
