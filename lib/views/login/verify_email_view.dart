import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) => CenteredView(
        children: [
          Text('Verifica tu correo',
              style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: 1),
          Text('Haz clic en el link que te enviamos para continuar.',
              style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 55),
          FilledButton(
              onPressed: () => context
                  .read<AppBloc>()
                  .add(const AppEventConfirmUserIsVerified()),
              child: const Text('Continuar')),
          SizedBox(height: 55),
          TextButton(
              onPressed: () => context
                  .read<AppBloc>()
                  .add(const AppEventSendEmailVerification()),
              child: const Text('Enviar otro correo')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () =>
                context.read<AppBloc>().add(const AppEventLogOut()),
            child: const Text('Salir'),
          )
        ],
      );
}
