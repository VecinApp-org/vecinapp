import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/extensions/geometry/point.dart';
import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/services/cloud/cloud_provider.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:vecinapp/utilities/entities/latlng.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'package:vecinapp/utilities/entities/post.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:vecinapp/services/cloud/cloud_exceptions.dart';
import 'package:vecinapp/extensions/geometry/is_point_in_polygon.dart';
import 'dart:developer' as devtools show log;
import 'package:vecinapp/utilities/entities/address.dart';

class FirebaseCloudProvider implements CloudProvider {
  late final AuthProvider _authProvider;
  final _neighborhoods =
      FirebaseFirestore.instance.collection(neighborhoodsCollectionName);
  final _households =
      FirebaseFirestore.instance.collection(householdsCollectionName);
  final _users = FirebaseFirestore.instance.collection(usersCollectionName);

  DocumentReference<Map<String, dynamic>> _neighborhood(
      {required String neighborhoodId}) {
    return _neighborhoods.doc(neighborhoodId);
  }

  @override
  Future<void> initialize({required authProvider}) async {
    _authProvider = authProvider;
  }

  // RULEBOOKS
  CollectionReference<Map<String, dynamic>> _rulebooks(
      {required String neighborhoodId}) {
    return _neighborhood(neighborhoodId: neighborhoodId)
        .collection(neighborhoodRulebooksCollectionName);
  }

  DocumentReference<Map<String, dynamic>> _rulebook({
    required String neighborhoodId,
    required String rulebookId,
  }) {
    return _rulebooks(neighborhoodId: neighborhoodId).doc(rulebookId);
  }

  @override
  Future<void> deleteRulebook({
    required String rulebookId,
  }) async {
    // check if user is neighborhood admin
    final user = await currentCloudUser;
    if (!user!.isNeighborhoodAdmin) {
      throw PermissionDeniedCloudException();
    }
    // delete rulebook
    try {
      final user = await cachedCloudUser;
      await _rulebook(
        neighborhoodId: user!.neighborhoodId!,
        rulebookId: rulebookId,
      ).delete();
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
    // check if user is neighborhood admin
    final user = await currentCloudUser;
    if (!user!.isNeighborhoodAdmin) {
      throw PermissionDeniedCloudException();
    }
    // check rulebook is valid
    if (title.isEmpty || text.isEmpty) {
      throw ChannelErrorCloudException();
    }
    // update rulebook
    try {
      final user = await cachedCloudUser;
      return await _rulebook(
        neighborhoodId: user!.neighborhoodId!,
        rulebookId: rulebookId,
      ).update({
        rulebookTitleFieldName: title,
        rulebookTextFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateRulebookException();
    }
  }

  @override
  Future<Rulebook> getRulebook({required String rulebookId}) async {
    try {
      final user = await cachedCloudUser;
      final doc = await _rulebook(
        neighborhoodId: user!.neighborhoodId!,
        rulebookId: rulebookId,
      ).get();
      return Rulebook.fromDocument(doc);
    } catch (e) {
      throw CouldNotGetRulebookException();
    }
  }

  @override
  Stream<Iterable<Rulebook>> neighborhoodRulebooks({
    required String neighborhoodId,
  }) {
    final allRulebooks =
        _rulebooks(neighborhoodId: neighborhoodId).snapshots().map(
      (event) {
        return event.docs.map((doc) {
          return Rulebook.fromSnapshot(doc);
        });
      },
    );
    return allRulebooks;
  }

  @override
  Future<Rulebook> createNewRulebook({
    required String title,
    required String text,
  }) async {
    // check if user is neighborhood admin
    final user = await currentCloudUser;
    if (!user!.isNeighborhoodAdmin) {
      throw PermissionDeniedCloudException();
    }
    // check rulebook is valid
    if (title.isEmpty || text.isEmpty) {
      throw ChannelErrorCloudException();
    }
    // create the rulebook
    try {
      final user = await cachedCloudUser;
      final doc = await _rulebooks(
        neighborhoodId: user!.neighborhoodId!,
      ).add({
        rulebookTitleFieldName: title,
        rulebookTextFieldName: text,
      }).then((doc) => doc.get().then((doc) => Rulebook.fromDocument(doc)));
      return doc;
    } catch (e) {
      throw CouldNotCreateRulebookException();
    }
  }

  // EVENTS
  CollectionReference<Map<String, dynamic>> _events(
      {required String neighborhoodId}) {
    return _neighborhood(neighborhoodId: neighborhoodId)
        .collection(neighborhoodEventsCollectionName);
  }

  DocumentReference<Map<String, dynamic>> _event({
    required String neighborhoodId,
    required String eventId,
  }) {
    return _events(neighborhoodId: neighborhoodId).doc(eventId);
  }

  @override
  Future<void> deleteEvent({
    required String eventId,
  }) async {
    // check if user is neighborhood admin
    final user = await currentCloudUser;
    if (!user!.isNeighborhoodAdmin) {
      throw PermissionDeniedCloudException();
    }
    // delete the event
    try {
      await _event(
        neighborhoodId: user.neighborhoodId!,
        eventId: eventId,
      ).delete();
    } catch (e) {
      throw CouldNotDeleteEventException();
    }
  }

  @override
  Future<void> updateEvent({
    required String eventId,
    required String? title,
    required String? text,
    required DateTime? dateStart,
    required DateTime? dateEnd,
    required String? placeName,
    required LatLng? location,
  }) async {
    // check if user is neighborhood admin
    final user = await currentCloudUser;
    if (!user!.isNeighborhoodAdmin) {
      throw PermissionDeniedCloudException();
    }
    // check if event is valid
    if (title == null ||
        title.isEmpty ||
        dateStart == null ||
        dateEnd == null) {
      throw ChannelErrorCloudException();
    }
    // check if end date is after start
    if (dateStart.isAfter(dateEnd)) {
      throw EventStartsAfterEndsCloudException();
    }
    // check if event date is valid
    if (dateStart.isBefore(DateTime.now().subtract(const Duration(days: 60))) ||
        dateEnd.isAfter(DateTime.now().add(const Duration(days: 365)))) {
      throw EventDateInvalidCloudException();
    }
    // update the event
    try {
      return await _event(
        neighborhoodId: user.neighborhoodId!,
        eventId: eventId,
      ).update({
        eventTitleFieldName: title,
        eventTextFieldName: text,
        eventDateStartFieldName: dateStart,
        eventDateEndFieldName: dateEnd,
        eventPlaceNameFieldName: placeName,
        eventLocationFieldName: location,
      });
    } catch (e) {
      throw CouldNotUpdateEventException();
    }
  }

  @override
  Stream<Iterable<Event>> neighborhoodEvents({
    required String neighborhoodId,
  }) {
    final upcomingEvents = _events(neighborhoodId: neighborhoodId)
        .where(eventDateEndFieldName, isGreaterThan: DateTime.now())
        .snapshots()
        .map(
      (event) {
        return event.docs.map((doc) {
          return Event.fromSnapshot(doc);
        });
      },
    );
    return upcomingEvents;
  }

  @override
  Future<Event> createNewEvent({
    required String? title,
    required String? text,
    required DateTime? dateStart,
    required DateTime? dateEnd,
    required String? placeName,
    required LatLng? location,
  }) async {
    // check if user is neighborhood admin
    final user = await currentCloudUser;
    if (!user!.isNeighborhoodAdmin) {
      throw PermissionDeniedCloudException();
    }
    // check required fields
    if (title == null ||
        title.isEmpty ||
        dateStart == null ||
        dateEnd == null) {
      throw ChannelErrorCloudException();
    }
    // check if end date is after start
    if (dateStart.isAfter(dateEnd)) {
      throw ChannelErrorCloudException();
    }
    // check if events starts in the past
    if (dateStart.isBefore(DateTime.now())) {
      throw ChannelErrorCloudException();
    }
    // create event
    try {
      final doc = await _events(
        neighborhoodId: user.neighborhoodId!,
      ).add({
        eventCreatorIdFieldName: user.id,
        eventTitleFieldName: title,
        eventTextFieldName: text,
        eventDateStartFieldName: dateStart,
        eventDateEndFieldName: dateEnd,
        eventPlaceNameFieldName: placeName,
        eventLocationFieldName:
            location == null ? null : GeoPoint(location.lat, location.lng),
      }).then((doc) => doc.get().then((doc) => Event.fromDocument(doc)));
      return doc;
    } catch (e) {
      throw CouldNotCreateEventException();
    }
  }

  @override
  Future<Event> getEvent({required String eventId}) async {
    try {
      final user = await cachedCloudUser;
      final doc = await _event(
        neighborhoodId: user!.neighborhoodId!,
        eventId: eventId,
      ).get();
      return Event.fromDocument(doc);
    } catch (e) {
      throw CouldNotGetEventException();
    }
  }

  // POSTS

  CollectionReference<Map<String, dynamic>> _posts(
          {required String neighborhoodId}) =>
      _neighborhoods.doc(neighborhoodId).collection('posts');

  DocumentReference<Map<String, dynamic>> _post(
          {required String neighborhoodId, required String postId}) =>
      _posts(neighborhoodId: neighborhoodId).doc(postId);

  @override
  Stream<Iterable<Post>> neighborhoodPosts({required String neighborhoodId}) {
    return _posts(neighborhoodId: neighborhoodId)
        .limit(10)
        .orderBy(postTimeCreatedFieldName, descending: true)
        .snapshots()
        .map(
      (post) {
        return post.docs.map((doc) {
          return Post.fromSnapshot(snapshot: doc);
        });
      },
    );
  }

  @override
  Future<void> likePost({required String postId}) async {
    try {
      final user = await currentCloudUser;
      await _post(
        neighborhoodId: user!.neighborhoodId!,
        postId: postId,
      ).update({
        postLikesFieldName: FieldValue.arrayUnion([user.id]),
      });
    } catch (_) {}
  }

  @override
  Future<void> unlikePost({required String postId}) async {
    try {
      final user = await currentCloudUser;
      await _post(
        neighborhoodId: user!.neighborhoodId!,
        postId: postId,
      ).update({
        postLikesFieldName: FieldValue.arrayRemove([user.id]),
      });
    } catch (_) {}
  }

  @override
  Future<void> createNewPost({required String? text}) async {
    // check required fields
    if (text == null || text.isEmpty) {
      throw ChannelErrorCloudException();
    }
    // create post
    try {
      final user = await currentCloudUser;
      final authuser = _authProvider.currentUser;
      await _posts(neighborhoodId: user!.neighborhoodId!).add({
        postCreatorIdFieldName: authuser!.uid,
        postTextFieldName: text,
        postTimeCreatedFieldName: DateTime.now(),
      }).timeout(Duration(seconds: 15));
      devtools.log('The post was created');
      return;
    } catch (e) {
      if (e is FirebaseException) {
        devtools.log(e.code);
      }
      devtools.log(e.toString());
      throw CouldNotCreatePostException();
    }
  }

  @override
  Future<Post> getPost({required String postId}) async {
    try {
      final user = await cachedCloudUser;
      final doc = await _post(
        neighborhoodId: user!.neighborhoodId!,
        postId: postId,
      ).get();
      return Post.fromDocument(doc: doc);
    } catch (e) {
      throw CouldNotGetPostException();
    }
  }

  @override
  Future<void> deletePost({required String postId}) async {
    try {
      final user = await currentCloudUser;
      return _post(neighborhoodId: user!.neighborhoodId!, postId: postId)
          .delete();
    } catch (e) {
      throw CouldNotDeletePostException();
    }
  }

  // USER
  @override
  Future<CloudUser?> get currentCloudUser async {
    final user = _authProvider.currentUser;

    if (user == null) return null;

    if (user.uid!.isEmpty) return null;
    final DocumentSnapshot<Map<String, dynamic>> cloudUser;
    try {
      cloudUser = await _users.doc(user.uid).get();
    } catch (e) {
      return null;
    }
    if (!cloudUser.exists) return null;

    if (cloudUser.data() == null) return null;

    return CloudUser.fromFirebase(doc: cloudUser);
  }

  @override
  Future<CloudUser?> get cachedCloudUser async {
    final user = _authProvider.currentUser;
    if (user == null) return null;
    if (user.uid!.isEmpty) return null;
    final cachedDoc = await _users.doc(user.uid).get(
          (GetOptions(source: Source.cache)),
        );
    if (!cachedDoc.exists) return null;
    if (cachedDoc.data() == null) return null;
    return CloudUser.fromFirebase(doc: cachedDoc);
  }

  @override
  Future<CloudUser?> userFromId({required String userId}) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    if (doc.data() == null) return null;
    return CloudUser.fromFirebase(doc: doc);
  }

  @override
  Future<void> createCloudUser({
    required String displayName,
  }) async {
    // check if input is empty
    if (displayName.isEmpty) {
      throw ChannelErrorCloudException();
    }

    // check if user already exists
    final cloudUser = await currentCloudUser;

    if (cloudUser != null) {
      throw UserAlreadyExistsException();
    }

    // create the cloud user
    try {
      final userId = _authProvider.currentUser!.uid;
      await _users.doc(userId).set({
        userDisplayNameFieldName: displayName,
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
  Future<void> deleteCloudUser() async {
    try {
      final userId = _authProvider.currentUser!.uid;
      await _users.doc(userId).delete();
    } catch (e) {
      throw CouldNotDeleteCloudUserException();
    }
  }

  @override
  Future<void> updateUserDisplayName({
    required String displayName,
  }) async {
    final userId = _authProvider.currentUser!.uid;
    // check if displayName is empty
    if (displayName.isEmpty) {
      throw ChannelErrorCloudException();
    }
    final cachedUser = await cachedCloudUser;

    if (cachedUser == null) {
      throw UserDoesNotExistException();
    }

    if (displayName == cachedUser.displayName) {
      return;
    }

    try {
      // update the user display name
      await _users.doc(userId).update({
        userDisplayNameFieldName: displayName,
      });
    } catch (e) {
      throw CouldNotUpdateUserException();
    }
  }

  @override
  Future<void> updateUserPhotoUrl({required String photoUrl}) async {
    final userId = _authProvider.currentUser!.uid;
    try {
      // update the user photo url
      await _users.doc(userId).update({
        userProfilePhotoUrlFieldName: photoUrl,
      });
    } catch (e) {
      throw CouldNotUpdateUserException();
    }
  }

  // HOUSEHOLD
  @override
  Future<Household?> get currentHousehold async {
    final user = await cachedCloudUser;
    if (user == null) return null;
    if (user.householdId == null) return null;
    return await _households.doc(user.householdId!).get().then((value) {
      if (!value.exists) return null;
      return Household.fromSnapshot(value);
    });
  }

  @override
  Future<Household?> get cachedHousehold async {
    final user = await cachedCloudUser;
    if (user == null) return null;
    if (user.householdId == null) return null;
    return await _households
        .doc(user.householdId!)
        .get(GetOptions(source: Source.cache))
        .then((value) {
      if (!value.exists) return null;
      return Household.fromSnapshot(value);
    });
  }

  @override
  Future<void> updateHousehold({
    required Address address,
  }) async {
    // check if input is empty
    if (address.fullAddress.isEmpty ||
        address.street.isEmpty ||
        address.houseNumber.isEmpty ||
        address.postalCode.isEmpty ||
        address.municipality.isEmpty ||
        address.state.isEmpty ||
        address.country.isEmpty) {
      throw ChannelErrorCloudException();
    }
    //check if interior is not empty and has spaces or special characters
    var interior = address.interior;
    if (address.interior != null) {
      if (address.interior!.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')) ||
          address.interior!.contains(' ')) {
        throw ChannelErrorCloudException();
      }
      if (address.interior!.isEmpty) {
        interior = null;
      }
    }

    //update the household
    try {
      final userId = _authProvider.currentUser!.uid;
      await _households
          .where(householdFullAddressFieldName, isEqualTo: address.fullAddress)
          .where(householdInteriorFieldName, isEqualTo: interior)
          .get()
          .then((value) async {
        late DocumentSnapshot snapshot;
        //create household if it doesn't exist
        if (value.docs.isEmpty) {
          snapshot = await _households.add({
            householdFullAddressFieldName: address.fullAddress,
            householdStreetFieldName: address.street,
            householdNeighborhoodFieldName: address.neighborhood,
            householdHouseNumberFieldName: address.houseNumber,
            householdPostalCodeFieldName: address.postalCode,
            householdInteriorFieldName: interior,
            householdMunicipalityFieldName: address.municipality,
            householdCountryFieldName: address.country,
            householdStateFieldName: address.state,
            householdLocationFieldName: GeoPoint(
              address.latitude,
              address.longitude,
            ),
          }).then((value) => value.get());
        } else {
          //get household if it exists
          snapshot = value.docs.first;
        }
        // update the user's household id and neighborhood id if applicable
        final data = snapshot.data() as Map<String?, dynamic>;
        await _users.doc(userId).update({
          userHouseholdIdFieldName: snapshot.id,
          userNeighborhoodIdFieldName: data[householdNeighborhoodIdFieldName],
        });
      });
    } catch (e) {
      throw CouldNotUpdateHouseholdException();
    }
  }

  @override
  Future<void> exitHousehold() async {
    try {
      final userId = _authProvider.currentUser!.uid;
      await _users.doc(userId).update({
        userHouseholdIdFieldName: null,
        userNeighborhoodIdFieldName: null,
      });
    } catch (e) {
      throw CouldNotExitHouseholdException();
    }
  }

  // NEIGHBORHOOD
  @override
  Future<Neighborhood?> get currentNeighborhood async {
    final user = await cachedCloudUser;
    if (user == null) return null;
    if (user.neighborhoodId == null) return null;
    return await _neighborhood(neighborhoodId: user.neighborhoodId!)
        .get()
        .then((value) {
      if (!value.exists) return null;
      return Neighborhood.fromDocument(value);
    });
  }

  @override
  Future<Neighborhood?> get cachedNeighborhood async {
    final user = await cachedCloudUser;
    if (user == null) return null;
    if (user.neighborhoodId == null) return null;
    return await _neighborhood(neighborhoodId: user.neighborhoodId!)
        .get(GetOptions(source: Source.cache))
        .then((value) {
      if (!value.exists) return null;
      return Neighborhood.fromDocument(value);
    });
  }

  @override
  Future<void> exitNeighborhood() async {
    try {
      final cloudUser = await currentCloudUser;
      await _households
          .doc(cloudUser!.householdId)
          .update({householdNeighborhoodIdFieldName: null});
    } catch (e) {
      throw CouldNotExitNeighborhoodException();
    }
  }

  @override
  Future<void> assignNeighborhood() async {
    final authUser = _authProvider.currentUser!;
    final cloudUser = await currentCloudUser;
    if (cloudUser == null) {
      throw UserDoesNotExistException();
    }
    if (cloudUser.householdId == null) {
      throw UserRequiresHouseholdException();
    }
    try {
      //get the household doc
      await _households.doc(cloudUser.householdId).get().then((value) async {
        //check if the household has a neighborhood
        final householdData = value.data() as Map<String, dynamic>;
        if (householdData.containsKey(householdNeighborhoodIdFieldName)) {
          // update the user's neighborhood id
          await _users.doc(authUser.uid).update({
            userNeighborhoodIdFieldName:
                householdData[householdNeighborhoodIdFieldName],
          });
          devtools
              .log('The household already had a neighborhood and was updated');
        } else {
          //Search for nearby neighborhoods
          //todo optimize by searching by distance
          final nearestNeighborhoods = await _neighborhoods
              .where('country',
                  isEqualTo: householdData[householdCountryFieldName])
              .where('state', isEqualTo: householdData[householdStateFieldName])
              .where('municipality',
                  isEqualTo: householdData[householdMunicipalityFieldName])
              .get()
              .then((value) => value.docs);
          //check if the point is in a neighborhood
          if (nearestNeighborhoods.isNotEmpty) {
            //Iterate through the results and check if the point is inside the polygon
            bool found = false;
            for (final neighborhood in nearestNeighborhoods) {
              final geoPoint = neighborhood[neighborhoodPolygonFieldName]
                  as Map<String, dynamic>;
              final List<Point> polygon = [];
              for (final point in geoPoint.values) {
                polygon.add(Point(x: point.latitude, y: point.longitude));
              }
              if (Poly.isPointInPolygon(
                Point(
                  x: householdData[householdLocationFieldName].latitude
                      as double,
                  y: householdData[householdLocationFieldName].longitude
                      as double,
                ),
                polygon,
              )) {
                devtools.log('The point is in the neighborhood');
                // update the household's neighborhood id
                await _households.doc(cloudUser.householdId).update({
                  householdNeighborhoodIdFieldName: neighborhood.id,
                });
                // update the user's neighborhood id
                await _users.doc(authUser.uid).update({
                  userNeighborhoodIdFieldName: neighborhood.id,
                });
                found = true;
                break;
              }
            }
            if (!found) {
              // throw an error if the point is not in a neighborhood
              devtools.log('The point is not in a neighborhood');
              throw CouldNotAssignNeighborhoodException();
            }
          } else {
            // throw an error if the point is not in a neighborhood
            devtools.log('Empty list of neighborhoods');
            throw CouldNotAssignNeighborhoodException();
          }
        }
      });
    } catch (e) {
      devtools.log(e.toString());
      throw CouldNotAssignNeighborhoodException();
    }
  }

  // NEIGHBORS
  @override
  Future<Household> otherHousehold({required String householdId}) async {
    try {
      final doc = await _households.doc(householdId).get();
      return Household.fromSnapshot(doc);
    } catch (e) {
      throw CouldNotGetHouseholdException();
    }
  }

  @override
  Stream<Iterable<CloudUser>> householdNeighbors({
    required String householdId,
  }) {
    final query = _users
        .where(userHouseholdIdFieldName, isEqualTo: householdId)
        .snapshots()
        .map((event) {
      return event.docs.map((doc) {
        return CloudUser.fromSnapshot(snapshot: doc);
      });
    });
    return query;
  }
}
