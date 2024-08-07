import 'package:flutter/material.dart';
import '../settings/settings_view.dart';

/// Displays a list of SampleItems.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VecinApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(
                context,
                SettingsView.routeName,
              );
            },
          ),
        ],
      ),
      drawer: NavigationDrawer(
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'VecinApp',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.message),
            label: Text('Mensajes'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.account_circle),
            label: Text('Perfil'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.settings),
            label: Text('Ajustes'),
          ),
        ],
      ),
    );
  }
}
