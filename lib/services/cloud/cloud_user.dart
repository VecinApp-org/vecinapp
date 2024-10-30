import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;
import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';

@immutable
class CloudUser {
  final String id;
  final String? username;
  final String? displayName;
  final String? householdId;
  final String? neighborhoodId;
  final String? profilePhotoUrl;

  const CloudUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.householdId,
    required this.neighborhoodId,
    required this.profilePhotoUrl,
  });

  factory CloudUser.fromFirebase({required DocumentSnapshot doc}) {
    final docData = doc.data() as Map<String, dynamic>;

    return CloudUser(
      id: doc.id,
      username: docData[userUsernameFieldName],
      displayName: docData[userDisplayNameFieldName],
      householdId: docData[userHouseholdIdFieldName],
      neighborhoodId: docData[userNeighborhoodIdFieldName],
      profilePhotoUrl: docData[userProfilePhotoUrlFieldName],
    );
  }

  @override
  String toString() {
    return 'CloudUser(displayName: $displayName, homeId: $householdId, neighborhoodId: $neighborhoodId, profilePhotoUrl: $profilePhotoUrl)';
  }
}
