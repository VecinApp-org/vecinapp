import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class Comment {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  Comment.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        text = snapshot.data()[commentTextFieldName] as String,
        authorId = snapshot.data()[commentCreatorIdFieldName] as String,
        authorName = snapshot.data()[commentCreatorNameFieldName] as String,
        createdAt = snapshot.data()[commentDateFieldName].toDate() as DateTime;
}
