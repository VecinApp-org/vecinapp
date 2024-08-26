import 'package:flutter/material.dart';
import 'package:vecinapp/constants/routes.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/utilities/show_confirmation_dialog.dart';
import 'package:vecinapp/utilities/show_error_dialog.dart';

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

              final confirmation = await showConfirmationDialog(
                context,
                '¿Seguro que quieres cerrar sesión?',
              );
              if (confirmation != null && confirmation) {
                await AuthService.firebase().logOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    appRootRouteName,
                    (route) => false,
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
          TextButton(
            onPressed: () async {
              devtools.log('Deleting user...');
              try {
                final confirmation = await showConfirmationDialog(
                  context,
                  '¿Seguro que quieres borrar tu cuenta?',
                );
                if (confirmation != null && confirmation) {
                  await AuthService.firebase().deleteAccount();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      appRootRouteName,
                      (route) => false,
                    );
                  }
                }
              } on RequiresRecentLoginAuthException {
                if (context.mounted) {
                  showErrorDialog(context, 'Requires recent login');
                }
              } on NetworkRequestFailedAuthException {
                if (context.mounted) {
                  showErrorDialog(context, 'No hay internet.');
                }
              } on GenericAuthException catch (e) {
                devtools.log('Error deleting user: ${e.runtimeType}');
                if (context.mounted) {
                  showErrorDialog(context, 'Algo salió mal');
                }
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
