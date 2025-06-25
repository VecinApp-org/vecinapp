import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:vecinapp/utilities/entities/auth_user.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:vecinapp/utilities/entities/address.dart';

@immutable
abstract class AppState {
  final bool isLoading;
  final Exception? exception;
  final String? loadingText;
  final AuthUser? user;
  final CloudUser? cloudUser;
  final Household? household;
  final Neighborhood? neighborhood;
  const AppState({
    required this.isLoading,
    required this.exception,
    this.user,
    this.loadingText,
    this.cloudUser,
    this.household,
    this.neighborhood,
  });
}

class AppStateUnInitalized extends AppState {
  const AppStateUnInitalized({required bool isLoading})
      : super(
          isLoading: isLoading,
          exception: null,
        );
}

class AppStateError extends AppState {
  const AppStateError({
    required exception,
    required bool isLoading,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );
}

//AUTHENTICATION STATES
class AppStateWelcomeViewing extends AppState with EquatableMixin {
  const AppStateWelcomeViewing({
    required bool isLoading,
    required exception,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

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

class AppStateConfirmingHomeAddress extends AppState {
  final List<Address> addresses;
  const AppStateConfirmingHomeAddress({
    required bool isLoading,
    required exception,
    required this.addresses,
  }) : super(isLoading: isLoading, exception: exception);
}

class AppStateNoNeighborhood extends AppState with EquatableMixin {
  const AppStateNoNeighborhood({
    required bool isLoading,
    required exception,
    required CloudUser cloudUser,
    required Household household,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          cloudUser: cloudUser,
          household: household,
        );

  @override
  List<Object?> get props => [exception, isLoading, cloudUser, household];
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
    required Household household,
    required Neighborhood neighborhood,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          cloudUser: cloudUser,
          neighborhood: neighborhood,
          household: household,
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
    required Household? household,
    required Neighborhood? neighborhood,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          user: user,
          loadingText: loadingText,
          cloudUser: cloudUser,
          household: household,
          neighborhood: neighborhood,
        );

  @override
  List<Object?> get props => [user, exception, isLoading, cloudUser];
  @override
  String toString() {
    return 'AppStateViewingProfile{user: $user, isLoading: $isLoading, exception: $exception}';
  }
}

class AppStateViewingHousehold extends AppState {
  const AppStateViewingHousehold({
    required bool isLoading,
    required exception,
    required Household household,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          household: household,
        );
}

class AppStateViewingNeighborhoodDetails extends AppState {
  const AppStateViewingNeighborhoodDetails({
    required bool isLoading,
    required exception,
    required Neighborhood neighborhood,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          neighborhood: neighborhood,
        );
}

class AppStateViewingSettings extends AppState {
  const AppStateViewingSettings({
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

//RULEBOOK STATES
class AppStateViewingRulebooks extends AppState {
  const AppStateViewingRulebooks(
      {required bool isLoading,
      required exception,
      required cloudUser,
      required neighborhood,
      required household})
      : super(
            isLoading: isLoading,
            exception: exception,
            cloudUser: cloudUser,
            neighborhood: neighborhood,
            household: household);
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
    required cloudUser,
    required isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception, cloudUser: cloudUser);
}

//EVENT STATES
class AppStateViewingEvents extends AppState {
  const AppStateViewingEvents({
    required bool isLoading,
    required exception,
    required cloudUser,
    required neighborhood,
    required household,
  }) : super(
            isLoading: isLoading,
            exception: exception,
            cloudUser: cloudUser,
            neighborhood: neighborhood,
            household: household);
}

class AppStateEditingEvent extends AppState {
  final Event? event;
  const AppStateEditingEvent({
    this.event,
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);
}

class AppStateViewingEventDetails extends AppState {
  final Event event;
  const AppStateViewingEventDetails({
    required this.event,
    required cloudUser,
    required isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception, cloudUser: cloudUser);
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

extension GetEvent on AppState {
  Event? get event {
    if (this is AppStateEditingEvent) {
      return (this as AppStateEditingEvent).event;
    }
    if (this is AppStateViewingEventDetails) {
      return (this as AppStateViewingEventDetails).event;
    }
    return null;
  }
}

extension GetAddresses on AppState {
  List<Address>? get addresses {
    if (this is AppStateConfirmingHomeAddress) {
      return (this as AppStateConfirmingHomeAddress).addresses;
    }
    return null;
  }
}
