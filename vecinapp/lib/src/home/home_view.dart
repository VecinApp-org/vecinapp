import 'package:flutter/material.dart';
import '../settings/settings_view.dart';
import '../sample_feature/sample_item_list_view.dart';

/// Displays a list of SampleItems.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var navigationDrawerIndex = 0;

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
          selectedIndex: navigationDrawerIndex,
          onDestinationSelected: (int index) {
            setState(() {
              navigationDrawerIndex = index;
            });
            switch (index) {
              case 0:
                Navigator.restorablePushNamed(context, HomeView.routeName);
              case 1:
                Navigator.restorablePushNamed(
                    context, SampleItemListView.routeName);
              case 2:
                Navigator.restorablePushNamed(context, SettingsView.routeName);
            }
          },
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
              icon: Icon(Icons.message),
              label: Text('Mensajes'),
            ),
            const NavigationDrawerDestination(
              icon: Icon(Icons.settings),
              label: Text('Ajustes'),
            ),
          ],
        ),
        body: ListView(
          children: const <Widget>[
            Card(
              child: ListTile(
                leading: Icon(Icons.notification_important),
                title: Text('Realiza tu aportación anual'),
                subtitle: Text(
                    'Para accesar a más información de tu vecindad, es necesario que realices la aportación anual de tu domicilio.'),
                isThreeLine: true,
                trailing: Icon(Icons.arrow_forward),
                onTap: null,
              ),
            ),
            ListTile(
              leading: CircleAvatar(child: Text('V')),
              title: Text('Vecindad Las Brisas'),
              subtitle: Text('Sandra: Yo digo que si.'),
            ),
            Divider(height: 0),
            ListTile(
              leading: CircleAvatar(child: Text('C')),
              title: Text('Calle Puerto Trinidad'),
              subtitle: Text('Sandra: Yo digo que si.'),
            ),
            Divider(height: 0),
            ListTile(
              leading: CircleAvatar(child: Text('E')),
              title: Text('Edificio #1050 Puerto Trinidad'),
              subtitle: Text('Sandra: Yo digo que si.'),
            ),
            Divider(height: 0),
          ],
        ));
  }
}
