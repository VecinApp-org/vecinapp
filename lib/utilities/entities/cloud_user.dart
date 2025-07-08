import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

@immutable
class CloudUser {
  final String id;
  final String displayName;
  final String? householdId;
  final String? neighborhoodId;
  final String? photoUrl;
  final bool isNeighborhoodAdmin;
  final bool isSuperAdmin;

  const CloudUser({
    required this.id,
    required this.displayName,
    required this.householdId,
    required this.neighborhoodId,
    required this.photoUrl,
    required this.isNeighborhoodAdmin,
    required this.isSuperAdmin,
  });

  factory CloudUser.fromFirebase({required DocumentSnapshot doc}) {
    final docData = doc.data() as Map<String?, dynamic>;

    late final bool isNeighborhoodAdmin;
    late final bool isSuperAdmin;
    switch (docData[userAdminLevelFieldName]) {
      case null:
        isNeighborhoodAdmin = false;
        isSuperAdmin = false;
      case 'neighborhoodadmin':
        isNeighborhoodAdmin = true;
        isSuperAdmin = false;
      case 'superadmin':
        isNeighborhoodAdmin = true;
        isSuperAdmin = true;
      default:
        isNeighborhoodAdmin = false;
        isSuperAdmin = false;
    }

    return CloudUser(
      id: doc.id,
      displayName: docData[userDisplayNameFieldName],
      householdId: docData[userHouseholdIdFieldName],
      neighborhoodId: docData[userNeighborhoodIdFieldName],
      photoUrl: docData[userProfilePhotoUrlFieldName],
      isNeighborhoodAdmin: isNeighborhoodAdmin,
      isSuperAdmin: isSuperAdmin,
    );
  }

  factory CloudUser.fromSnapshot(
      {required QueryDocumentSnapshot<Map<String?, dynamic>> snapshot}) {
    final docData = snapshot.data();
    late final bool isNeighborhoodAdmin;
    late final bool isSuperAdmin;
    switch (docData[userAdminLevelFieldName]) {
      case null:
        isNeighborhoodAdmin = false;
        isSuperAdmin = false;
      case 'neighborhoodadmin':
        isNeighborhoodAdmin = true;
        isSuperAdmin = false;
      case 'superadmin':
        isNeighborhoodAdmin = true;
        isSuperAdmin = true;
      default:
        isNeighborhoodAdmin = false;
        isSuperAdmin = false;
    }
    return CloudUser(
        id: snapshot.id,
        displayName: docData[userDisplayNameFieldName] as String,
        householdId: docData[userHouseholdIdFieldName] as String?,
        neighborhoodId: docData[userNeighborhoodIdFieldName] as String?,
        photoUrl: docData[userProfilePhotoUrlFieldName] as String?,
        isNeighborhoodAdmin: isNeighborhoodAdmin,
        isSuperAdmin: isSuperAdmin);
  }

  @override
  String toString() {
    return 'CloudUser(displayName: $displayName, homeId: $householdId, neighborhoodId: $neighborhoodId photoUrl: $photoUrl, isNeighborhoodAdmin: $isNeighborhoodAdmin, isSuperAdmin: $isSuperAdmin)';
  }
}
