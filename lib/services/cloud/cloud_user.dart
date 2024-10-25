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

  factory CloudUser.fromFirebase(DocumentSnapshot<Map<String, dynamic>> data) {
    late final String? displayName;
    late final String? homeId;
    late final String? neighborhoodId;
    late final String? profilePhotoUrl;

    try {
      displayName = data.get(userDisplayNameFieldName);
    } catch (e) {
      displayName = null;
    }

    try {
      homeId = data.get(userHomeIdFieldName);
    } catch (e) {
      homeId = null;
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
      homeId: homeId,
      neighborhoodId: neighborhoodId,
      profilePhotoUrl: profilePhotoUrl,
    );
  }

  @override
  String toString() {
    return 'CloudUser(displayName: $displayName, homeId: $homeId, neighborhoodId: $neighborhoodId, profilePhotoUrl: $profilePhotoUrl)';
  }
}
