import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  late final TextEditingController _code;

  @override
  void initState() {
    _code = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Verifica tu correo'),
            FilledButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
              },
              child: const Text('Enviar correo de verificación'),
            ),
            FilledButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.reload();
                if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
                  if (context.mounted) {
                    Navigator.of(context).popAndPushNamed('/');
                  }
                } else {
                  devtools.log('Still not verified');
                }
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
