import 'package:flutter/foundation.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:vecinapp/utilities/entities/address.dart';

@immutable
abstract class CloudProvider {
  Future<void> initialize({required authProvider});

  Future<CloudUser?> get currentCloudUser;
  Future<CloudUser?> get cachedCloudUser;
  Future<Neighborhood?> get cachedNeighborhood;
  Future<Neighborhood?> get currentNeighborhood;
  Future<Household?> get currentHousehold;
  Future<Household?> get cachedHousehold;

  Future<void> createCloudUser({
    required String displayName,
  });

  Future<void> deleteCloudUser();

  Future<void> updateHousehold({
    required Address address,
  });

  Future<void> exitHousehold();

  Future<void> exitNeighborhood();

  Future<void> assignNeighborhood();

  Future<void> updateUserDisplayName({
    required String displayName,
  });

  Future<void> updateUserPhotoUrl({
    required String? photoUrl,
  });

  Stream<Iterable<CloudUser>> householdNeighbors({
    required String householdId,
  });

  Future<Household> otherHousehold({required String householdId});

  Stream<Iterable<Rulebook>> neighborhoodRulebooks({
    required String neighborhoodId,
  });

  Future<Rulebook> createNewRulebook({
    required String title,
    required String text,
  });

  Future<void> updateRulebook({
    required String rulebookId,
    required String title,
    required String text,
  });

  Future<void> deleteRulebook({
    required String rulebookId,
  });
}
