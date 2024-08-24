import 'package:flutter/material.dart';
import 'package:vecinapp/constants/routes.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
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
                      final userCredentail = await AuthService.firebase()
                          .logIn(email: email, password: password);
                      devtools.log('Logged in: $userCredentail');
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            appRootRouteName, (route) => false);
                      }
                    } on InvalidEmailAuthException {
                      if (context.mounted) {
                        showErrorDialog(context, 'El correo está mal escrito.');
                      }
                    } on NetworkRequestFailedAuthException {
                      if (context.mounted) {
                        showErrorDialog(context, 'No hay internet.');
                      }
                    } on ChannelErrorAuthException {
                      if (context.mounted) {
                        showErrorDialog(context, 'Dejaste algo vacío.');
                      }
                    } on InvalidCredentialAuthException {
                      if (context.mounted) {
                        showErrorDialog(context,
                            'La contraseña es incorrecta o ese correo no existe.');
                      }
                    } on GenericAuthException catch (e) {
                      devtools
                          .log('Error logging in: ${e.runtimeType} Error: $e');
                      if (context.mounted) {
                        showErrorDialog(
                            context, 'Algo salió mal iniciando sesión.');
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
