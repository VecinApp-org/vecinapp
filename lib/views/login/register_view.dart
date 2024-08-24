import 'package:flutter/material.dart';
import 'package:vecinapp/constants/routes.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 64,
            children: [
              //Title
              const Text(
                'Crear cuenta',
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
                        hintText: 'Correo',
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
                  //Register button
                  FilledButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      try {
                        await AuthService.firebase().createUser(
                          email: email,
                          password: password,
                        );
                        await AuthService.firebase().sendEmailVerification();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              appRootRouteName, (route) => false);
                        }
                      } on EmailAlreadyInUseAuthException {
                        if (context.mounted) {
                          await showErrorDialog(
                              context, 'Ese email ya tiene una cuenta.');
                        }
                      } on NetworkRequestFailedAuthException {
                        if (context.mounted) {
                          showErrorDialog(context, 'No hay internet.');
                        }
                      } on WeakPasswordAuthException {
                        if (context.mounted) {
                          await showErrorDialog(
                              context, 'La contraseña está muy debil.');
                        }
                      } on InvalidEmailAuthException {
                        if (context.mounted) {
                          await showErrorDialog(
                              context, 'El correo está mal escrito.');
                        }
                      } on ChannelErrorAuthException {
                        if (context.mounted) {
                          await showErrorDialog(context, 'Dejaste algo vacío.');
                        }
                      } on GenericAuthException {
                        if (context.mounted) {
                          await showErrorDialog(
                              context, 'Algo salió mal creando la cuenta.');
                        }
                      }
                    },
                    child: const Text('Crear cuenta'),
                  ),

                  //Go to login page
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                        loginRouteName,
                      );
                    },
                    child: const Text('Ya tengo una cuenta'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
