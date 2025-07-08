import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class Post {
  final String id;
  final String text;
  final String authorId;
  final DateTime timestamp;
  final Set<String>? likes;
  final int? commentCount;

  const Post({
    required this.id,
    required this.text,
    required this.authorId,
    required this.timestamp,
    required this.likes,
    required this.commentCount,
  });

  factory Post.fromSnapshot(
      {required QueryDocumentSnapshot<Map<String?, dynamic>> snapshot}) {
    final data = snapshot.data();

    return Post(
      id: snapshot.id,
      authorId: data[postCreatorIdFieldName] as String,
      text: data[postTextFieldName] as String,
      timestamp: data[postTimeCreatedFieldName].toDate() as DateTime,
      likes: Set<String>.from(data[postLikesFieldName] ?? []),
      commentCount: data[postCommentsCountFieldName] ?? 0,
    );
  }

  factory Post.fromDocument({required DocumentSnapshot doc}) {
    final data = doc.data() as Map<String?, dynamic>;
    return Post(
        id: doc.id,
        text: data[postTextFieldName] as String,
        authorId: data[postCreatorIdFieldName] as String,
        timestamp: data[postTimeCreatedFieldName].toDate() as DateTime,
        likes: data[postLikesFieldName],
        commentCount: data[postCommentsCountFieldName] ?? 0);
  }

  @override
  String toString() =>
      'Post(id: $id, authorId: $authorId, timestamp: $timestamp, likeCount: ${likes?.length}, commentCount: $commentCount, text: $text)';
}
