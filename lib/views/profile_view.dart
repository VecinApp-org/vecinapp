import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/utilities/dialogs/single_text_input_dialog.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<AppBloc>().add(const AppEventGoToNeighborhoodView());
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AppBloc>().add(const AppEventDeleteProfilePhoto());
            },
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          String? phoneNumber = state.user!.phoneNumber;
          if (phoneNumber == null || phoneNumber.isEmpty) {
            phoneNumber = 'Sin Teléfono';
          }
          String displayName = state.cloudUser!.displayName;
          String? email = state.user!.email;
          if (email == null || email.isEmpty) {
            email = 'Sin Email';
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: () async {
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
                  },
                  child: ProfilePicture(
                    id: state.cloudUser!.id,
                    radius: 60.0,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 50),
                  Text(displayName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                  IconButton(
                    onPressed: () async {
                      final newUserDisplayName = await showTextInputDialog(
                        context: context,
                        initialValue: state.cloudUser!.displayName,
                        title: 'Cambiar nombre',
                        labelText: 'Nombre',
                      );
                      if (newUserDisplayName != null && context.mounted) {
                        context.read<AppBloc>().add(
                            AppEventUpdateUserDisplayName(
                                displayName: newUserDisplayName));
                      }
                    },
                    icon: const Icon(Icons.edit),
                  )
                ],
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.alternate_email),
                title: Text(email),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(phoneNumber),
              ),
              ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Mi Casa'),
                  trailing: Icon(Icons.arrow_right),
                  onTap: () {
                    context.read<AppBloc>().add(AppEventGoToHouseholdView(
                        householdId: state.cloudUser!.householdId!));
                  }),
              const Divider(),
              ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configuración'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    context
                        .read<AppBloc>()
                        .add(const AppEventGoToSettingsView());
                  }),
            ],
          );
        },
      ),
    );
  }
}
