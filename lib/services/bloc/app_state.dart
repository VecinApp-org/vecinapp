import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:vecinapp/services/auth/auth_user.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';

@immutable
abstract class AppState {
  final bool isLoading;
  final Exception? exception;
  final String? loadingText;
  final AuthUser? user;
  const AppState({
    required this.isLoading,
    required this.exception,
    this.user,
    this.loadingText,
  });
}

class AppStateUnInitalized extends AppState {
  const AppStateUnInitalized({required bool isLoading})
      : super(
          isLoading: isLoading,
          exception: null,
        );
}

//AUTHENTICATION STATES
class AppStateRegistering extends AppState with EquatableMixin {
  const AppStateRegistering({
    required exception,
    required bool isLoading,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateNeedsVerification extends AppState with EquatableMixin {
  final AuthUser user;
  const AppStateNeedsVerification({
    required this.user,
    required bool isLoading,
    required exception,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateLoggingIn extends AppState with EquatableMixin {
  const AppStateLoggingIn({
    required exception,
    required bool isLoading,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateResettingPassword extends AppState {
  final bool hasSentEmail;
  final String? email;
  const AppStateResettingPassword({
    required exception,
    required this.hasSentEmail,
    required bool isLoading,
    this.email,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );
}

//MAIN APP STATES
class AppStateViewingHome extends AppState with EquatableMixin {
  final AuthUser user;
  const AppStateViewingHome({
    required this.user,
    required exception,
    required bool isLoading,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateViewingSettings extends AppState {
  const AppStateViewingSettings({
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);
}

class AppStateViewingRulebooks extends AppState {
  final Stream<Iterable<Rulebook>> rulebooks;
  const AppStateViewingRulebooks({
    required this.rulebooks,
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);
}

class AppStateEditingRulebook extends AppState {
  final Rulebook rulebook;
  const AppStateEditingRulebook({
    required this.rulebook,
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);
}

class AppStateViewingRulebook extends AppState {
  final Rulebook rulebook;
  const AppStateViewingRulebook({
    required this.rulebook,
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);
}

//EXTENSIONS
extension GetUser on AppState {
  AuthUser? get user {
    return this.user;
  }
}
