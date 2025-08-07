import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/utilities/entities/comment_plus.dart';
import 'package:vecinapp/utilities/extensions/formatting/format_date_time.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';

class CommentListTile extends StatelessWidget {
  const CommentListTile(
      {super.key,
      required this.commentPlus,
      required this.onLiked,
      required this.onUnliked});

  final CommentPlus commentPlus;
  final VoidCallback? onLiked;
  final VoidCallback? onUnliked;

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AppBloc>().state.cloudUser!.id;
    final isLiked = commentPlus.comment.likes.contains(userId);
    final time = formatDateTime(commentPlus.comment.timestamp);
    return ListTile(
      leading: ProfilePicture(
        radius: 16,
        imageUrl: commentPlus.author.photoUrl,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(commentPlus.author.displayName),
          const SizedBox(width: 8),
          Text(
            time,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
      subtitle: Text(commentPlus.comment.text),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                if (isLiked) {
                  onUnliked!();
                } else {
                  onLiked!();
                }
              },
              icon: (isLiked)
                  ? Icon(Icons.favorite, color: Colors.red, size: 16)
                  : Icon(Icons.favorite_border, size: 16)),
          Text('${commentPlus.comment.likeCount}'),
        ],
      ),
      dense: true,
      visualDensity: VisualDensity(
          vertical: VisualDensity.minimumDensity,
          horizontal: VisualDensity.minimumDensity),
    );
  }
}
