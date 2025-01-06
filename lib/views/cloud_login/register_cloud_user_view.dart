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
    return CenteredView(
      children: [
        Text(
          '¡Hola!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 21),
        Text(
            'Ingresa tu nombre y apellido para que tus vecinos te reconozcan.'),
        const SizedBox(height: 34),
        TextField(
            autofocus: true,
            controller: displayNameController,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Nombre y Apellido')),
        const SizedBox(height: 55),
        FilledButton(
            onPressed: () async =>
                context.read<AppBloc>().add(AppEventCreateCloudUser(
                      displayName: displayNameController.text,
                    )),
            child: const Text('Continuar'))
      ],
    );
  }
}
