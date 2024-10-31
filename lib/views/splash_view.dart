import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'SplashView',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}