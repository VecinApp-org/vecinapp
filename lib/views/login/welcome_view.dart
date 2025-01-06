import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CenteredView(children: [
      Text(
        'VecinApp',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 55),
      FilledButton(
          onPressed: () =>
              context.read<AppBloc>().add(const AppEventGoToRegistration()),
          child: const Text('Crear cuenta nueva')),
      const SizedBox(height: 13),
      OutlinedButton(
          onPressed: () =>
              context.read<AppBloc>().add(const AppEventGoToLogin()),
          child: const Text('Ya tengo una cuenta')),
      TextButton(
        onPressed: () {},
        child: Text('Aviso de privacidad'),
      )
    ]);
  }
}
