import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:vecinapp/services/auth/auth_user.dart';
import 'package:vecinapp/services/cloud/cloud_user.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';

@immutable
abstract class AppState {
  final bool isLoading;
  final Exception? exception;
  final String? loadingText;
  final AuthUser? user;
  final CloudUser? cloudUser;
  const AppState({
    required this.isLoading,
    required this.exception,
    this.user,
    this.loadingText,
    this.cloudUser,
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
  const AppStateNeedsVerification({
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

//CLOUD REGISTRATION STATES
class AppStateCreatingCloudUser extends AppState with EquatableMixin {
  const AppStateCreatingCloudUser({
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateSelectingHomeAddress extends AppState with EquatableMixin {
  const AppStateSelectingHomeAddress({
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateNoNeighborhood extends AppState {
  const AppStateNoNeighborhood({required bool isLoading, required exception})
      : super(isLoading: isLoading, exception: exception);
}

class AppStateWelcomeToNeighborhood extends AppState {
  const AppStateWelcomeToNeighborhood({required bool isLoading})
      : super(isLoading: isLoading, exception: null);
}

//MAIN APP STATES
class AppStateViewingNeighborhood extends AppState with EquatableMixin {
  const AppStateViewingNeighborhood({
    required exception,
    required bool isLoading,
    required CloudUser cloudUser,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          cloudUser: cloudUser,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateViewingProfile extends AppState with EquatableMixin {
  const AppStateViewingProfile({
    required bool isLoading,
    required exception,
    required AuthUser user,
    required CloudUser cloudUser,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          user: user,
          loadingText: loadingText,
          cloudUser: cloudUser,
        );

  @override
  List<Object?> get props => [user, exception, isLoading, cloudUser];
  @override
  String toString() {
    return 'AppStateViewingProfile{user: $user, isLoading: $isLoading, exception: $exception}';
  }
}

class AppStateViewingHousehold extends AppState {
  final String householdId;
  const AppStateViewingHousehold({
    required bool isLoading,
    required exception,
    required this.householdId,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );
}

class AppStateChangingAddress extends AppState {
  const AppStateChangingAddress({
    required bool isLoading,
    required exception,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );
}

class AppStateViewingSettings extends AppState {
  const AppStateViewingSettings({
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);
}

class AppStateViewingRulebooks extends AppState {
  const AppStateViewingRulebooks({
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
    loadingText,
  }) : super(
            isLoading: isLoading,
            exception: exception,
            loadingText: loadingText);
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

extension GetHouseholdId on AppState {
  String? get householdId {
    if (this is AppStateViewingHousehold) {
      return (this as AppStateViewingHousehold).householdId;
    }
    return null;
  }
}
