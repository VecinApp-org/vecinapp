import 'package:flutter/material.dart';
import 'package:vecinapp/constants/routes.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          spacing: 64,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Title
            const Column(
              spacing: 8,
              children: [
                Text(
                  'VecinApp',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Encuentra a tus vecinos'),
              ],
            ),

            //Buttons
            Row(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      registerRouteName,
                    );
                  },
                  child: const Text('Crear cuenta'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      loginRouteName,
                    );
                  },
                  child: const Text('Ya tengo cuenta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
