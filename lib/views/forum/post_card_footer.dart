import 'package:flutter/material.dart';

class PostCardFooter extends StatelessWidget {
  const PostCardFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chat_bubble_outline),
        ),
        Text('#', style: Theme.of(context).textTheme.bodySmall),
        IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        Text('#', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
