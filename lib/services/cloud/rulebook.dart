import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class Rulebook {
  final String id;
  final String title;
  final String text;
  const Rulebook({
    required this.id,
    required this.title,
    required this.text,
  });

  Rulebook.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        title = snapshot.data()[rulebookTitleFieldName] as String,
        text = snapshot.data()[rulebookTextFieldName] as String;

  @override
  String toString() => 'Rulebook (title: $title, text: $text)';

  String get shareRulebook => 'Reglamento en VecinApp:\n\n$title\n\n$text';

  Rulebook copyWith({
    required String newTitle,
    required String newText,
  }) {
    return Rulebook(
      id: id,
      title: newTitle,
      text: newText,
    );
  }
}
