import 'package:flutter/foundation.dart' show immutable;

@immutable
class Household {
  final String id;
  final String addressLine1;
  final String group;
  final String fullAddress;
  final String? interior;
  final double? latitude;
  final double? longitude;
  final String? neighborhoodId;
  const Household({
    required this.id,
    required this.addressLine1,
    required this.group,
    required this.fullAddress,
    required this.interior,
    required this.latitude,
    required this.longitude,
    required this.neighborhoodId,
  });
}
