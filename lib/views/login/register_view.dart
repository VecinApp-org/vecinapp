import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

import 'package:vecinapp/constants/routes.dart';
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
                        devtools.log('Registrando usuario...');
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        devtools.log('Usuario registrado');
                        devtools.log('Enviando email de verificación...');
                        await FirebaseAuth.instance.currentUser
                            ?.sendEmailVerification();
                        devtools.log('Email enviado');
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              appRootRouteName, (route) => false);
                        }
                      } on FirebaseAuthException catch (e) {
                        switch (e.code) {
                          case 'email-already-in-use':
                            if (context.mounted) {
                              await showErrorDialog(
                                context,
                                'Ese email ya tiene una cuenta.',
                              );
                            }
                          case 'network-request-failed':
                            if (context.mounted) {
                              showErrorDialog(
                                context,
                                'No hay internet.',
                              );
                            }
                          case 'weak-password':
                            if (context.mounted) {
                              showErrorDialog(
                                context,
                                'La contraseña está muy débil.',
                              );
                            }
                          case 'invalid-email':
                            if (context.mounted) {
                              showErrorDialog(
                                context,
                                'El correo está mal escrito.',
                              );
                            }
                          case 'channel-error':
                            if (context.mounted) {
                              showErrorDialog(
                                context,
                                'Dejaste algo vacío.',
                              );
                            }
                          default:
                            if (context.mounted) {
                              showErrorDialog(
                                context,
                                'Algo salió mal creando tu cuenta.',
                              );
                            }
                        }
                      } catch (e) {
                        devtools.log(
                            'Error Generico tipo: ${e.runtimeType.toString()} Error: ${e.toString()}');
                        if (context.mounted) {
                          showErrorDialog(
                            context,
                            'Algo salió mal.',
                          );
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
