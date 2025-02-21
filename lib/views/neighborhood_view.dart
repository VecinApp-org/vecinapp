import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/constants/neighborhood_page_index.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';
import 'package:vecinapp/views/events/events_view.dart';
import 'package:vecinapp/views/rulebooks/rulebooks_view.dart';

class NeighborhoodView extends HookWidget {
  const NeighborhoodView(
      {super.key, required this.neighborhood, this.selectedIndex});
  final int? selectedIndex;
  final Neighborhood neighborhood;

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController(initialPage: selectedIndex ?? 0);
    final currentPageIndex =
        useState(selectedIndex ?? NeighborhoodPageIndex.events);
    final cloudUser = context.read<AppBloc>().state.cloudUser!;
    return Scaffold(
        key: const Key('neighborhoodView'),
        appBar: AppBar(
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
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (int index) async {
            currentPageIndex.value = index;
            await pageController.animateToPage(
              index,
              duration: kThemeAnimationDuration,
              curve: Curves.easeInOut,
            );
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
        floatingActionButton: Visibility(
          visible: cloudUser.isNeighborhoodAdmin,
          child: <Widget>[
            FloatingActionButton(
                onPressed: () =>
                    context.read<AppBloc>().add(AppEventGoToEditEventView()),
                child: const Icon(Icons.add)),
            FloatingActionButton(
              onPressed: () => context
                  .read<AppBloc>()
                  .add(const AppEventGoToEditRulebookView()),
              child: const Icon(Icons.add),
            ),
          ][currentPageIndex.value],
        ),
        body: PageView(
          controller: pageController,
          onPageChanged: (index) {
            currentPageIndex.value = index;
          },
          children: [
            EventsView(cloudUser: cloudUser),
            RulebooksView(cloudUser: cloudUser),
          ],
        ));
  }
}
