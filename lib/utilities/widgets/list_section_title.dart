import 'package:flutter/material.dart';

class ListSectionTitle extends StatelessWidget {
  const ListSectionTitle({super.key, this.visible = true, required this.text});

  final bool visible;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
