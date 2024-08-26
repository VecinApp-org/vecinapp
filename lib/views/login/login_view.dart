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
  late bool _isShowingPassword = false;

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
          children: [
            //Title
            const Text(
              'Iniciar sesión',
              style: TextStyle(fontSize: 28),
            ),
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  //Email Field
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.email),
                      hintText: 'Email',
                    ),
                  ),
                  //Password Field
                  TextField(
                    controller: _password,
                    obscureText: !_isShowingPassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.key),
                      hintText: 'Contraseña',
                      suffixIcon: IconButton(onPressed: () {
                        setState(() {
                          _isShowingPassword = !_isShowingPassword;
                        });
                      }, icon: Builder(builder: (context) {
                        if (_isShowingPassword) {
                          return const Icon(Icons.visibility_off);
                        } else {
                          return const Icon(Icons.visibility);
                        }
                      })),
                    ),
                  ),
                ],
              ),
            ),
            //Buttons
            Column(
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
