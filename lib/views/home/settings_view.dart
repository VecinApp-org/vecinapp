import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vecinapp/constants/routes.dart';

import '../../services/settings/settings_controller.dart';
import 'dart:developer' as devtools show log;

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

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
            title: const Text('Tema', style: TextStyle(fontSize: 20)),
            trailing: Padding(
                padding: const EdgeInsets.all(8),
                child: DropdownButton<ThemeMode>(
                    value: controller.themeMode,
                    onChanged: controller.updateThemeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('Igual que el sistema'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Claro'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Oscuro'),
                      )
                    ])),
          ),
          const Divider(),
          TextButton(
            onPressed: () async {
              devtools.log('Logging out...');
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).popAndPushNamed(
                  appRootRouteName,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
          TextButton(
            onPressed: () async {
              devtools.log('Deleting user...');
              try {
                await FirebaseAuth.instance.currentUser!.delete();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    appRootRouteName,
                    (route) => false,
                  );
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );
  }
}
