import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:vecinapp/services/auth/auth_user.dart';

@immutable
abstract class AppState {
  final bool isLoading;
  final String? loadingText;
  const AppState({
    required this.isLoading,
    this.loadingText,
  });
}

//login states
class AppStateUnInitalized extends AppState {
  const AppStateUnInitalized({required bool isLoading})
      : super(isLoading: isLoading);
}

class AppStateRegistering extends AppState with EquatableMixin {
  final Exception? exception;
  const AppStateRegistering({
    required this.exception,
    required bool isLoading,
  }) : super(isLoading: isLoading);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateLoggedIn extends AppState with EquatableMixin {
  final AuthUser user;
  final Exception? exception;
  const AppStateLoggedIn({
    required this.user,
    required this.exception,
    required bool isLoading,
  }) : super(isLoading: isLoading);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateNeedsVerification extends AppState with EquatableMixin {
  final AuthUser user;
  final Exception? exception;
  const AppStateNeedsVerification({
    required this.user,
    required bool isLoading,
    required this.exception,
  }) : super(
          isLoading: isLoading,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateLoggingIn extends AppState with EquatableMixin {
  final Exception? exception;
  const AppStateLoggingIn({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateResettingPassword extends AppState {
  final Exception? exception;
  final bool hasSentEmail;
  final String? email;
  const AppStateResettingPassword({
    required this.exception,
    required this.hasSentEmail,
    required bool isLoading,
    this.email,
  }) : super(isLoading: isLoading);
}
