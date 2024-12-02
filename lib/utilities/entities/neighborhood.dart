import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:vecinapp/extensions/geometry/point.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';

@immutable
class Neighborhood {
  final String neighborhoodId;
  final String neighborhoodName;
  final String country;
  final String state;
  final String municipality;
  final List<Point> polygon;

  const Neighborhood({
    required this.neighborhoodId,
    required this.neighborhoodName,
    required this.country,
    required this.state,
    required this.municipality,
    required this.polygon,
  });

  factory Neighborhood.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final geoPoint = doc[neighborhoodPolygonFieldName] as Map<String, dynamic>;
    final List<Point> polygon = [];
    for (final point in geoPoint.values) {
      polygon.add(Point(x: point.latitude, y: point.longitude));
    }
    return Neighborhood(
        neighborhoodId: doc.id,
        neighborhoodName: doc[neighborhoodNameFieldName] as String,
        country: doc[neighborhoodCountryFieldName] as String,
        state: doc[neighborhoodStateFieldName] as String,
        municipality: doc[neighborhoodMunicipalityFieldName] as String,
        polygon: polygon);
  }
}
