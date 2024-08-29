import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/bloc/auth_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/services/auth/bloc/auth_state.dart';
import 'package:vecinapp/utilities/loading_dialog.dart';
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
  CloseDialog? _closeLoadingDialogHadler;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeLoadingDialogHadler;
          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeLoadingDialogHadler = null;
          } else if (state.isLoading && closeDialog == null) {
            _closeLoadingDialogHadler = showLoadingDialog(
              context: context,
              text: 'Cargando...',
            );
          }

          if (state.exception is InvalidCredentialAuthException) {
            await showErrorDialog(context,
                'La combinación de correo y contraseña es incorrecta.');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'El correo está mal escrito.');
          } else if (state.exception is NetworkRequestFailedAuthException) {
            await showErrorDialog(context, 'No hay internet.');
          } else if (state.exception is ChannelErrorAuthException) {
            await showErrorDialog(context, 'Dejaste algo vacío.');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Algo salió mal');
          } else if (state.exception != null) {
            await showErrorDialog(context, 'Algo salió mal');
          }
        }
      },
      child: Scaffold(
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
              const SizedBox(
                height: 55,
              ),
              SizedBox(
                width: 377,
                child: Column(
                  children: [
                    //Email Field
                    TextField(
                      autofocus: true,
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email),
                        hintText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 13),
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
              const SizedBox(height: 55),

              //Buttons
              Column(
                children: [
                  //Login button
                  FilledButton(
                    onPressed: () async {
                      devtools.log('Logging in...');
                      final email = _email.text;
                      final password = _password.text;
                      context.read<AuthBloc>().add(
                            AuthEventLogInWithEmailAndPassword(
                              email,
                              password,
                            ),
                          );
                    },
                    child: const Text('Entrar a mi cuenta'),
                  ),
                  const SizedBox(height: 13),
                  //go to register button
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventShouldRegister(),
                          );
                    },
                    child: const Text('Crear una cuenta nueva'),
                  ),
                  const SizedBox(height: 13),
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
      ),
    );
  }
}
