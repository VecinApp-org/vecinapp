import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'settings_controller.dart';
import 'dart:developer' as devtools show log;

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Theme', style: TextStyle(fontSize: 20)),
            trailing: Padding(
                padding: const EdgeInsets.all(8),
                child: DropdownButton<ThemeMode>(
                    value: controller.themeMode,
                    onChanged: controller.updateThemeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      )
                    ])),
          ),
          const Divider(),
          TextButton(
            onPressed: () async {
              devtools.log(
                  'About to sign out ${FirebaseAuth.instance.currentUser}');
              await FirebaseAuth.instance.signOut();
              devtools.log('Logged out: ${FirebaseAuth.instance.currentUser}');
              if (context.mounted) {
                devtools.log('Pushing home');
                Navigator.of(context).popAndPushNamed('/');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
          TextButton(
            onPressed: () async {
              try {
                devtools.log(
                    'About to delete ${FirebaseAuth.instance.currentUser}');
                await FirebaseAuth.instance.currentUser!.delete();
                devtools.log('Deleted: ${FirebaseAuth.instance.currentUser}');
                if (context.mounted) {
                  devtools.log('Pushing home');
                  Navigator.of(context).popAndPushNamed('/');
                }
              } on FirebaseAuthException catch (e) {
                switch (e.code) {
                  case 'requires-recent-login':
                    devtools.log(
                        'The user must reauthenticate before this operation can be executed.');
                  default:
                    devtools.log('Unknown error deleting user: $e');
                }
              } catch (e) {
                devtools.log('Error deleting user: ${e.runtimeType}');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );
  }
}
