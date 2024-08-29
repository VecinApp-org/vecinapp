import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/services/auth/bloc/auth_state.dart';

import '../../services/settings/settings_controller.dart';

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
            listener: (context, state) {},
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
          //const SizedBox(height: 32),
          // TextButton(
          //   onPressed: () {},
          //   style: TextButton.styleFrom(
          //     foregroundColor: Colors.red,
          //   ),
          //   child: const Text('Eliminar cuenta'),
          // ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}
