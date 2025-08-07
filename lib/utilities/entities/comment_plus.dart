import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/comment.dart';

@immutable
class CommentPlus extends Equatable {
  final Comment comment;
  final CloudUser author;

  const CommentPlus({required this.comment, required this.author});

  @override
  List<Object?> get props => [comment, author];

  CommentPlus copyWith({
    Comment? comment,
  }) {
    return CommentPlus(
      comment: comment ?? this.comment,
      author: author,
    );
  }
}
