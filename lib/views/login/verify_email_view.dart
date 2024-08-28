import 'package:flutter/material.dart';
import 'package:vecinapp/constants/routes.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/utilities/show_confirmation_dialog.dart';
import 'package:vecinapp/utilities/show_error_dialog.dart';
//import 'dart:developer' as devtools show log;

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  final double primarySpacing = 64;
  final double secondarySpacing = 32;
  final double tertiarySpacing = 16;
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
                onPressed: () async {
                  try {
                    await AuthService.firebase().reload();
                    final user = AuthService.firebase().currentUser;
                    if (user != null) {
                      if (user.isEmailVerified) {
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              appRootRouteName, (route) => false);
                        }
                      } else {
                        if (context.mounted) {
                          showErrorDialog(
                              context, 'Aún no has verificado tu correo');
                        }
                      }
                    }
                  } on NetworkRequestFailedAuthException {
                    if (context.mounted) {
                      showErrorDialog(context, 'No hay internet.');
                    }
                  } on GenericAuthException {
                    if (context.mounted) {
                      showErrorDialog(context, 'Algo salio mal.');
                    }
                  }
                },
                child: const Text('Continuar')),
            SizedBox(height: tertiarySpacing),
            OutlinedButton(
                onPressed: () async {
                  try {
                    await AuthService.firebase().sendEmailVerification();
                  } on NetworkRequestFailedAuthException {
                    if (context.mounted) {
                      showErrorDialog(context, 'No hay internet.');
                    }
                  } on TooManyRequestsAuthException {
                    if (context.mounted) {
                      showErrorDialog(
                          context, 'Demasiados intentos. Intentalo mas tarde.');
                    }
                  } on GenericAuthException {
                    if (context.mounted) {
                      showErrorDialog(context, 'Algo salio mal.');
                    }
                  }
                },
                child: const Text('Enviar otro correo')),
            SizedBox(height: tertiarySpacing),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                final confirmation = await showConfirmationDialog(
                  context,
                  '¿Seguro que quieres cerrar sesión?',
                );
                if (confirmation != null && confirmation) {
                  await AuthService.firebase().logOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      appRootRouteName,
                      (route) => false,
                    );
                  }
                }
              },
              child: const Text('Salir'),
            ),
          ],
        ),
      ),
    );
  }
}
