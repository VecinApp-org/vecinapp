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

class AppStateViewingProfile extends AppState {
  const AppStateViewingProfile({
    required AuthUser user,
    required bool isLoading,
    required exception,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          user: user,
        );
  @override
  String toString() {
    return 'AppStateViewingProfile{user: $user, isLoading: $isLoading, exception: $exception}';
  }
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
  final Rulebook? rulebook;
  const AppStateEditingRulebook({
    this.rulebook,
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);
}

class AppStateViewingRulebookDetails extends AppState {
  final Rulebook rulebook;
  const AppStateViewingRulebookDetails({
    required this.rulebook,
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);
}

class AppStateDeletingAccount extends AppState {
  const AppStateDeletingAccount({
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);
}

//EXTENSIONS
extension GetRulebook on AppState {
  Rulebook? get rulebook {
    if (this is AppStateEditingRulebook) {
      return (this as AppStateEditingRulebook).rulebook;
    }
    if (this is AppStateViewingRulebookDetails) {
      return (this as AppStateViewingRulebookDetails).rulebook;
    }
    return null;
  }
}
