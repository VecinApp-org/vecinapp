import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/cloud_user.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';

@immutable
abstract class CloudProvider {
  Future<void> initialize({required authProvider});

  Future<CloudUser?> get currentCloudUser;
  Future<CloudUser?> get cachedCloudUser;

  Future<void> createCloudUser({
    required String username,
    required String displayName,
  });

  Future<void> deleteCloudUser();

  Future<void> changeHousehold({
    required String fullAddress,
    required String addressLine1,
    required String groupname,
    required String? interior,
    required double latitude,
    required double longitude,
  });

  Future<void> assignNeighborhood();

  Future<void> updateUserDisplayName({
    required String displayName,
  });
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
