import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_sorage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudDoc {
  final String documentId;
  final String ownerUserId;
  final String title;
  final String text;
  const CloudDoc({
    required this.documentId,
    required this.ownerUserId,
    required this.title,
    required this.text,
  });

  CloudDoc.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        title = snapshot.data()[titleFieldName] as String,
        text = snapshot.data()[textFieldName] as String;

  @override
  String toString() =>
      'CloudDoc(ownerUserId: $ownerUserId, title: $title, text: $text)';

  String get shareDoc => 'Reglamento en VecinApp:\n\n$title\n\n$text';
}
