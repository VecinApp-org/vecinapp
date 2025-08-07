import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/utilities/entities/comment_plus.dart';
import 'package:vecinapp/utilities/widgets/comment_list_tile.dart';

Future<void> showPostComments({
  required BuildContext context,
  required post,
  bool autofocus = false,
}) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: CommentListView(postId: post.id, autofocus: autofocus),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Comentar',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              minLines: 1,
              maxLines: 5,
              autofocus: autofocus,
              onSubmitted: (text) {
                context.read<AppBloc>().add(
                    AppEventCreatePostComment(postId: post.id, text: text));
              },
            ),
          ],
        ),
      );
    },
  );
}

class CommentListView extends HookWidget {
  const CommentListView(
      {super.key, required this.postId, this.autofocus = false});

  final String postId;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    useMemoized(() =>
        context.read<AppBloc>().add(AppEventFetchPostComments(postId: postId)));
    return BlocSelector<AppBloc, AppState, Iterable<CommentPlus>>(
      selector: (state) =>
          state.posts!.firstWhere((p) => p.post.id == postId).commentsPlus,
      builder: (context, state) => (state.isNotEmpty)
          ? ListView.builder(
              itemCount: state.length,
              itemBuilder: (context, index) {
                final commentPlus = state.elementAt(index);
                return CommentListTile(
                  commentPlus: commentPlus,
                  onLiked: () {
                    context.read<AppBloc>().add(
                          AppEventLikePostComment(
                            postId: postId,
                            commentId: commentPlus.comment.id,
                          ),
                        );
                  },
                  onUnliked: () {
                    context.read<AppBloc>().add(
                          AppEventUnlikePostComment(
                            postId: postId,
                            commentId: commentPlus.comment.id,
                          ),
                        );
                  },
                );
              },
            )
          : Center(child: const Text('No hay comentarios')),
    );
  }
}
