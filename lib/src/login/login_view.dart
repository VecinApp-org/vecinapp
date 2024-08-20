import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

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
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            const Text(
              'Iniciar sesión',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(
              height: 32,
            ),
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
            const SizedBox(
              height: 32,
            ),
            FilledButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    final userCredentail =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    devtools.log('Login exitoso $userCredentail');
                    if (context.mounted) {
                      devtools.log('navegando a home');
                      Navigator.of(context).popAndPushNamed('/');
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'invalid-email') {
                      devtools.log('Email invalido');
                    } else if (e.code == 'invalid-credential') {
                      devtools.log('Credenciales no validas');
                    } else if (e.code == 'network-request-failed') {
                      devtools.log('Error de red');
                    } else {
                      devtools.log(
                          'Error de FirebaseAuthException desconocido ${e.code}');
                    }
                  } catch (e) {
                    devtools.log(
                        'Error desconocido tipo ${e.runtimeType} error: $e');
                  }
                },
                child: const Text('Iniciar sesión')),
            const TextButton(
              onPressed: null,
              child: Text('Olvidé mi contraseña'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/register');
                },
                child: const Text('¿No tienes cuenta? Regístrate')),
          ],
        ),
      ),
    );
  }
}
