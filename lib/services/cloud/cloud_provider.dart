import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:vecinapp/utilities/entities/latlng.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'package:vecinapp/utilities/entities/post.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:vecinapp/utilities/entities/address.dart';

@immutable
abstract class CloudProvider {
  Future<void> initialize({required AuthProvider authProvider});

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
    required String photoUrl,
  });

  Stream<Iterable<CloudUser>> householdNeighbors({
    required String householdId,
  });

  Future<CloudUser?> userFromId({required String userId});

  Future<Household> otherHousehold({required String householdId});

  // RULEBOOKS
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

  Future<Rulebook> getRulebook({required String rulebookId});

  // EVENTS
  Stream<Iterable<Event>> neighborhoodEvents({
    required String neighborhoodId,
  });

  Future<Event> createNewEvent({
    required String? title,
    required String? text,
    required DateTime? dateStart,
    required DateTime? dateEnd,
    required String? placeName,
    required LatLng? location,
  });

  Future<void> updateEvent({
    required String eventId,
    required String? title,
    required String? text,
    required DateTime? dateStart,
    required DateTime? dateEnd,
    required String? placeName,
    required LatLng? location,
  });

  Future<void> deleteEvent({
    required String eventId,
  });

  Future<Event> getEvent({required String eventId});

  // POSTS
  Stream<Iterable<Post>> neighborhoodPosts({
    required String neighborhoodId,
  });

  Future<Post> createNewPost({
    required String? text,
  });

  Future<void> deletePost({
    required String postId,
  });

  Future<Post> getPost({required String postId});
}
