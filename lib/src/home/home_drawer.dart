import 'package:flutter/material.dart';

import 'home_view.dart';
import '../rulebooks/rulebook_list.dart';
import '../contacts/contact_list.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  static const routeName = '/';

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _navigationDrawerIndex = 0;
  late bool showNavigationDrawer;

  void handleScreenChanged(int selectedScreen) {
    if (_navigationDrawerIndex != selectedScreen) {
      setState(() {
        _navigationDrawerIndex = selectedScreen;
      });
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const [
          HomeView.title,
          ContactList.title,
          RulebookList.title,
        ][_navigationDrawerIndex],
      ),
      body: const [
        HomeView(),
        ContactList(),
        RulebookList(),
      ][_navigationDrawerIndex],
      drawer: NavigationDrawer(
        onDestinationSelected: (int index) {
          handleScreenChanged(index);
        },
        selectedIndex: _navigationDrawerIndex,
        children: <Widget>[
          DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VecinApp',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                )
              ],
            ),
          ),
          const NavigationDrawerDestination(
            icon: HomeView.icon,
            selectedIcon: HomeView.selectedIcon,
            label: HomeView.title,
          ),
          const NavigationDrawerDestination(
            icon: ContactList.icon,
            selectedIcon: ContactList.selectedIcon,
            label: ContactList.title,
          ),
          const NavigationDrawerDestination(
            icon: RulebookList.icon,
            selectedIcon: RulebookList.selectedIcon,
            label: RulebookList.title,
          ),
        ],
      ),
    );
  }
}