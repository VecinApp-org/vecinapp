import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;
import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';

@immutable
class Household {
  final String id;
  final String fullAddress;
  final String addressLine1;
  final String groupname;
  final String? interior;
  final double latitude;
  final double longitude;

  const Household({
    required this.id,
    required this.fullAddress,
    required this.addressLine1,
    required this.groupname,
    required this.interior,
    required this.latitude,
    required this.longitude,
  });

  factory Household.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Household(
      id: snapshot.id,
      fullAddress: data[householdFullAddressFieldName] as String,
      addressLine1: data[householdAddressLine1FieldName] as String,
      groupname: data[householdGroupNameFieldName] as String,
      interior: data[householdInteriorFieldName] as String?,
      latitude: data[householdLocationFieldName].latitude as double,
      longitude: data[householdLocationFieldName].longitude as double,
    );
  }
}
