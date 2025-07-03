import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/dialogs/show_pic_edit_options_dialog.dart';
import 'package:vecinapp/utilities/dialogs/single_text_input_dialog.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';

class ProfileView extends HookWidget {
  const ProfileView(
      {super.key,
      required this.cloudUser,
      required this.neighborhood,
      required this.household});
  final CloudUser cloudUser;
  final Neighborhood? neighborhood;
  final Household? household;

  @override
  Widget build(BuildContext context) {
    final String displayName = cloudUser.displayName;
    late final String householdName;
    if (household == null) {
      householdName = 'Sin Casa';
    } else {
      householdName = '${household!.street} #${household!.number}';
    }

    late final String neighborhoodName;
    if (neighborhood == null) {
      neighborhoodName = 'Sin Barrio';
    } else {
      neighborhoodName = '${neighborhood!.neighborhoodName} ';
    }
    final bool isloading = context.watch<AppBloc>().state.isLoading;
    final Stream<Uint8List?> profilePicture = useMemoized(
        () => context.watch<AppBloc>().profilePicture(userId: cloudUser.id),
        [isloading]);

    final image = useStream(profilePicture).data;

    return Scaffold(
      appBar: AppBar(
        leading: (neighborhood == null)
            ? BackButton(
                onPressed: () => context
                    .read<AppBloc>()
                    .add(const AppEventGoToNoNeighborhoodView()),
              )
            : null,
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.edit),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'imagen',
                    onTap: () => {
                      if (image == null)
                        {updatePicture(context: context)}
                      else
                        {editOrDeleteProfilePicture(context: context)}
                    },
                    child: (image == null)
                        ? const Text('Agregar foto de perfil')
                        : const Text('Editar foto de perfil'),
                  ),
                  PopupMenuItem(
                    value: 'nombre',
                    onTap: () =>
                        changeName(context: context, displayName: displayName),
                    child: Text('Cambiar nombre'),
                  )
                ];
              }),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        shrinkWrap: true,
        children: [
          Center(
            child: ProfilePicture(
              image: image,
              radius: 60.0,
            ),
          ),
          const SizedBox(height: 21),
          Text(displayName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 34),
          Visibility(
            visible: household != null,
            child: ListTile(
              leading: const Icon(Icons.home),
              title: Text(householdName),
              trailing: const Icon(Icons.arrow_right),
              onTap: () {
                if (household == null) {
                  return;
                } else {
                  context
                      .read<AppBloc>()
                      .add(AppEventGoToHouseholdView(household: household!));
                }
              },
            ),
          ),
          Visibility(
            visible: neighborhood != null,
            child: ListTile(
                leading: const Icon(Icons.group),
                title: Text(neighborhoodName),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {
                  if (neighborhood == null) {
                    return;
                  } else {
                    context.read<AppBloc>().add(
                        AppEventGoToNeighborhoodDetailsView(
                            neighborhood: neighborhood!));
                  }
                }),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              context.read<AppBloc>().add(AppEventGoToSettingsView());
            },
          ),
        ],
      ),
    );
  }
}

void editOrDeleteProfilePicture({required BuildContext context}) async {
  // show options
  final option = await showPicEditOptionsDialog(context: context, text: '');
  if (option == null) {
    return;
  }
  // delete photo
  if (option == 'eliminar' && context.mounted) {
    deletePicture(context: context);
    return;
  }
  // change photo
  if (option == 'cambiar' && context.mounted) {
    updatePicture(context: context);
  }
}

void updatePicture({required BuildContext context}) async {
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

void deletePicture({required BuildContext context}) {
  context.read<AppBloc>().add(const AppEventDeleteProfilePhoto());
}

void changeName(
    {required BuildContext context, required String displayName}) async {
  final newUserDisplayName = await showTextInputDialog(
    context: context,
    initialValue: displayName,
    title: 'Cambiar nombre',
    text:
        'Para evitar robos de identidad, el tiene efecto en 3 días y los administradores pueden revisarlo.',
    labelText: 'Nombre y Apellido(s)',
  );
  if (newUserDisplayName != null && context.mounted) {
    context
        .read<AppBloc>()
        .add(AppEventUpdateUserDisplayName(displayName: newUserDisplayName));
  }
}
