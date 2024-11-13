import 'package:flutter/foundation.dart' show immutable;

@immutable
class Address {
  const Address({
    required this.houseNumber,
    required this.interior,
    required this.street,
    required this.neighborhood,
    required this.municipality,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
  });

  final String houseNumber;
  final String? interior;
  final String street;
  final String? neighborhood;
  final String municipality;
  final String state;
  final String country;
  final String postalCode;
  final String fullAddress;
  final double latitude;
  final double longitude;

  factory Address.fromOpenCageJson(
      {required Map<String?, dynamic> json, required String? interior}) {
    final components = json['components'] as Map<String?, dynamic>;
    return Address(
      houseNumber: components['house_number'] as String,
      street: components['road'] as String,
      neighborhood: components['residential'] as String?,
      municipality: components['county'] as String,
      state: components['state'] as String,
      country: components['country'] as String,
      postalCode: components['postcode'] as String,
      fullAddress: json['formatted'] as String,
      latitude: json['geometry']['lat'] as double,
      longitude: json['geometry']['lng'] as double,
      interior: interior,
    );
  }

  @override
  String toString() {
    return 'Address{fullAddress: $fullAddress, latitude: $latitude, longitude: $longitude}';
  }
}
