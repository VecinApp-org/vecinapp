import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/utilities/dialogs/show_confirmation_dialog.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/settings/settings_controller.dart';
import 'package:vecinapp/views/delete_account_view.dart';

class SettingsView extends HookWidget {
  SettingsView({super.key});

  final SettingsController controller = SettingsController();

  @override
  Widget build(BuildContext context) {
    useListenable(controller);
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state.user == null) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            PopupMenuButton(itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'Cerrar sesión',
                  onTap: () async {
                    final confirmLogout = await showConfirmationDialog(
                      context: context,
                      text: '¿Quieres salir de tu cuenta?',
                    );
                    if (confirmLogout == true && context.mounted) {
                      context.read<AppBloc>().add(
                            const AppEventLogOut(),
                          );
                    }
                  },
                  child: Text('Cerrar sesión'),
                ),
                PopupMenuItem(
                  value: 'Eliminar cuenta',
                  onTap: () async {
                    final confirmDeleteAccout = await showConfirmationDialog(
                      context: context,
                      isDestructive: true,
                      title: 'Eliminar cuenta',
                      text: 'Esta acción es irreversible.',
                      confirmText: 'Eliminar todos mis datos',
                    );
                    if (confirmDeleteAccout == true && context.mounted) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DeleteAccountView(),
                      ));
                    }
                  },
                  child: Text('Eliminar cuenta'),
                ),
              ];
            })
          ],
        ),
        body: ListView(
          children: [
            ListTile(
              title: const Text('Tema'),
              trailing: SegmentedButton(
                onSelectionChanged: (selection) =>
                    controller.updateThemeMode(selection.first),
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.phone_android),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                  ),
                ],
                selected: <ThemeMode>{controller.themeMode},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
