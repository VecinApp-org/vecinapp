import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';

@immutable
class CloudUser {
  final String? displayName;
  final String? homeId;
  final String? neighborhoodId;
  final String? profilePhotoUrl;
  const CloudUser({
    required this.displayName,
    required this.homeId,
    required this.neighborhoodId,
    required this.profilePhotoUrl,
  });

  CloudUser.fromFirebase(DocumentSnapshot<Map<String, dynamic>> data)
      : displayName = data[userDisplayNameFieldName],
        homeId = data[userHomeIdFieldName],
        neighborhoodId = data[userNeighborhoodIdFieldName],
        profilePhotoUrl = data[userProfilePhotoUrlFieldName];

  @override
  String toString() {
    return 'CloudUser(displayName: $displayName, homeId: $homeId, neighborhoodId: $neighborhoodId, profilePhotoUrl: $profilePhotoUrl)';
  }
}
