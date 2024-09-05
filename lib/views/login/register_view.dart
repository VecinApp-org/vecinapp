import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/bloc/auth_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/services/auth/bloc/auth_state.dart';
import 'package:vecinapp/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, this.email});

  final String? email;

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
            showErrorDialog(
                context: context, text: 'La contraseña es muy débil');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            showErrorDialog(
                context: context, text: 'Ese correo ya tiene una cuenta');
          } else if (state.exception is NetworkRequestFailedAuthException) {
            showErrorDialog(context: context, text: 'No hay internet');
          } else if (state.exception is InvalidEmailAuthException) {
            showErrorDialog(
                context: context, text: 'El correo está mal escrito');
          } else if (state.exception is ChannelErrorAuthException) {
            showErrorDialog(context: context, text: 'Dejaste algo vacío');
          } else if (state.exception
              is PasswordConfirmationDoesNotMatchAuthException) {
            showErrorDialog(
                context: context, text: 'Las contraseñas no coinciden');
          } else if (state.exception is GenericAuthException) {
            showErrorDialog(
                context: context, text: 'Algo salió mal registrando la cuenta');
          }
        }
      },
      child: Scaffold(
        restorationId: 'registerView',
        appBar: AppBar(),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                //Title
                Text('VecinApp',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 55),
                //Email Field
                TextField(
                  autofocus: true,
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    constraints: BoxConstraints(maxWidth: 377),
                    hintText: 'Email',
                    icon: Icon(Icons.email),
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
                            return const Icon(Icons.visibility);
                          } else {
                            return const Icon(Icons.visibility_off);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                //confirm Password Field
                TextField(
                  controller: _password2,
                  obscureText: !_isShowingPassword2,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    constraints: const BoxConstraints(maxWidth: 377),
                    hintText: 'Confirmar contraseña',
                    icon: const Icon(Icons.key),
                    suffixIcon: IconButton(onPressed: () {
                      setState(() {
                        _isShowingPassword2 = !_isShowingPassword2;
                      });
                    }, icon: Builder(builder: (context) {
                      if (_isShowingPassword2) {
                        return const Icon(Icons.visibility);
                      } else {
                        return const Icon(Icons.visibility_off);
                      }
                    })),
                  ),
                ),
                const SizedBox(height: 55),
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
                OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  },
                  child: const Text('Ya tengo una cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
