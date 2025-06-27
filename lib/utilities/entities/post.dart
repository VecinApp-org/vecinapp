import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class Post {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final DateTime timestamp;

  const Post({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.timestamp,
  });

  Post.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        text = snapshot.data()[postTextFieldName] as String,
        authorId = snapshot.data()[postCreatorIdFieldName] as String,
        authorName = snapshot.data()[postCreatorNameFieldName] as String,
        timestamp =
            snapshot.data()[postTimeCreatedFieldName].toDate() as DateTime;

  Post.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        text = doc[postTextFieldName] as String,
        authorId = doc[postCreatorIdFieldName] as String,
        authorName = doc[postCreatorNameFieldName] as String,
        timestamp = doc[postTimeCreatedFieldName].toDate() as DateTime;
}
