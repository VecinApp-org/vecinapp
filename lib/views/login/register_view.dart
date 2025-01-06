import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';

class RegisterView extends HookWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final passwordController2 = useTextEditingController();
    final isShowingPassword = useState(false);
    final isShowingPassword2 = useState(false);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            onPressed: () =>
                context.read<AppBloc>().add(const AppEventGoToWelcomeView())),
      ),
      body: CenteredView(
        children: [
          Text('Crear cuenta',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 55),
          TextField(
            autofocus: true,
            controller: emailController,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                labelText: 'Email', icon: Icon(Icons.email)),
          ),
          TextField(
            controller: passwordController,
            obscureText: !isShowingPassword.value,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
                labelText: 'Contraseña',
                icon: const Icon(Icons.key),
                suffixIcon: IconButton(
                    onPressed: () =>
                        isShowingPassword.value = !isShowingPassword.value,
                    icon: Builder(
                        builder: (context) => isShowingPassword.value
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off)))),
          ),
          TextField(
            controller: passwordController2,
            obscureText: !isShowingPassword2.value,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                icon: const Icon(Icons.key),
                suffixIcon: IconButton(
                    onPressed: () =>
                        isShowingPassword2.value = !isShowingPassword2.value,
                    icon: Builder(
                        builder: (context) => isShowingPassword.value
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off)))),
          ),
          const SizedBox(height: 55),
          //Register button
          FilledButton(
              onPressed: () async => context
                  .read<AppBloc>()
                  .add(AppEventRegisterWithEmailAndPassword(
                    emailController.text,
                    passwordController.text,
                    passwordController2.text,
                  )),
              child: const Text('Crear cuenta')),
          const SizedBox(height: 8),
          //Go to login page
          TextButton(
              onPressed: () =>
                  context.read<AppBloc>().add(const AppEventGoToLogin()),
              child: const Text('Ya tengo una cuenta'))
        ],
      ),
    );
  }
}
