import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

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
                          devtools.log('Pushing home');
                          Navigator.of(context).popAndPushNamed('/');
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'email-already-in-use') {
                          devtools.log('Ya existe una cuenta con este correo');
                        } else if (e.code == 'network-request-failed') {
                          devtools.log('No hay conexión a internet');
                        } else if (e.code == 'weak-password') {
                          devtools.log('La contraseña es muy debil');
                        } else if (e.code == 'invalid-email') {
                          devtools.log('Email inválido');
                        } else {
                          devtools.log(e.code);
                        }
                      } catch (e) {
                        devtools.log(
                            'Error Generico tipo ${e.runtimeType.toString()} ----> ${e.toString()}');
                      }
                    },
                    child: const Text('Crear cuenta'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
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
