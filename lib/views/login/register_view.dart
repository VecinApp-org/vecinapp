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
  late final TextEditingController _password2;
  late bool _isShowingPassword = false;
  late bool _isShowingPassword2 = false;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _password2 = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _password2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      restorationId: 'registerView',
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
                        icon: Icon(Icons.email),
                      ),
                    ),
                    TextField(
                      controller: _password,
                      obscureText: !_isShowingPassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        icon: const Icon(Icons.key),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isShowingPassword = !_isShowingPassword;
                            });
                          },
                          icon: Builder(
                            builder: (context) {
                              if (_isShowingPassword) {
                                return const Icon(Icons.visibility_off);
                              } else {
                                return const Icon(Icons.visibility);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _password2,
                      obscureText: !_isShowingPassword2,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        icon: const Icon(Icons.key),
                        suffixIcon: IconButton(onPressed: () {
                          setState(() {
                            _isShowingPassword2 = !_isShowingPassword2;
                          });
                        }, icon: Builder(builder: (context) {
                          if (_isShowingPassword2) {
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
                          passwordConfirmation: _password2.text,
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
                      } on PasswordConfirmationDoesNotMatchAuthException {
                        if (context.mounted) {
                          await showErrorDialog(
                              context, 'Las contraseñas no coinciden.');
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
