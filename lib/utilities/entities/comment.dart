import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class Comment extends Equatable {
  final String id;
  final String text;
  final String authorId;
  final DateTime timestamp;
  final Set<String> likes;
  final int likeCount;

  const Comment({
    required this.id,
    required this.text,
    required this.authorId,
    required this.timestamp,
    required this.likes,
    required this.likeCount,
  });

  factory Comment.fromDocument(DocumentSnapshot<Map<String?, dynamic>> doc) {
    final data = doc.data()!;
    final likes = Set<String>.from(data[commentLikesFieldName] ?? []);
    return Comment(
      id: doc.id,
      text: data[commentTextFieldName] as String,
      authorId: data[commentCreatorIdFieldName] as String,
      timestamp: data[commentDateFieldName].toDate() as DateTime,
      likes: likes,
      likeCount: likes.length,
    );
  }

  factory Comment.fromSnapshot(
      QueryDocumentSnapshot<Map<String?, dynamic>> snapshot) {
    final data = snapshot.data();
    final likes = Set<String>.from(data[commentLikesFieldName] ?? []);
    return Comment(
      id: snapshot.id,
      text: snapshot.data()[commentTextFieldName] as String,
      authorId: snapshot.data()[commentCreatorIdFieldName] as String,
      timestamp: snapshot.data()[commentDateFieldName].toDate() as DateTime,
      likes: likes,
      likeCount: likes.length,
    );
  }

  @override
  List<Object?> get props => [id, text, authorId, timestamp];
}
