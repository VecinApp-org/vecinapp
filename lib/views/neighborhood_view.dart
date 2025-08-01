import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'package:vecinapp/views/events/events_view.dart';
import 'package:vecinapp/views/forum/forum_view.dart';
import 'package:vecinapp/views/pooling/pooling_view.dart';
import 'package:vecinapp/views/profile_view.dart';
import 'package:vecinapp/views/reports/reports_view.dart';
import 'package:vecinapp/views/rulebooks/rulebooks_view.dart';

class NeighborhoodView extends HookWidget {
  const NeighborhoodView(
      {super.key,
      required this.neighborhood,
      this.selectedIndex = 0,
      required this.household,
      required this.cloudUser});
  final int selectedIndex;
  final Neighborhood neighborhood;
  final Household household;
  final CloudUser cloudUser;

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController(initialPage: selectedIndex);
    final currentPageIndex = useState(selectedIndex);
    return Scaffold(
        key: const Key('neighborhoodView'),
        bottomNavigationBar: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (int index) async {
            currentPageIndex.value = index;
            pageController.jumpToPage(index);
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
            NavigationDestination(
                icon: Icon(Icons.person),
                selectedIcon: Icon(Icons.person),
                label: 'Perfil'),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          //allowImplicitScrolling: true,
          onPageChanged: (index) {
            currentPageIndex.value = index;
          },
          children: [
            ForumView(),
            EventsView(cloudUser: cloudUser),
            ReportsView(),
            RulebooksView(cloudUser: cloudUser),
            PoolingView(cloudUser: cloudUser),
            ProfileView(
                cloudUser: cloudUser,
                household: household,
                neighborhood: neighborhood),
          ],
        ));
  }
}
