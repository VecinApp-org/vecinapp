import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';

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
    return Scaffold(
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
                  context.read<AppBloc>().add(
                        AppEventRegisterWithEmailAndPassword(
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
                  context.read<AppBloc>().add(
                        const AppEventLogOut(),
                      );
                },
                child: const Text('Ya tengo una cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
