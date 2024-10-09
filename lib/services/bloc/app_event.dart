import 'package:flutter/foundation.dart' show immutable;

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
  const AppEventDeleteAccount();
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

// MAIN APP ROUTING EVENTS
class AppEventGoToHomeView extends AppEvent {
  const AppEventGoToHomeView();
}

class AppEventGoToRulebooksView extends AppEvent {
  const AppEventGoToRulebooksView();
}

class AppEventGoToSettingsView extends AppEvent {
  const AppEventGoToSettingsView();
}
