import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';

class DeleteAccountView extends StatefulWidget {
  const DeleteAccountView({super.key});

  @override
  State<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<DeleteAccountView> {
  late final TextEditingController _controller;
  late bool _isShowingPassword = false;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<AppBloc>().add(
                  const AppEventReset(),
                );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                //Title
                Text('Confirma tu contraseña',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 55),
                //email textfield
                TextField(
                  controller: _controller,
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
                      }, icon: Builder(
                        builder: (context) {
                          if (_isShowingPassword) {
                            return const Icon(Icons.visibility);
                          } else {
                            return const Icon(Icons.visibility_off);
                          }
                        },
                      ))),
                ),
                const SizedBox(height: 55),
                FilledButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.errorContainer),
                  ),
                  onPressed: () {
                    final password = _controller.text;
                    context.read<AppBloc>().add(AppEventDeleteAccount(
                          password: password,
                        ));
                  },
                  child: const Text('Eliminar cuenta'),
                ),
                const SizedBox(height: 13),
                TextButton(
                  onPressed: () {
                    context.read<AppBloc>().add(
                          const AppEventReset(),
                        );
                  },
                  child: const Text('Regresar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
