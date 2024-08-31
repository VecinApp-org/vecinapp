import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/constants/routes.dart';
import 'package:vecinapp/services/auth/bloc/auth_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/utilities/show_confirmation_dialog.dart';
import 'package:vecinapp/views/home/docs/docs_view.dart';
import 'contacts/contact_list.dart';
import 'dart:developer' as devtools show log;

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _navigationDrawerIndex = 2;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmLogout = await showConfirmationDialog(
                context: context,
                text: '¿Seguro que quieres cerrar la sesión?',
              );
              if (confirmLogout == true && context.mounted) {
                context.read<AuthBloc>().add(
                      const AuthEventLogOut(),
                    );
              }
            },
          ),
        ],
        title: const [
          Text(''),
          Text('Contactos'),
          Text('Documentos'),
        ][_navigationDrawerIndex],
      ),
      body: const [
        DashboardView(),
        ContactList(),
        DocsView(),
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
                  'Tu Vecindad',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      settingsRouteName,
                    );
                  },
                )
              ],
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Inicio'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: Text('Contactos'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: Text('Documentos'),
          ),
        ],
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    devtools.log('Build Dashboard View');
    return ListView(
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
    );
  }
}
