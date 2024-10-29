import 'package:flutter/foundation.dart' show immutable;
import 'package:vecinapp/services/cloud/rulebook.dart';

@immutable
abstract class AppEvent {
  const AppEvent();
}

class AppEventInitialize extends AppEvent {
  const AppEventInitialize();
}

// AUTHENTICATION ROUTING EVENTS
class AppEventGoToRegistration extends AppEvent {
  const AppEventGoToRegistration();
}

class AppEventGoToForgotPassword extends AppEvent {
  final String? email;
  const AppEventGoToForgotPassword({String? email}) : email = email ?? '';
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

class AppEventUserChanges extends AppEvent {
  const AppEventUserChanges();
}

class AppEventConfirmUserIsVerified extends AppEvent {
  const AppEventConfirmUserIsVerified();
}

class AppEventSendPasswordResetEmail extends AppEvent {
  final String email;
  const AppEventSendPasswordResetEmail(this.email);
}

class AppEventUpdateUserDisplayName extends AppEvent {
  final String displayName;
  const AppEventUpdateUserDisplayName({required this.displayName});
}

// CLOUD REGISTRATION EVENTS
class AppEventCreateCloudUser extends AppEvent {
  final String displayName;
  final String username;
  const AppEventCreateCloudUser({
    required this.username,
    required this.displayName,
  });
}

class AppEventUpdateHomeAddress extends AppEvent {
  final String country;
  final String state;
  final String municipality;
  final String postalCode;
  final String street;
  final String number;
  final String? interior;
  final double latitude;
  final double longitude;
  const AppEventUpdateHomeAddress({
    required this.country,
    required this.state,
    required this.municipality,
    required this.postalCode,
    required this.street,
    required this.number,
    required this.interior,
    required this.latitude,
    required this.longitude,
  });
}

class AppEventLookForNeighborhood extends AppEvent {
  const AppEventLookForNeighborhood();
}

// MAIN APP ROUTING EVENTS
class AppEventGoToHomeView extends AppEvent {
  const AppEventGoToHomeView();
}

class AppEventGoToProfileView extends AppEvent {
  const AppEventGoToProfileView();
}

class AppEventGoToSettingsView extends AppEvent {
  const AppEventGoToSettingsView();
}

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

class AppEventGoToDeleteAccountView extends AppEvent {
  const AppEventGoToDeleteAccountView();
}

// CLOUD EVENTS
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

class AppEventDeleteProfilePhoto extends AppEvent {
  const AppEventDeleteProfilePhoto();
}

class AppEventUpdateProfilePhoto extends AppEvent {
  final String imagePath;
  const AppEventUpdateProfilePhoto({required this.imagePath});
}
