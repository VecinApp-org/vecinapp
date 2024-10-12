import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
//import 'dart:developer' as devtools show log;

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  final double primarySpacing = 64;
  final double secondarySpacing = 32;
  final double tertiarySpacing = 8;
  final double maxWidth = 360;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: maxWidth,
              child: const Text('Verifica tu correo',
                  style: TextStyle(fontSize: 28), textAlign: TextAlign.center),
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
    );
  }
}
