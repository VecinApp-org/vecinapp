import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/dialogs/show_pic_edit_options_dialog.dart';
import 'package:vecinapp/utilities/dialogs/single_text_input_dialog.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.cloudUser});
  final CloudUser cloudUser;
  @override
  Widget build(BuildContext context) {
    String displayName = cloudUser.displayName;
    String username = cloudUser.username;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<AppBloc>().add(const AppEventGoToNeighborhoodView());
          },
        ),
        actions: [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(3.0),
        children: [
          const SizedBox(height: 32),
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
          const SizedBox(height: 34),
          GestureDetector(
            child: Text(displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            onTap: () async {
              final newUserDisplayName = await showTextInputDialog(
                context: context,
                initialValue: displayName,
                title: 'Cambiar nombre',
                labelText: 'Nombre y Apellido(s)',
              );
              if (newUserDisplayName != null && context.mounted) {
                context.read<AppBloc>().add(AppEventUpdateUserDisplayName(
                    displayName: newUserDisplayName));
              }
            },
          ),
          const SizedBox(height: 8),
          GestureDetector(
            child: Text(
              '@$username',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(height: 34),
          HouseholdListTile(
            householdId: cloudUser.householdId,
          ),
          ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                context.read<AppBloc>().add(const AppEventGoToSettingsView());
              }),
        ],
      ),
    );
  }
}

class HouseholdListTile extends HookWidget {
  const HouseholdListTile({super.key, required this.householdId});
  final String? householdId;
  @override
  Widget build(BuildContext context) {
    final householdFuture = useMemoized(
        () => context.watch<AppBloc>().currentHousehold(householdId));
    final snapshot = useFuture(householdFuture);
    final household = snapshot.data;
    String addressline;
    if (household == null) {
      addressline = '';
    } else {
      addressline = '${household.street} #${household.number}';
    }
    return ListTile(
        leading: Icon(Icons.home),
        title: Text(addressline),
        trailing: Icon(Icons.arrow_right),
        onTap: () {
          if (household == null) {
            return;
          }
          context
              .read<AppBloc>()
              .add(AppEventGoToHouseholdView(household: household));
        });
  }
}
