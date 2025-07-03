import 'package:flutter/material.dart';

class PostCardFooter extends StatelessWidget {
  const PostCardFooter(
      {super.key, required this.likesCount, required this.commentsCount});

  final int likesCount;
  final int commentsCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          Text('$commentsCount', style: Theme.of(context).textTheme.bodySmall),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
          Text('$likesCount', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
