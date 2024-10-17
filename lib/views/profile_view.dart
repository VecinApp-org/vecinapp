import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/utilities/dialogs/single_text_input_dialog.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<AppBloc>().add(const AppEventGoToHomeView());
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image == null) {
                return;
              }
              if (context.mounted) {
                context.read<AppBloc>().add(
                      AppEventUpdateUserPhoto(
                        imagePath: image.path,
                      ),
                    );
              }
            },
            icon: const Icon(
              Icons.upload,
            ),
          ),
        ],
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          String? phoneNumber = state.user!.phoneNumber;
          if (phoneNumber == null || phoneNumber.isEmpty) {
            phoneNumber = 'Sin Teléfono';
          }
          String? displayName = state.user!.displayName;
          if (displayName == null || displayName.isEmpty) {
            displayName = 'Sin Nombre';
          }
          String? email = state.user!.email;
          if (email == null || email.isEmpty) {
            email = 'Sin Email';
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 32),
              Container(
                width: 120,
                height: 120,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: Image.network(
                  state.user?.photoUrl ?? '',
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/images/flutter_logo.png');
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator();
                  },
                ),
              ),
              const SizedBox(height: 32),
              InkWell(
                onTap: () async {
                  final newUserDisplayName = await showTextInputDialog(
                    context: context,
                    title: 'Cambiar nombre',
                    hintText: state.user!.displayName ?? 'Ingresa tu nombre',
                  );
                  if (newUserDisplayName != null && context.mounted) {
                    context.read<AppBloc>().add(AppEventUpdateUserDisplayName(
                        displayName: newUserDisplayName));
                  }
                },
                child: Text(displayName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall),
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
              const ListTile(
                leading: Icon(Icons.home),
                title: Text('Sin Dirección'),
              ),
              const Divider(),
              ListTile(
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
