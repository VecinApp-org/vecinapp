import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;
import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';

@immutable
class Household {
  final String id;
  final String fullAddress;
  final String street;
  final String number;
  final String? interior;
  final double latitude;
  final double longitude;
  final String? neighborhoodId;

  const Household({
    required this.id,
    required this.fullAddress,
    required this.street,
    required this.number,
    required this.interior,
    required this.latitude,
    required this.longitude,
    required this.neighborhoodId,
  });

  factory Household.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Household(
      id: snapshot.id,
      neighborhoodId: data[householdNeighborhoodIdFieldName] as String?,
      fullAddress: data[householdFullAddressFieldName] as String,
      street: data[householdStreetFieldName] as String,
      number: data[householdHouseNumberFieldName] as String,
      interior: data[householdInteriorFieldName] as String?,
      latitude: data[householdLocationFieldName].latitude as double,
      longitude: data[householdLocationFieldName].longitude as double,
    );
  }
}
