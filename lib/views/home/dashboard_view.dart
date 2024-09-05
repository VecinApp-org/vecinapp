import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    devtools.log('Build Dashboard View');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu)),
      ),
      body: ListView(
        restorationId: 'homeView',
        children: const <Widget>[
          Card(
            elevation: 10,
            margin: EdgeInsets.all(16),
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
      ),
    );
  }
}
