import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/utilities/dialogs/show_error_dialog.dart';
import 'package:vecinapp/utilities/dialogs/show_notification_dialog.dart';
//import 'dart:developer' as devtools show log;

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  final double primarySpacing = 64;
  final double secondarySpacing = 32;
  final double tertiarySpacing = 8;
  final double maxWidth = 360;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        (context, state) {
          if (state is AppStateNeedsVerification) {
            switch (state.exception) {
              case TooManyRequestsAuthException():
                showErrorDialog(context: context, text: 'Esperate tantito');
              case NetworkRequestFailedAuthException():
                showErrorDialog(context: context, text: 'No hay internet');
              case UserNotLoggedInAuthException():
                context.read().add(const AppEventLogOut());
              case UserNotVerifiedAuthException():
                showNotificationDialog(
                  context: context,
                  title: 'Aún no has verificado tu correo',
                  content:
                      'Si no encuentras el correo, revisa tu carpeta de Spam. O vuelve a enviar el correo de verificación.\n Si no recibes el correo, puede ser que hayas escrito mal tu correo. En ese caso, puedes salir y volver a intentar crear tu cuenta.',
                );
              case GenericAuthException():
                showErrorDialog(context: context, text: 'Algo salió mal');
            }
          }
        };
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: maxWidth,
                child: const Text('Verifica tu correo',
                    style: TextStyle(fontSize: 28),
                    textAlign: TextAlign.center),
              ),
              SizedBox(height: tertiarySpacing),
              SizedBox(
                width: maxWidth,
                child: const Text(
                  'Haz clic en el link para continuar.',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: secondarySpacing),
              FilledButton(
                  onPressed: () {
                    context.read<AppBloc>().add(
                          const AppEventConfirmUserIsVerified(),
                        );
                  },
                  child: const Text('Continuar')),
              SizedBox(height: secondarySpacing),
              OutlinedButton(
                  onPressed: () {
                    context.read<AppBloc>().add(
                          const AppEventSendEmailVerification(),
                        );
                  },
                  child: const Text('Enviar otro correo')),
              SizedBox(height: tertiarySpacing),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  context.read<AppBloc>().add(
                        const AppEventLogOut(),
                      );
                },
                child: const Text('Salir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
