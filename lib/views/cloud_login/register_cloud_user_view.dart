import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';

class RegisterCloudUserView extends HookWidget {
  const RegisterCloudUserView({super.key});

  @override
  Widget build(BuildContext context) {
    final displayNameController = useTextEditingController();
    final usernameController = useTextEditingController();
    return CenteredView(
      children: [
        Text('Registra tus datos',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 55),
        TextField(
            autofocus: true,
            controller: displayNameController,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Nombre')),
        TextField(
            autofocus: true,
            controller: usernameController,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration:
                const InputDecoration(labelText: 'Nombre de ususario único')),
        const SizedBox(height: 55),
        FilledButton(
            onPressed: () async => context.read<AppBloc>().add(
                AppEventCreateCloudUser(
                    displayName: displayNameController.text,
                    username: usernameController.text)),
            child: const Text('Crear cuenta'))
      ],
    );
  }
}
