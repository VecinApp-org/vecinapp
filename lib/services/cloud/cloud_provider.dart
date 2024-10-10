import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';

@immutable
abstract class CloudProvider {
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
