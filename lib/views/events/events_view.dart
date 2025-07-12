import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/views/events/edit_event_view.dart';
import 'package:vecinapp/views/events/event_list_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

class EventsView extends HookWidget {
  const EventsView({super.key, required this.cloudUser});
  final CloudUser cloudUser;
  @override
  Widget build(BuildContext context) {
    //get upcoming events
    final stream = useMemoized(() => context.watch<AppBloc>().events);
    final snapshot = useStream(stream);
    //check if snapshot is null
    if (snapshot.data == null) {
      return Container();
    }
    final events = snapshot.data!.toList();
    //sort events
    events.sort((a, b) => a.dateStart.compareTo(b.dateStart));
    return Scaffold(
        appBar: AppBar(
          title: const Text('Próximos Eventos'),
          actions: [
            Visibility(
              visible: cloudUser.isNeighborhoodAdmin,
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const EditEventView(),
                )),
              ),
            )
          ],
        ),
        body: (events.isEmpty)
            ? const Center(child: Text('No hay eventos'))
            : ListView(
                shrinkWrap: true,
                children: [EventListView(events: events)],
              ));
  }
}
