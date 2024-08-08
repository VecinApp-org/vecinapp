import 'package:flutter/material.dart';

int _navigationDrawerIndex = 0;

get index => _navigationDrawerIndex;

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      onDestinationSelected: (int index) {
        // Update the state of the app with the item that was selected.
        if (_navigationDrawerIndex == index) {
          Navigator.pop(context);
          return;
        }
        setState(() {
          _navigationDrawerIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
          case 1:
            Navigator.pushReplacementNamed(context, '/contacts');
          case 2:
            Navigator.pushReplacementNamed(context, '/rulebooks');
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
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Inicio'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: Text('Contactos'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: Text('Reglamentos'),
        ),
      ],
    );
  }
}
