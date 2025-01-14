import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class Event {
  final String id;
  final String title;
  final String text;
  const Event({
    required this.id,
    required this.title,
    required this.text,
  });

  Event.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        title = snapshot.data()[eventsTitleFieldName] as String,
        text = snapshot.data()[eventsTextFieldName] as String;

  Event.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        title = doc[eventsTitleFieldName] as String,
        text = doc[eventsTextFieldName] as String;

  @override
  String toString() => 'Event (title: $title, text: $text)';

  String get shareEvent => 'Evento en VecinApp:\n\n$title\n\n$text';

  Event copyWith({
    required String newTitle,
    required String newText,
  }) {
    return Event(
      id: id,
      title: newTitle,
      text: newText,
    );
  }
}
