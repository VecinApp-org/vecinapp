import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/comment_plus.dart';
import 'package:vecinapp/utilities/entities/post.dart';

@immutable
class PostPlus extends Equatable {
  final Post post;
  final CloudUser user;
  final Iterable<CommentPlus> commentsPlus;
  const PostPlus({
    required this.post,
    required this.user,
    this.commentsPlus = const [],
  });

  @override
  List<Object?> get props => [post, user, commentsPlus];

  PostPlus copyWith({
    Post? post,
    CloudUser? user,
    Iterable<CommentPlus>? commentsPlus,
  }) {
    return PostPlus(
      post: post ?? this.post,
      user: user ?? this.user,
      commentsPlus: commentsPlus ?? this.commentsPlus,
    );
  }
}
