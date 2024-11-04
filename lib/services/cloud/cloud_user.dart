import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';

@immutable
class CloudUser {
  final String id;
  final String? username;
  final String? displayName;
  final String? householdId;
  final String? neighborhoodId;

  const CloudUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.householdId,
    required this.neighborhoodId,
  });

  factory CloudUser.fromFirebase({required DocumentSnapshot doc}) {
    final docData = doc.data() as Map<String, dynamic>;

    return CloudUser(
      id: doc.id,
      username: docData[userUsernameFieldName],
      displayName: docData[userDisplayNameFieldName],
      householdId: docData[userHouseholdIdFieldName],
      neighborhoodId: docData[userNeighborhoodIdFieldName],
    );
  }

  CloudUser.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        username = snapshot.data()[userUsernameFieldName] as String,
        displayName = snapshot.data()[userDisplayNameFieldName] as String,
        householdId = snapshot.data()[userHouseholdIdFieldName] as String,
        neighborhoodId = snapshot.data()[userNeighborhoodIdFieldName] as String;

  @override
  String toString() {
    return 'CloudUser(displayName: $displayName, homeId: $householdId, neighborhoodId: $neighborhoodId)';
  }
}
