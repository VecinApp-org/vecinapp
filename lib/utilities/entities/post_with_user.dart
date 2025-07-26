import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/post.dart';

@immutable
class PostWithUser extends Equatable {
  final Post post;
  final CloudUser user;
  const PostWithUser({
    required this.post,
    required this.user,
  });

  @override
  List<Object?> get props => [post, user];
}
