import 'package:flutter/material.dart';

int navigationDrawerIndex = 0;

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  void updateSelectedIndex(int index) {
    if (index == navigationDrawerIndex) {
      return;
    }
    setState(() {
      navigationDrawerIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      onDestinationSelected: (int index) {
        updateSelectedIndex(index);
        switch (index) {
          case 0:
            Navigator.popAndPushNamed(context, '/home');
          case 1:
            Navigator.popAndPushNamed(context, '/rulebooks');
          case 2:
            Navigator.popAndPushNamed(context, '/settings');
        }
      },
      selectedIndex: navigationDrawerIndex,
      children: <Widget>[
        DrawerHeader(
          child: Text(
            'VecinApp',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home),
          label: Text('Inicio'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.book),
          label: Text('Reglamentos'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings),
          label: Text('Ajustes'),
        ),
      ],
    );
  }
}
