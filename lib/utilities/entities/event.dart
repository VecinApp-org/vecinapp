import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:vecinapp/utilities/entities/latlng.dart';

@immutable
class Event {
  final String id;
  final String creatorId;
  final String title;
  final String text;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String placeName;
  final LatLng? location;
  const Event({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.text,
    required this.dateStart,
    required this.dateEnd,
    required this.placeName,
    required this.location,
  });

  Event.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        creatorId = snapshot.data()[eventCreatorIdFieldName] as String,
        title = snapshot.data()[eventTitleFieldName] as String,
        text = snapshot.data()[eventTextFieldName] as String,
        dateStart =
            snapshot.data()[eventDateStartFieldName].toDate() as DateTime,
        dateEnd = snapshot.data()[eventDateEndFieldName].toDate() as DateTime,
        placeName = snapshot.data()[eventPlaceNameFieldName] as String,
        location = snapshot.data()[eventLocationFieldName] != null
            ? LatLng(
                snapshot.data()[eventLocationFieldName].latitude,
                snapshot.data()[eventLocationFieldName].longitude,
              )
            : null;

  Event.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        creatorId = doc[eventCreatorIdFieldName] as String,
        title = doc[eventTitleFieldName] as String,
        text = doc[eventTextFieldName] as String,
        dateStart = doc[eventDateStartFieldName].toDate() as DateTime,
        dateEnd = doc[eventDateEndFieldName].toDate() as DateTime,
        placeName = doc[eventPlaceNameFieldName] as String,
        location = doc[eventLocationFieldName] != null
            ? LatLng(
                doc[eventLocationFieldName].latitude,
                doc[eventLocationFieldName].longitude,
              )
            : null;

  @override
  String toString() => 'Event (title: $title, text: $text)';

  String get shareEvent => 'Evento en VecinApp:\n\n$title\n\n$text';
}
