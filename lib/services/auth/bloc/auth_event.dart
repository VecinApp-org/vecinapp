import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogInWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogInWithEmailAndPassword(this.email, this.password);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventSendEmailVerification extends AuthEvent {
  final String email;
  const AuthEventSendEmailVerification(this.email);
}

class AuthEventRegisterWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;
  final String passwordConfirmation;
  const AuthEventRegisterWithEmailAndPassword(
      this.email, this.password, this.passwordConfirmation);
}

class AuthEventDeleteAccount extends AuthEvent {
  const AuthEventDeleteAccount();
}
