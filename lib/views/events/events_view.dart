import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/views/events/event_list_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

class EventsView extends HookWidget {
  const EventsView({super.key, required this.cloudUser});
  final CloudUser cloudUser;
  @override
  Widget build(BuildContext context) {
    //get all events
    final stream = useMemoized(() => context.watch<AppBloc>().events);
    final snapshot = useStream(stream);
    //check if snapshot is null
    if (snapshot.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    //check if events are empty
    final events = snapshot.data!.toList();
    if (events.isEmpty) {
      return const Center(
        child: Text('No hay eventos'),
      );
    }
    //sort events
    events.sort((a, b) => a.dateStart.compareTo(b.dateStart));
    final currentDate = useMemoized(() => DateTime.now());
    //define past events
    final pastEvents = events
        .where((event) => event.dateEnd.isBefore(currentDate))
        .toList()
        .reversed
        .toList();
    //current events
    final happeningEvents = events
        .where((event) =>
            event.dateStart.isBefore(currentDate) &&
            event.dateEnd.isAfter(currentDate))
        .toList();
    //todays events that have not started
    final todaysEvents = events
        .where((event) =>
            event.dateStart.isBefore(DateTime(
                currentDate.year, currentDate.month, currentDate.day + 1)) &&
            event.dateStart.isAfter(currentDate))
        .toList();
    //events in the next 7 days
    final nextWeekEvents = events.where((event) {
      final isAfterToday = event.dateStart.isAfter(
          DateTime(currentDate.year, currentDate.month, currentDate.day + 1));
      return isAfterToday &&
          event.dateStart.isBefore(currentDate.add(const Duration(days: 7)));
    }).toList();
    //events after this week
    final eventsAfterWeek = events.where((event) {
      final isAfterNow =
          event.dateStart.isAfter(currentDate.add(const Duration(days: 7)));
      final isNotToday = event.dateStart.day != currentDate.day ||
          event.dateStart.month != currentDate.month ||
          event.dateStart.year != currentDate.year;
      return isAfterNow && isNotToday;
    }).toList();
    final toggleViewPastEvents = useState<bool>(false);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Eventos'),
        ),
        floatingActionButton: Visibility(
          visible: cloudUser.isNeighborhoodAdmin,
          child: FloatingActionButton(
              onPressed: () =>
                  context.read<AppBloc>().add(AppEventGoToEditEventView()),
              child: const Icon(Icons.add)),
        ),
        body: ListView(
          shrinkWrap: true,
          children: [
            ListSectionTitle(
              text: 'Sucediendo ahora',
              visible: happeningEvents.isNotEmpty,
            ),
            Visibility(
              visible: happeningEvents.isNotEmpty,
              child: EventListView(
                events: happeningEvents,
              ),
            ),
            ListSectionTitle(
              text: 'Hoy',
              visible: todaysEvents.isNotEmpty,
            ),
            Visibility(
              visible: todaysEvents.isNotEmpty,
              child: EventListView(
                events: todaysEvents,
              ),
            ),
            ListSectionTitle(
              text: 'Próximos 7 dias',
              visible: nextWeekEvents.isNotEmpty,
            ),
            Visibility(
              visible: nextWeekEvents.isNotEmpty,
              child: EventListView(
                events: nextWeekEvents,
              ),
            ),
            ListSectionTitle(
              text: 'Después',
              visible: eventsAfterWeek.isNotEmpty,
            ),
            Visibility(
              visible: eventsAfterWeek.isNotEmpty,
              child: EventListView(
                events: eventsAfterWeek,
              ),
            ),
            Visibility(
              visible: pastEvents.isNotEmpty,
              child: TextButton(
                  onPressed: () =>
                      toggleViewPastEvents.value = !toggleViewPastEvents.value,
                  child: toggleViewPastEvents.value
                      ? Text('Ocultar')
                      : Text('Ver Eventos Pasados')),
            ),
            Visibility(
              visible: pastEvents.isNotEmpty && !toggleViewPastEvents.value,
              child: SizedBox(height: 170),
            ),
            Visibility(
              visible: pastEvents.isNotEmpty && toggleViewPastEvents.value,
              child: EventListView(
                events: pastEvents,
              ),
            ),
          ],
        ));
  }
}

class ListSectionTitle extends StatelessWidget {
  const ListSectionTitle({super.key, this.visible = true, required this.text});

  final bool visible;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
