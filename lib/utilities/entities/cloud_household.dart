import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';

@immutable
class Household {
  final String id;
  final String fullAddress;
  final String street;
  final String number;
  final String? interior;
  final String? neighborhood;
  final String country;
  final String municipality;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String? neighborhoodId;

  const Household({
    required this.id,
    required this.fullAddress,
    required this.street,
    required this.number,
    required this.interior,
    required this.neighborhood,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.neighborhoodId,
    required this.municipality,
    required this.postalCode,
    required this.state,
  });

  factory Household.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Household(
      id: snapshot.id,
      neighborhoodId: data[householdNeighborhoodIdFieldName] as String?,
      fullAddress: data[householdFullAddressFieldName] as String,
      street: data[householdStreetFieldName] as String,
      country: data[householdCountryFieldName] as String,
      municipality: data[householdMunicipalityFieldName] as String,
      neighborhood: data[householdNeighborhoodFieldName] as String?,
      state: data[householdStateFieldName] as String,
      postalCode: data[householdPostalCodeFieldName] as String,
      number: data[householdHouseNumberFieldName] as String,
      interior: data[householdInteriorFieldName] as String?,
      latitude: data[householdLocationFieldName].latitude as double,
      longitude: data[householdLocationFieldName].longitude as double,
    );
  }
}
