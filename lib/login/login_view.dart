import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vecinapp/constants/routes.dart';
import 'dart:developer' as devtools show log;

import 'package:vecinapp/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      restorationId: 'loginView',
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 64,
          children: [
            //Title
            const Text(
              'Iniciar sesión',
              style: TextStyle(fontSize: 28),
            ),

            //Email and password fields
            SizedBox(
              width: 300,
              child: Column(
                spacing: 8,
                children: [
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                    ),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Contraseña',
                    ),
                  ),
                ],
              ),
            ),

            //Buttons
            Column(
              spacing: 8,
              children: [
                //Login button
                FilledButton(
                  onPressed: () async {
                    devtools.log('Logging in...');
                    final email = _email.text;
                    final password = _password.text;
                    try {
                      final userCredentail = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: email, password: password);
                      devtools.log('Logged in: $userCredentail');
                      FirebaseAuth.instance.currentUser?.reload();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            appRootRouteName, (route) => false);
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'invalid-email') {
                        if (context.mounted) {
                          showErrorDialog(
                            context,
                            'El correo está mal escrito.',
                          );
                        }
                      } else if (e.code == 'invalid-credential') {
                        if (context.mounted) {
                          showErrorDialog(
                            context,
                            'Algo está mal escrito o no existe esa cuenta.',
                          );
                        }
                      } else if (e.code == 'network-request-failed') {
                        if (context.mounted) {
                          showErrorDialog(
                            context,
                            'No hay internet.',
                          );
                        }
                      } else if (e.code == 'channel-error') {
                        if (context.mounted) {
                          showErrorDialog(
                            context,
                            'Dejaste algo vacío.',
                          );
                        }
                      } else {
                        devtools.log(e.toString());
                        if (context.mounted) {
                          showErrorDialog(
                            context,
                            'Algo salió mal iniciando sesión.',
                          );
                        }
                      }
                    } catch (e) {
                      devtools.log(
                          'Error desconocido tipo: ${e.runtimeType} Error: $e');
                      if (context.mounted) {
                        showErrorDialog(
                          context,
                          'Algo salió mal.',
                        );
                      }
                    }
                  },
                  child: const Text('Entrar a mi cuenta'),
                ),

                //go to register button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      registerRouteName,
                    );
                  },
                  child: const Text('Crear una cuenta nueva'),
                ),

                //Forgot password button
                const TextButton(
                  onPressed: null,
                  child: Text('Olvidé mi contraseña'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
