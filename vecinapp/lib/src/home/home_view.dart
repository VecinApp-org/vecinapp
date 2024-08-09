import 'package:flutter/material.dart';
import 'home_drawer.dart';

/// Displays a list of SampleItems.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = '/home';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('VecinApp'),
        ),
        drawer: const HomeDrawer(),
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
