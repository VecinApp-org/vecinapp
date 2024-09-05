import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/bloc/auth_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/services/auth/bloc/auth_state.dart';
import 'package:vecinapp/utilities/show_error_dialog.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key, this.email});

  final String? email;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is InvalidCredentialAuthException) {
            await showErrorDialog(
                context: context,
                text: 'La combinación de correo y contraseña es incorrecta.');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
                context: context, text: 'El correo está mal escrito.');
          } else if (state.exception is NetworkRequestFailedAuthException) {
            await showErrorDialog(context: context, text: 'No hay internet.');
          } else if (state.exception is ChannelErrorAuthException) {
            await showErrorDialog(
                context: context, text: 'Dejaste algo vacío.');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context: context, text: 'Algo salió mal');
          } else if (state.exception != null) {
            await showErrorDialog(context: context, text: 'Algo salió mal');
          }
        }
      },
      child: Scaffold(
        restorationId: 'loginView',
        appBar: AppBar(),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                //Logo
                Text('VecinApp',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 55),
                //Title
                //Text('Iniciar sesión',
                //    style: Theme.of(context).textTheme.headlineMedium),
                //const SizedBox(height: 13),
                //Email Field
                TextField(
                  autofocus: true,
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    constraints: BoxConstraints(maxWidth: 377),
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
                    constraints: const BoxConstraints(maxWidth: 377),
                    icon: const Icon(Icons.key),
                    hintText: 'Contraseña',
                    suffixIcon: IconButton(onPressed: () {
                      setState(() {
                        _isShowingPassword = !_isShowingPassword;
                      });
                    }, icon: Builder(builder: (context) {
                      if (_isShowingPassword) {
                        return const Icon(Icons.visibility);
                      } else {
                        return const Icon(Icons.visibility_off);
                      }
                    })),
                  ),
                ),
                const SizedBox(height: 55),
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
                  child: const Text('Entrar'),
                ),
                const SizedBox(height: 13),
                //go to register button
                OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventShouldRegister(),
                        );
                  },
                  child: const Text('Aún no tengo cuenta'),
                ),
                const SizedBox(height: 13),
                //Forgot password button
                TextButton(
                  onPressed: () {
                    final email = _email.text;
                    context
                        .read<AuthBloc>()
                        .add(AuthEventForgotPassword(email: email));
                  },
                  child: const Text('Olvidé mi contraseña'),
                ),
                //const SizedBox(height: 55),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
