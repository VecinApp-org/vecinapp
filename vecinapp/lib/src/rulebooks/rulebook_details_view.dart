import 'package:flutter/material.dart';

import 'rulebook.dart';

/// Displays detailed information about a SampleItem.
class RulebookDetailsView extends StatelessWidget {
  const RulebookDetailsView({super.key, required this.rulebook});

  final Rulebook rulebook;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details ${rulebook.id}'),
      ),
      body: const Center(
        child: Text('More Information Here'),
      ),
    );
  }
}
