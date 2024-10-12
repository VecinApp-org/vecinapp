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
                  const AppEventGoToSettingsView(),
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
                Text('Eliminar cuenta',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 55),
                //email textfield
                TextField(
                  controller: _controller,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    constraints: BoxConstraints(maxWidth: 377),
                    icon: Icon(Icons.password),
                    hintText: 'Contraseña',
                  ),
                ),
                const SizedBox(height: 55),
                //Reset password button
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
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
                //cancel button
                TextButton(
                  onPressed: () {
                    context.read<AppBloc>().add(const AppEventLogOut());
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
