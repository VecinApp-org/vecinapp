import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final households =
      FirebaseFirestore.instance.collection(householdsCollectionName);
  final users = FirebaseFirestore.instance.collection(usersCollectionName);

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

  @override
  Future<void> initialize({required String? userId}) async {
    await users.doc(userId).get();
  }

  @override
  Future<CloudUser> get currentCloudUser async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final cloudUser = await users.doc(userId).get();
    return CloudUser.fromFirebase(doc: cloudUser);
  }

  @override
  Future<CloudUser> get cachedCloudUser async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final cachedUser = await users
        .doc(userId)
        .get(
          (GetOptions(source: Source.cache)),
        )
        .then((value) => CloudUser.fromFirebase(doc: value));

    return cachedUser;
  }

  @override
  Future<void> createCloudUser({
    required String userId,
    required String username,
    required String displayName,
  }) async {
    // check if input is empty
    if (displayName.isEmpty || username.isEmpty) {
      throw ChannelErrorRulebookException();
    }

    // check if user already exists
    final cloudUser = await currentCloudUser;
    if (cloudUser.username != null) {
      throw UserAlreadyExistsException();
    }

    // create the cloud user
    try {
      await users.doc(userId).set({
        userDisplayNameFieldName: displayName,
        userUsernameFieldName: username,
      });
    } on CloudException catch (e) {
      devtools.log(
          'Could not create cloud user ${e.runtimeType}/${e.hashCode}/${e.toString()}');
      throw CouldNotCreateCloudUserException();
    } catch (e) {
      devtools.log(
          'Could not create cloud user ${e.runtimeType}/${e.hashCode}/${e.toString()}');
      throw CouldNotCreateCloudUserException();
    }
  }

  @override
  Future<void> changeHousehold({
    required String fullAddress,
    required String addressLine1,
    required String groupname,
    required String? interior,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await households
          .where(householdFullAddressFieldName, isEqualTo: fullAddress)
          .get()
          .then((value) async {
        late DocumentSnapshot snapshot;
        //get or create household
        if (value.docs.isEmpty) {
          snapshot = await households.add({
            householdFullAddressFieldName: fullAddress,
            householdAddressLine1FieldName: addressLine1,
            householdGroupNameFieldName: groupname,
            householdInteriorFieldName: interior,
            householdLocationFieldName: GeoPoint(latitude, longitude),
          }).then((value) => value.get());
        } else {
          snapshot = value.docs.first;
        }
        // update the user's household id and neighborhood id if applicable
        final data = snapshot.data() as Map<String, dynamic>;
        if (data[householdNeighborhoodIdFieldName] != null) {
          await users.doc(userId).update({
            userHouseholdIdFieldName: snapshot.id,
            userNeighborhoodIdFieldName: data[householdNeighborhoodIdFieldName],
          });
        } else {
          await users.doc(userId).update({
            userHouseholdIdFieldName: snapshot.id,
          });
        }
      });
    } catch (e) {
      throw CouldNotUpdateHouseholdException();
    }
  }

  @override
  Future<void> assignNeighborhood() async {
    final cloudUser = await currentCloudUser;
    final authUser = FirebaseAuth.instance.currentUser!;

    if (cloudUser.householdId == null) {
      throw UserRequiresHouseholdException();
    }
    try {
      //get the household doc
      await households.doc(cloudUser.householdId).get().then((value) async {
        //check if the household has a neighborhood
        final data = value.data() as Map<String, dynamic>;
        if (data.containsKey(householdNeighborhoodIdFieldName)) {
          // update the user's neighborhood id
          await users.doc(authUser.uid).update({
            userNeighborhoodIdFieldName: data[householdNeighborhoodIdFieldName],
          });
        } else {
          //todo try to assign a neighborhood
          throw CouldNotAssignNeighborhoodException();
        }
      });
    } catch (e) {
      throw CouldNotAssignNeighborhoodException();
    }
  }

  @override
  Future<void> updateUserDisplayName({
    required String displayName,
  }) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    // check if displayName is empty
    if (displayName.isEmpty) {
      throw ChannelErrorRulebookException();
    }
    final cachedUser = await cachedCloudUser;

    if (displayName == cachedUser.displayName) {
      return;
    }

    try {
      // update the user display name
      await users.doc(userId).update({
        userDisplayNameFieldName: displayName,
      });
    } catch (e) {
      throw CouldNotUpdateUserException();
    }
  }
}
