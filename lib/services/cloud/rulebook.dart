import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class Rulebook {
  final String id;
  final String ownerUserId;
  final String title;
  final String text;
  const Rulebook({
    required this.id,
    required this.ownerUserId,
    required this.title,
    required this.text,
  });

  Rulebook.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        title = snapshot.data()[titleFieldName] as String,
        text = snapshot.data()[textFieldName] as String;

  @override
  String toString() =>
      'Rulebook (ownerUserId: $ownerUserId, title: $title, text: $text)';

  String get shareRulebook => 'Reglamento en VecinApp:\n\n$title\n\n$text';

  Rulebook copyWith({
    required String newTitle,
    required String newText,
  }) {
    return Rulebook(
      id: id,
      ownerUserId: ownerUserId,
      title: newTitle,
      text: newText,
    );
  }
}
