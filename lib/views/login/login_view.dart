import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';

class LoginView extends HookWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isShowingPassword = useState(false);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            onPressed: () =>
                context.read<AppBloc>().add(const AppEventGoToWelcomeView())),
      ),
      body: CenteredView(
        children: [
          Text('Entrar a cuenta',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 55),
          TextField(
              autofocus: true,
              controller: emailController,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  icon: Icon(Icons.email), labelText: 'Email')),
          TextField(
              controller: passwordController,
              obscureText: !isShowingPassword.value,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                  icon: const Icon(Icons.key),
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                      onPressed: () =>
                          isShowingPassword.value = !isShowingPassword.value,
                      icon: Builder(
                          builder: (context) => isShowingPassword.value
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off))))),
          const SizedBox(height: 55),
          FilledButton(
              onPressed: () async =>
                  context.read<AppBloc>().add(AppEventLogInWithEmailAndPassword(
                        emailController.text,
                        passwordController.text,
                      )),
              child: const Text('Entrar')),
          const SizedBox(height: 55),
          TextButton(
              onPressed: () =>
                  context.read<AppBloc>().add(AppEventGoToForgotPassword(
                        email: emailController.text,
                      )),
              child: const Text('Olvidé mi contraseña')),
          TextButton(
              onPressed: () =>
                  context.read<AppBloc>().add(const AppEventGoToRegistration()),
              child: const Text('Crear cuenta nueva'))
        ],
      ),
    );
  }
}
