import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/bloc/auth_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/services/auth/bloc/auth_state.dart';
import 'package:vecinapp/utilities/show_error_dialog.dart';
//import 'dart:developer' as devtools show log;

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  final double primarySpacing = 64;
  final double secondarySpacing = 32;
  final double tertiarySpacing = 8;
  final double maxWidth = 360;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        (context, state) {
          if (state is AuthStateNeedsVerification) {
            switch (state.exception) {
              case TooManyRequestsAuthException():
                showErrorDialog(context, 'Esperate tantito');
              case NetworkRequestFailedAuthException():
                showErrorDialog(context, 'Error de red');
              case UserNotLoggedInAuthException():
                context.read().add(const AuthEventLogOut());
              case UserNotVerifiedAuthException():
                showErrorDialog(context, 'Aún no has verificado tu correo.');
              case GenericAuthException():
                showErrorDialog(context, 'Algo salió mal');
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
                    context.read<AuthBloc>().add(
                          const AuthEventConfirmUserIsVerified(),
                        );
                  },
                  child: const Text('Continuar')),
              SizedBox(height: secondarySpacing),
              OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventSendEmailVerification(),
                        );
                  },
                  child: const Text('Enviar otro correo')),
              SizedBox(height: tertiarySpacing),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
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
