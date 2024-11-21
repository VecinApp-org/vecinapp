import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';

@immutable
class CloudUser {
  final String id;
  final String username;
  final String displayName;
  final String? householdId;
  final String? neighborhoodId;
  final String? photoUrl;

  const CloudUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.householdId,
    required this.neighborhoodId,
    required this.photoUrl,
  });

  factory CloudUser.fromFirebase({required DocumentSnapshot doc}) {
    final docData = doc.data() as Map<String?, dynamic>;

    return CloudUser(
      id: doc.id,
      username: docData[userUsernameFieldName],
      displayName: docData[userDisplayNameFieldName],
      householdId: docData[userHouseholdIdFieldName],
      neighborhoodId: docData[userNeighborhoodIdFieldName],
      photoUrl: docData[userProfilePhotoUrlFieldName],
    );
  }

  factory CloudUser.fromSnapshot(
      {required QueryDocumentSnapshot<Map<String?, dynamic>> snapshot}) {
    final docData = snapshot.data();
    return CloudUser(
        id: snapshot.id,
        username: docData[userUsernameFieldName] as String,
        displayName: docData[userDisplayNameFieldName] as String,
        householdId: docData[userHouseholdIdFieldName] as String?,
        neighborhoodId: docData[userNeighborhoodIdFieldName] as String?,
        photoUrl: docData[userProfilePhotoUrlFieldName] as String?);
  }

  @override
  String toString() {
    return 'CloudUser(displayName: $displayName, homeId: $householdId, neighborhoodId: $neighborhoodId)';
  }
}
