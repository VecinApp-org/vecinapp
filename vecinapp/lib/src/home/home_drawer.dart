import 'package:flutter/material.dart';

int _navigationDrawerIndex = 0;

get index => _navigationDrawerIndex;

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  void updateSelectedIndex(int index) {
    if (index == _navigationDrawerIndex) {
      return;
    }
    setState(() {
      _navigationDrawerIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      onDestinationSelected: (int index) {
        updateSelectedIndex(index);
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
          case 1:
            Navigator.pushReplacementNamed(context, '/rulebooks');
          case 2:
            Navigator.pushReplacementNamed(context, '/settings');
        }
      },
      selectedIndex: _navigationDrawerIndex,
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
