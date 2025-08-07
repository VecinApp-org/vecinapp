import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

@immutable
class Post extends Equatable {
  final String id;
  final String text;
  final String authorId;
  final DateTime timestamp;
  final Set<String> likes;
  final int likeCount;
  final int commentCount;

  const Post({
    required this.id,
    required this.text,
    required this.authorId,
    required this.timestamp,
    required this.likes,
    required this.likeCount,
    required this.commentCount,
  });

  @override
  List<Object?> get props =>
      [id, text, authorId, timestamp, likes, likeCount, commentCount];

  factory Post.fromSnapshot(
      {required QueryDocumentSnapshot<Map<String?, dynamic>> snapshot}) {
    final data = snapshot.data();
    final likes = Set<String>.from(data[postLikesFieldName] ?? []);
    return Post(
      id: snapshot.id,
      authorId: data[postCreatorIdFieldName] as String,
      text: data[postTextFieldName] as String,
      timestamp: data[postTimeCreatedFieldName].toDate() as DateTime,
      likes: likes,
      likeCount: likes.length,
      commentCount: data[postCommentsCountFieldName] ?? 0,
    );
  }

  factory Post.fromDocument(
      {required DocumentSnapshot<Map<String?, dynamic>> doc}) {
    final data = doc.data();
    final likes = Set<String>.from(data?[postLikesFieldName] ?? []);
    return Post(
        id: doc.id,
        text: data?[postTextFieldName] as String,
        authorId: data?[postCreatorIdFieldName] as String,
        timestamp: data?[postTimeCreatedFieldName].toDate() as DateTime,
        likes: likes,
        likeCount: likes.length,
        commentCount: data?[postCommentsCountFieldName] ?? 0);
  }

  @override
  String toString() =>
      'Post(id: $id, authorId: $authorId, timestamp: $timestamp, likeCount: ${likes.length}, commentCount: $commentCount, text: $text)';

  Post copyWith({
    String? text,
    Set<String>? likes,
  }) {
    final likeCount = likes?.length ?? this.likeCount;
    return Post(
      id: id,
      text: text ?? this.text,
      authorId: authorId,
      timestamp: timestamp,
      likes: likes ?? this.likes,
      likeCount: likeCount,
      commentCount: commentCount,
    );
  }
}
