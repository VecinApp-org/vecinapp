import 'package:flutter/material.dart';
import 'package:vecinapp/constants/routes.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/utilities/show_error_dialog.dart';
//import 'dart:developer' as devtools show log;

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verifica tu correo',
              style: TextStyle(fontSize: 28),
            ),
            Column(
              children: [
                const SizedBox(
                  width: 300,
                  child: Text(
                      //textAlign: TextAlign.center,
                      'Te enviamos un correo. Haz clic en el enlace y regresa aquí para continuar.'),
                ),
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
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  width: 300,
                  child: Text(
                      //textAlign: TextAlign.center,
                      'Si no recibiste el correo, puedes enviarlo otra vez.'),
                ),
                // Resend email button
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
                          showErrorDialog(context,
                              'Demasiados intentos. Intentalo mas tarde.');
                        }
                      } on GenericAuthException {
                        if (context.mounted) {
                          showErrorDialog(context, 'Algo salio mal.');
                        }
                      }
                    },
                    child: const Text('Enviar otro correo')),
              ],
            ),
            Column(
              children: [
                const SizedBox(
                  width: 300,
                  child: Text(
                      'Si quieres usar otro correo, puedes cerrar la sesión.'),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () async {
                    await AuthService.firebase().logOut();
                    if (context.mounted) {
                      Navigator.of(context).popAndPushNamed(
                        appRootRouteName,
                      );
                    }
                  },
                  child: const Text('Salir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
