import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventRegisterWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;
  final String passwordConfirmation;
  const AuthEventRegisterWithEmailAndPassword(
      this.email, this.password, this.passwordConfirmation);
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventLogInWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogInWithEmailAndPassword(
    this.email,
    this.password,
  );
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventDeleteAccount extends AuthEvent {
  const AuthEventDeleteAccount();
}

class AuthEventUserChanges extends AuthEvent {
  const AuthEventUserChanges();
}

class AuthEventConfirmUserIsVerified extends AuthEvent {
  const AuthEventConfirmUserIsVerified();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({String? email}) : email = email ?? '';
}

class AuthEventSendPasswordResetEmail extends AuthEvent {
  final String email;
  const AuthEventSendPasswordResetEmail(this.email);
}
