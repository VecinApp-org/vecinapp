import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/cloud_user.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';

@immutable
abstract class CloudProvider {
  Future<void> initialize({
    required String? userId,
  });

  Future<CloudUser?> get currentCloudUser;

  Future<void> createCloudUser({
    required String userId,
    required String username,
    required String displayName,
  });

  Future<void> changeHousehold({
    required String fullAddress,
    required String addressLine1,
    required String groupname,
    required String? interior,
    required double latitude,
    required double longitude,
  });

  Future<void> assignNeighborhood();

  Stream<Iterable<Rulebook>> allRulebooks({
    required String ownerUserId,
  });

  Future<Rulebook> createNewRulebook({
    required String ownerUserId,
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
