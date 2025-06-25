import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'package:vecinapp/views/events/events_view.dart';
import 'package:vecinapp/views/forum/forum_view.dart';
import 'package:vecinapp/views/pooling/pooling_view.dart';
import 'package:vecinapp/views/reports/reports_view.dart';
import 'package:vecinapp/views/rulebooks/rulebooks_view.dart';

class NeighborhoodView extends HookWidget {
  const NeighborhoodView(
      {super.key, required this.neighborhood, this.selectedIndex});
  final int? selectedIndex;
  final Neighborhood neighborhood;

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController(initialPage: selectedIndex ?? 0);
    final currentPageIndex = useState(selectedIndex ?? 0);
    final cloudUser = context.read<AppBloc>().state.cloudUser!;
    return Scaffold(
        key: const Key('neighborhoodView'),
        bottomNavigationBar: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
              icon: Icon(Icons.forum_outlined),
              selectedIcon: Icon(Icons.forum),
              label: 'Foro',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event),
              label: 'Eventos',
            ),
            NavigationDestination(
              icon: Icon(Icons.report_outlined),
              selectedIcon: Icon(Icons.report),
              label: 'Reportes',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books),
              label: 'Recursos',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments),
              label: 'Caja',
            ),
          ],
        ),
        body: PageView(
          controller: pageController,
          allowImplicitScrolling: true,
          onPageChanged: (index) {
            currentPageIndex.value = index;
          },
          children: [
            ForumView(cloudUser: cloudUser, neighborhood: neighborhood),
            EventsView(cloudUser: cloudUser),
            ReportsView(),
            RulebooksView(cloudUser: cloudUser),
            PoolingView(cloudUser: cloudUser),
          ],
        ));
  }
}
