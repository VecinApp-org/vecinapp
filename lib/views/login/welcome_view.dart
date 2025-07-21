import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';
import 'package:vecinapp/views/login/login_view.dart';
import 'package:vecinapp/views/login/register_view.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CenteredView(children: [
      Text(
        'VecinApp',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 55),
      FilledButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const RegisterView(),
            ));
          },
          child: const Text('Crear cuenta nueva')),
      const SizedBox(height: 13),
      OutlinedButton(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const LoginView())),
          child: const Text('Ya tengo una cuenta')),
      TextButton(
        onPressed: () {},
        child: Text('Aviso de privacidad'),
      )
    ]);
  }
}
