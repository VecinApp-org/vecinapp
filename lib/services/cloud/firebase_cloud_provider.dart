import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_provider.dart';
import 'package:vecinapp/services/cloud/cloud_user.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:vecinapp/services/cloud/cloud_exceptions.dart';
import 'dart:developer' as devtools show log;

class FirebaseCloudProvider implements CloudProvider {
  final rulebooks =
      FirebaseFirestore.instance.collection(rulebooksCollectionName);
  final neighborhood =
      FirebaseFirestore.instance.collection(neighborhoodsCollectionName);
  final home = FirebaseFirestore.instance.collection(homesCollectionName);
  final users = FirebaseFirestore.instance.collection(usersCollectionName);
  late final CloudUser? _cachedCloudUser;

  @override
  Future<void> deleteRulebook({
    required String rulebookId,
  }) async {
    try {
      await rulebooks.doc(rulebookId).delete();
    } catch (e) {
      throw CouldNotDeleteRulebookException();
    }
  }

  @override
  Future<void> updateRulebook({
    required String rulebookId,
    required String title,
    required String text,
  }) async {
    if (title.isEmpty || text.isEmpty) {
      throw ChannelErrorRulebookException();
    }
    try {
      await rulebooks.doc(rulebookId).update({
        rulebookTitleFieldName: title,
        rulebookTextFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateRulebooksException();
    }
  }

  @override
  Stream<Iterable<Rulebook>> allRulebooks({required String ownerUserId}) {
    final allRulebooks = rulebooks
        .where(rulebookOwnerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => Rulebook.fromSnapshot(doc)));
    return allRulebooks;
  }

  @override
  Future<Rulebook> createNewRulebook({
    required String ownerUserId,
    required String title,
    required String text,
  }) async {
    if (title.isEmpty || text.isEmpty) {
      throw ChannelErrorRulebookException();
    }
    final rulebook = await rulebooks.add({
      rulebookOwnerUserIdFieldName: ownerUserId,
      rulebookTitleFieldName: title,
      rulebookTextFieldName: text,
    });
    final fetchedRulebook = await rulebook.get();

    return Rulebook(
      id: fetchedRulebook.id,
      ownerUserId: ownerUserId,
      title: title,
      text: text,
    );
  }

  void _ensureInitialized() {
    if (_cachedCloudUser == null) {
      throw CloudProviderNotInitializedException();
    }
  }

  @override
  Future<void> initialize({required String? userId}) async {
    devtools.log('Initializing Firebase Cloud Provider... $userId');
    if (userId == null) {
      _cachedCloudUser = null;
      return;
    }

    try {
      // check if the user exists
      final userDoc = await users.doc(userId).get();
      if (!userDoc.exists) {
        _cachedCloudUser = null;
        return;
      }
      // get the cloud user
      _cachedCloudUser = await users.doc(userId).get().then((value) {
        devtools.log('Cloud user: $value');
        return CloudUser.fromFirebase(value);
      }).onError((error, stackTrace) {
        devtools.log(error.toString());
        throw CouldNotInitializeCloudProviderException();
      });
    } catch (_) {
      _cachedCloudUser = null;
    }
  }

  @override
  CloudUser? get currentUser {
    return _cachedCloudUser;
  }

  Future<CloudUser> createCloudUser({
    required String userId,
    required String displayName,
  }) async {
    // check if displayName is empty
    if (displayName.isEmpty) {
      throw ChannelErrorRulebookException();
    }
    final cloudUser = users.doc(userId);

    await cloudUser.set({
      userDisplayNameFieldName: displayName,
    }).onError((error, stackTrace) => throw CouldNotCreateCloudUserException());

    final fetchedUser = await cloudUser.get();

    _cachedCloudUser = CloudUser.fromFirebase(fetchedUser);

    return currentUser!;
  }

  Future<void> updateUserDisplayName({
    required String displayName,
    required String userId,
  }) async {
    // check if displayName is empty
    if (displayName.isEmpty) {
      throw ChannelErrorRulebookException();
    }
    final cloudUser = users.doc(userId);
    await cloudUser.update({
      userDisplayNameFieldName: displayName,
    }).onError((error, stackTrace) => throw CouldNotUpdateUserException());
  }

  Future<void> updateUserPhotoUrl({
    required String photoUrl,
    required String userId,
  }) async {
    // check if photoUrl is valid
    if (photoUrl.isEmpty) {
      throw ChannelErrorRulebookException();
    }
    // update the user photo url
    final cloudUser = users.doc(userId);
    await cloudUser.update({
      userProfilePhotoUrlFieldName: photoUrl,
    }).onError((error, stackTrace) => throw CouldNotUpdateUserException());
  }

  Future<void> updateUserHomeId({
    required String homeId,
    required String userId,
  }) async {
    final cloudUser = users.doc(userId);
    await cloudUser.update({
      userHomeIdFieldName: homeId,
    }).onError((error, stackTrace) => throw CouldNotUpdateUserException());
  }
}
