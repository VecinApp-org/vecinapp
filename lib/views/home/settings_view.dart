import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/constants/routes.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/services/auth/bloc/auth_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/services/auth/bloc/auth_state.dart';
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
      appBar: AppBar(),
      body: Column(
        children: [
          const SizedBox(height: 32),
          const Text('Configuración', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 32),
          ListTile(
            title: const Text('Modo Oscuro', style: TextStyle(fontSize: 20)),
            trailing: DropdownButton<ThemeMode>(
                value: controller.themeMode,
                onChanged: controller.updateThemeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Prendido'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Apagado'),
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
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthStateLoggedOut) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRouteName,
                  (route) => false,
                );
              } else if (state is AuthStateLoggedOutFailure) {
                showErrorDialog(context, state.exception.toString());
              } else if (state is AuthStateLoggedIn) {
                showErrorDialog(context, 'Sesión iniciada');
              }
            },
            child: TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventLogOut(),
                    );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cerrar sesión'),
            ),
          ),
          const SizedBox(height: 32),
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
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}
