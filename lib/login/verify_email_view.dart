import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:vecinapp/constants/routes.dart';
import 'package:vecinapp/utilities/show_error_dialog.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  bool isEmailSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          spacing: 64,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verifica tu correo',
              style: TextStyle(fontSize: 28),
            ),
            Column(
              spacing: 16,
              children: [
                const SizedBox(
                  width: 300,
                  child: Text(
                      //textAlign: TextAlign.center,
                      'Te enviamos un correo. Haz clic en el enlace y regresa aquí para continuar.'),
                ),
                FilledButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.currentUser?.reload();
                    if (FirebaseAuth.instance.currentUser?.emailVerified ==
                        true) {
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          appRootRouteName,
                          (route) => false,
                        );
                      }
                    } else {
                      if (context.mounted) {
                        showErrorDialog(
                          context,
                          'Todavía no has verificado el correo',
                        );
                      }
                    }
                  },
                  child: const Text('Continuar'),
                ),
              ],
            ),
            Column(
              spacing: 16,
              children: [
                const SizedBox(
                  width: 300,
                  child: Text(
                      //textAlign: TextAlign.center,
                      'Si no recibiste el correo, puedes enviarlo otra vez.'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    switch (isEmailSent) {
                      case true:
                        showErrorDialog(context,
                            'Espera un minuto para enviar otro correo');
                      case false:
                        final user = FirebaseAuth.instance.currentUser;
                        await user?.sendEmailVerification();
                        isEmailSent = true;
                        devtools.log('Email sent');
                        setState(() {});
                        Future.delayed(
                          const Duration(minutes: 1),
                          () {
                            devtools.log(
                              'Email verification button reactivated',
                            );
                            isEmailSent = false;
                            setState(() {});
                          },
                        );
                    }
                  },
                  child: const Text('Enviar otro correo'),
                ),
              ],
            ),
            Column(
              spacing: 16,
              children: [
                const SizedBox(
                  width: 300,
                  child: Text(
                      'Si quieres usar otro correo, puedes cerrar la sesión.'),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
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
