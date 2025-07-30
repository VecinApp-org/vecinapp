import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: child ??
          const SizedBox(
            height: 100,
          ),
    );
  }
}
