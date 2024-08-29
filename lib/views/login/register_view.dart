import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/bloc/auth_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/services/auth/bloc/auth_state.dart';
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            showErrorDialog(context, 'La contraseña es muy débil');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            showErrorDialog(context, 'Ese correo ya tiene una cuenta');
          } else if (state.exception is NetworkRequestFailedAuthException) {
            showErrorDialog(context, 'No hay internet');
          } else if (state.exception is InvalidEmailAuthException) {
            showErrorDialog(context, 'El correo está mal escrito');
          } else if (state.exception is ChannelErrorAuthException) {
            showErrorDialog(context, 'Dejaste algo vacío');
          } else if (state.exception
              is PasswordConfirmationDoesNotMatchAuthException) {
            showErrorDialog(context, 'Las contraseñas no coinciden');
          } else if (state.exception is GenericAuthException) {
            showErrorDialog(context, 'Algo salió mal registrando la cuenta');
          }
        }
      },
      child: Scaffold(
        restorationId: 'registerView',
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Title
              const Text(
                'Crear cuenta',
                style: TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 55),
              //Email and password fields
              SizedBox(
                width: 377,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Correo',
                        icon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 13),
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
                    const SizedBox(height: 13),
                    TextField(
                      controller: _password2,
                      obscureText: !_isShowingPassword2,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'Confirmar contraseña',
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

              const SizedBox(height: 55),

              //Buttons
              Column(
                children: [
                  //Register button
                  FilledButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      final password2 = _password2.text;
                      context.read<AuthBloc>().add(
                            AuthEventRegisterWithEmailAndPassword(
                              email,
                              password,
                              password2,
                            ),
                          );
                    },
                    child: const Text('Crear cuenta'),
                  ),

                  const SizedBox(height: 13),
                  //Go to login page
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
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
