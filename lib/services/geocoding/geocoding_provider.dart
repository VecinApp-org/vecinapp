import 'package:flutter/foundation.dart';
import 'package:vecinapp/utilities/entities/address.dart';

@immutable
abstract class GeocodingProvider {
  const GeocodingProvider();

  Future<List<Address>> getValidAddress({
    required String country,
    required String state,
    required String municipality,
    required String neighborhood,
    required String street,
    required String housenumber,
    required String postalCode,
    required String? interior,
    required double? latitude,
    required double? longitude,
  });
}
