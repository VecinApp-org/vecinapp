import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';

class RegisterCloudUserView extends StatefulWidget {
  const RegisterCloudUserView({super.key});

  @override
  State<RegisterCloudUserView> createState() => _RegisterCloudUserViewState();
}

class _RegisterCloudUserViewState extends State<RegisterCloudUserView> {
  late final TextEditingController _displayNameController;

  @override
  void initState() {
    _displayNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Registra tus datos',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 55),
            TextField(
              autofocus: true,
              controller: _displayNameController,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 377),
                hintText: 'Nombre',
                icon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 55),
            //Register button
            FilledButton(
              onPressed: () async {
                final name = _displayNameController.text;
                context.read<AppBloc>().add(
                      AppEventCreateCloudUser(displayName: name),
                    );
              },
              child: const Text('Crear cuenta'),
            ),
          ],
        )),
      ),
    );
  }
}
