import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;
import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';

@immutable
class CloudUser {
  final String? displayName;
  final String? householdId;
  final String? neighborhoodId;
  final String? profilePhotoUrl;

  const CloudUser({
    required this.displayName,
    required this.householdId,
    required this.neighborhoodId,
    required this.profilePhotoUrl,
  });

  factory CloudUser.fromFirebase(DocumentSnapshot<Map<String, dynamic>> data) {
    late final String? displayName;
    late final String? householdId;
    late final String? neighborhoodId;
    late final String? profilePhotoUrl;

    if (!data.exists || data.data() == null) {
      return const CloudUser(
        displayName: null,
        householdId: null,
        neighborhoodId: null,
        profilePhotoUrl: null,
      );
    }

    try {
      displayName = data.get(userDisplayNameFieldName);
    } catch (e) {
      displayName = null;
    }

    try {
      householdId = data.get(userHouseholdIdFieldName);
    } catch (e) {
      householdId = null;
    }

    try {
      neighborhoodId = data.get(userNeighborhoodIdFieldName);
    } catch (e) {
      neighborhoodId = null;
    }

    try {
      profilePhotoUrl = data.get(userProfilePhotoUrlFieldName);
    } catch (e) {
      profilePhotoUrl = null;
    }

    return CloudUser(
      displayName: displayName,
      householdId: householdId,
      neighborhoodId: neighborhoodId,
      profilePhotoUrl: profilePhotoUrl,
    );
  }

  @override
  String toString() {
    return 'CloudUser(displayName: $displayName, homeId: $householdId, neighborhoodId: $neighborhoodId, profilePhotoUrl: $profilePhotoUrl)';
  }
}
