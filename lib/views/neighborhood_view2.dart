import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';
import 'package:vecinapp/views/events/events_view.dart';
import 'package:vecinapp/views/rulebooks/rulebooks_view.dart';

class NeighborhoodView2 extends HookWidget {
  const NeighborhoodView2(
      {super.key, required this.neighborhood, this.selectedIndex});
  final int? selectedIndex;
  final Neighborhood neighborhood;

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = useState(selectedIndex ?? 0);
    final cloudUser = context.read<AppBloc>().state.cloudUser!;
    return Scaffold(
      key: const Key('neighborhoodView'),
      appBar: AppBar(
        elevation: 1,
        title: Text(
          neighborhood.neighborhoodName,
        ),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 13.0),
              child: GestureDetector(
                  onTap: () => context
                      .read<AppBloc>()
                      .add(const AppEventGoToProfileView()),
                  child: ProfilePicture(
                    radius: 16,
                    id: cloudUser.id,
                  )))
        ],
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: Duration(milliseconds: 300),
        onDestinationSelected: (int index) {
          currentPageIndex.value = index;
        },
        selectedIndex: currentPageIndex.value,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Eventos',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Reglamentos',
          ),
        ],
      ),
      body: <Widget>[
        EventsView(cloudUser: cloudUser),
        RulebooksView(cloudUser: cloudUser),
      ][currentPageIndex.value],
    );
  }
}
