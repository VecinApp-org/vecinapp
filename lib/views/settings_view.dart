import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/utilities/show_confirmation_dialog.dart';

import '../services/settings/settings_controller.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  final SettingsController controller = SettingsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const SizedBox(height: 32),
          const Text('Configuración', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 32),
          ListTile(
            title: const Text('Tema', style: TextStyle(fontSize: 20)),
            trailing: DropdownButton<ThemeMode>(
                value: controller.themeMode,
                onChanged: controller.updateThemeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Noche'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Día'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Sistema'),
                  )
                ]),
          ),
          //const Divider(),
          const Spacer(),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () async {
              final confirmLogout = await showConfirmationDialog(
                context: context,
                text: '¿Quieres salir de tu cuenta?',
              );
              if (confirmLogout == true && context.mounted) {
                context.read<AuthBloc>().add(
                      const AuthEventLogOut(),
                    );
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () async {
              final confirmLogout = await showConfirmationDialog(
                context: context,
                text: '¿Quieres eliminar tu cuenta?',
              );
              if (confirmLogout == true && context.mounted) {
                context.read<AuthBloc>().add(
                      const AuthEventDeleteAccount(),
                    );
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar cuenta'),
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}
