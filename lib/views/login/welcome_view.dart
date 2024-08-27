import 'package:flutter/material.dart';
import 'package:vecinapp/constants/routes.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Title
            const Column(
              children: [
                Text(
                  'VecinApp',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 89),

            //Buttons
            Row(
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
                const SizedBox(width: 13),
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
