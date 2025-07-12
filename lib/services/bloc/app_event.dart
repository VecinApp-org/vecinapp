import 'package:flutter/foundation.dart' show immutable;
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/latlng.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'package:vecinapp/utilities/entities/post.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:vecinapp/utilities/entities/address.dart';

@immutable
abstract class AppEvent {
  const AppEvent();
}

class AppEventInitialize extends AppEvent {
  const AppEventInitialize();
}

class AppEventReset extends AppEvent {
  const AppEventReset();
}

// AUTHENTICATION ROUTING EVENTS
class AppEventGoToWelcomeView extends AppEvent {
  const AppEventGoToWelcomeView();
}

class AppEventGoToRegistration extends AppEvent {
  const AppEventGoToRegistration();
}

class AppEventGoToForgotPassword extends AppEvent {
  final String? email;
  const AppEventGoToForgotPassword({String? email}) : email = email ?? '';
}

class AppEventGoToLogin extends AppEvent {
  const AppEventGoToLogin();
}

class AppEventGoToNoNeighborhoodView extends AppEvent {
  const AppEventGoToNoNeighborhoodView();
}

// AUTHENTICATION EVENTS
class AppEventRegisterWithEmailAndPassword extends AppEvent {
  final String email;
  final String password;
  final String passwordConfirmation;
  const AppEventRegisterWithEmailAndPassword(
      this.email, this.password, this.passwordConfirmation);
}

class AppEventSendEmailVerification extends AppEvent {
  const AppEventSendEmailVerification();
}

class AppEventLogInWithEmailAndPassword extends AppEvent {
  final String email;
  final String password;
  const AppEventLogInWithEmailAndPassword(
    this.email,
    this.password,
  );
}

class AppEventLogOut extends AppEvent {
  const AppEventLogOut();
}

class AppEventDeleteAccount extends AppEvent {
  final String password;
  const AppEventDeleteAccount({required this.password});
}

class AppEventConfirmUserIsVerified extends AppEvent {
  const AppEventConfirmUserIsVerified();
}

class AppEventSendPasswordResetEmail extends AppEvent {
  final String email;
  const AppEventSendPasswordResetEmail(this.email);
}

//NEIGHBORHOOD REGISTRATION EVENTS
class AppEventCreateCloudUser extends AppEvent {
  final String displayName;
  const AppEventCreateCloudUser({
    required this.displayName,
  });
}

class AppEventUpdateHomeAddress extends AppEvent {
  final String country;
  final String state;
  final String municipality;
  final String neighborhood;
  final String postalCode;
  final String street;
  final String houseNumber;
  final String? interior;
  final double? latitude;
  final double? longitude;
  const AppEventUpdateHomeAddress({
    required this.country,
    required this.state,
    required this.municipality,
    required this.neighborhood,
    required this.postalCode,
    required this.street,
    required this.houseNumber,
    required this.interior,
    required this.latitude,
    required this.longitude,
  });
}

class AppEventConfirmAddress extends AppEvent {
  final Address address;
  const AppEventConfirmAddress({required this.address});
}

class AppEventExitHousehold extends AppEvent {
  const AppEventExitHousehold();
}

class AppEventLookForNeighborhood extends AppEvent {
  const AppEventLookForNeighborhood();
}

class AppEventUpdateUserDisplayName extends AppEvent {
  final String displayName;
  const AppEventUpdateUserDisplayName({required this.displayName});
}

//NEIGHBORHOOD ROUTING EVENTS
class AppEventGoToNeighborhoodView extends AppEvent {
  const AppEventGoToNeighborhoodView();
}

class AppEventGoToProfileView extends AppEvent {
  const AppEventGoToProfileView();
}

class AppEventGoToHouseholdView extends AppEvent {
  final Household household;
  const AppEventGoToHouseholdView({
    required this.household,
  });
}

class AppEventGoToNeighborhoodDetailsView extends AppEvent {
  final Neighborhood neighborhood;
  const AppEventGoToNeighborhoodDetailsView({required this.neighborhood});
}

class AppEventGoToSettingsView extends AppEvent {
  const AppEventGoToSettingsView();
}

class AppEventGoToDeleteAccountView extends AppEvent {
  const AppEventGoToDeleteAccountView();
}

// PROFILE PHOTO EVENTS
class AppEventDeleteProfilePhoto extends AppEvent {
  const AppEventDeleteProfilePhoto();
}

class AppEventUpdateProfilePhoto extends AppEvent {
  final String imagePath;
  const AppEventUpdateProfilePhoto({required this.imagePath});
}

// RULEBOOK ROUTING EVENTS
class AppEventGoToRulebooksView extends AppEvent {
  const AppEventGoToRulebooksView();
}

class AppEventGoToEditRulebookView extends AppEvent {
  final Rulebook? rulebook;
  const AppEventGoToEditRulebookView({this.rulebook});
}

class AppEventGoToRulebookDetailsView extends AppEvent {
  final Rulebook rulebook;
  const AppEventGoToRulebookDetailsView({required this.rulebook});
}

// RULEBOOK EVENTS
class AppEventCreateOrUpdateRulebook extends AppEvent {
  final String title;
  final String text;
  const AppEventCreateOrUpdateRulebook({
    required this.title,
    required this.text,
  });
}

class AppEventDeleteRulebook extends AppEvent {
  const AppEventDeleteRulebook();
}

// EVENT EVENTS
class AppEventCreateOrUpdateEvent extends AppEvent {
  final String? eventId;
  final String? title;
  final String? text;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final String? placeName;
  final LatLng? location;
  const AppEventCreateOrUpdateEvent({
    required this.eventId,
    required this.title,
    required this.text,
    required this.dateStart,
    required this.dateEnd,
    required this.placeName,
    required this.location,
  });
}

class AppEventDeleteEvent extends AppEvent {
  final String eventId;
  const AppEventDeleteEvent({required this.eventId});
}

// POSTS ROUTING EVENTS
class AppEventGoToPostsView extends AppEvent {
  const AppEventGoToPostsView();
}

class AppEventGoToPostDetailsView extends AppEvent {
  final Post post;
  const AppEventGoToPostDetailsView({required this.post});
}

class AppEventGoToCreatePostView extends AppEvent {
  const AppEventGoToCreatePostView();
}

// POSTS EVENTS

class AppEventCreatePost extends AppEvent {
  final String text;
  const AppEventCreatePost({required this.text});
}

class AppEventUpdatePost extends AppEvent {
  final Post post;
  const AppEventUpdatePost({required this.post});
}

class AppEventDeletePost extends AppEvent {
  final Post post;
  const AppEventDeletePost({required this.post});
}

class AppEventLikePost extends AppEvent {
  final String postId;
  const AppEventLikePost({required this.postId});
}

class AppEventUnlikePost extends AppEvent {
  final String postId;
  const AppEventUnlikePost({required this.postId});
}
