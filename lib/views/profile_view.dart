import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/dialogs/show_pic_edit_options_dialog.dart';
import 'package:vecinapp/utilities/dialogs/single_text_input_dialog.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';

class ProfileView extends StatelessWidget {
  const ProfileView(
      {super.key, required this.cloudUser, required this.household});
  final CloudUser cloudUser;
  final Household? household;
  @override
  Widget build(BuildContext context) {
    final String displayName = cloudUser.displayName;
    late final String householdName;
    if (household == null) {
      householdName = 'Sin Casa';
    } else {
      householdName = '${household?.street} #${household?.number}';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: BackButton(
          onPressed: () {
            context.read<AppBloc>().add(const AppEventGoToNeighborhoodView());
          },
        ),
        actions: [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        shrinkWrap: true,
        children: [
          Center(
            child: GestureDetector(
              child: ProfilePicture(
                id: cloudUser.id,
                radius: 60.0,
              ),
              onTap: () async {
                final option =
                    await showPicEditOptionsDialog(context: context, text: '');
                if (option == null) {
                  return;
                }
                if (option == 'eliminar' && context.mounted) {
                  context
                      .read<AppBloc>()
                      .add(const AppEventDeleteProfilePhoto());
                  return;
                }
                if (option == 'cambiar') {
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image == null) {
                    return;
                  }
                  if (context.mounted) {
                    context.read<AppBloc>().add(
                          AppEventUpdateProfilePhoto(
                            imagePath: image.path,
                          ),
                        );
                  }
                  return;
                }
              },
            ),
          ),
          const SizedBox(height: 21),
          GestureDetector(
            child: Text(displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            onTap: () async {
              final newUserDisplayName = await showTextInputDialog(
                context: context,
                initialValue: displayName,
                title: 'Cambiar nombre',
                text:
                    'Para evitar robos de identidad, el tiene efecto en 3 días y los administradores pueden revisarlo.',
                labelText: 'Nombre y Apellido(s)',
              );
              if (newUserDisplayName != null && context.mounted) {
                context.read<AppBloc>().add(AppEventUpdateUserDisplayName(
                    displayName: newUserDisplayName));
              }
            },
          ),
          const SizedBox(height: 34),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(householdName),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              if (household == null) {
                return;
              }
              context
                  .read<AppBloc>()
                  .add(AppEventGoToHouseholdView(household: household!));
            },
          ),
          ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                if (household == null) {
                  return;
                }
                context.read<AppBloc>().add(AppEventGoToSettingsView());
              }),
        ],
      ),
    );
  }
}
