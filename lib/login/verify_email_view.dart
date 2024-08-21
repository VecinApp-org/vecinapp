import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:vecinapp/constants/routes.dart';

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
            //Title
            const Text(
              'Verifica tu correo',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(
              width: 300,
              child: Text(
                  textAlign: TextAlign.center,
                  'Te enviamos un correo. Haz clic en el enlace y regresa aquí para continuar.'),
            ),

            //Buttons
            Column(
              spacing: 16,
              children: [
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
                      devtools.log('Still not verified');
                    }
                  },
                  child: const Text('Continuar'),
                ),
                /*
                OutlinedButton(
                  onPressed: () async {
                    switch (isEmailSent) {
                      case true:
                        devtools.log('Email already sent');
                      case false:
                        final user = FirebaseAuth.instance.currentUser;
                        await user?.sendEmailVerification();
                        isEmailSent = true;
                        devtools.log('Email sent');
                        setState(() {});
                        Future.delayed(
                          const Duration(minutes: 5),
                          () {
                            devtools
                                .log('Email verification button reactivated');
                            isEmailSent = false;
                            setState(() {});
                          },
                        );
                    }
                  },
                  child: const Text('Enviar otro correo'),
                ),
                
                const TextButton(
                  onPressed: null, //TODO implement logout with warning dialog
                  child: Text('Salir'),
                )
                */
              ],
            ),
          ],
        ),
      ),
    );
  }
}
