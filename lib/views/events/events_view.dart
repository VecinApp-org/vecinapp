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
    final stream = useMemoized(() => context.watch<AppBloc>().events);
    final events = useStream(stream);
    final currentDate = useMemoized(() => DateTime.now());
    final happeningEvents = events.data?.where((event) =>
        event.dateStart.isBefore(currentDate) &&
        event.dateEnd.isAfter(currentDate));
    final todaysEvents = events.data?.where((event) =>
        event.dateStart.isAfter(currentDate) &&
        event.dateStart.day == currentDate.day &&
        event.dateEnd.month == currentDate.month &&
        event.dateEnd.year == currentDate.year);
    final eventsAfterToday = events.data?.where((event) {
      final isAfterNow = event.dateStart.isAfter(currentDate);
      final isNotToday = event.dateStart.day != currentDate.day ||
          event.dateStart.month != currentDate.month ||
          event.dateStart.year != currentDate.year;
      return isAfterNow && isNotToday;
    });
    final pastEvents =
        events.data?.where((event) => event.dateEnd.isBefore(currentDate));
    final toggleViewPastEvents = useState<bool>(false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        leading: BackButton(
            onPressed: () => context
                .read<AppBloc>()
                .add(const AppEventGoToNeighborhoodView())),
      ),
      floatingActionButton: Visibility(
        visible: cloudUser.isNeighborhoodAdmin,
        child: FloatingActionButton(
            onPressed: () =>
                context.read<AppBloc>().add(const AppEventGoToEditEventView()),
            child: const Icon(Icons.add)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: events.data == null
            ? Container()
            : events.data!.isEmpty
                ? Center(
                    child: Text(
                    'No hay eventos',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ))
                : ListView(
                    children: [
                      Visibility(
                        visible: happeningEvents?.isNotEmpty ?? false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sucediendo ahora',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            EventListView(
                              events: happeningEvents ?? [],
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: todaysEvents?.isNotEmpty ?? false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hoy',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            EventListView(
                              events: todaysEvents ?? [],
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: eventsAfterToday?.isNotEmpty ?? false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Después',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            EventListView(
                              events: eventsAfterToday ?? [],
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: pastEvents?.isNotEmpty ?? false,
                        child: Column(
                          children: [
                            TextButton(
                                onPressed: () => toggleViewPastEvents.value =
                                    !toggleViewPastEvents.value,
                                child: const Text('Ver Eventos Pasados')),
                            Visibility(
                              visible: toggleViewPastEvents.value,
                              child: EventListView(
                                events: pastEvents ?? [],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
