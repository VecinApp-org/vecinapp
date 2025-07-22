import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:vecinapp/utilities/entities/auth_user.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
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

class AppStateError extends AppState with EquatableMixin {
  const AppStateError({
    required Exception? exception,
    required bool isLoading,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );
  @override
  List<Object?> get props => [exception, isLoading];
}

//AUTHENTICATION STATES
class AppStateLoggedOut extends AppState with EquatableMixin {
  const AppStateLoggedOut({
    required bool isLoading,
    required String? loadingText,
    AuthUser? user,
    required exception,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          loadingText: loadingText,
          user: user,
        );

  @override
  List<Object?> get props => [exception, isLoading, loadingText, user];
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

class AppStateConfirmingHomeAddress extends AppState with EquatableMixin {
  final List<Address> addresses;
  const AppStateConfirmingHomeAddress({
    required bool isLoading,
    required exception,
    required this.addresses,
  }) : super(isLoading: isLoading, exception: exception);

  @override
  List<Object?> get props => [exception, isLoading, addresses];
}

class AppStateNoNeighborhood extends AppState with EquatableMixin {
  const AppStateNoNeighborhood({
    required bool isLoading,
    required String? loadingText,
    required exception,
    required CloudUser cloudUser,
    required Household household,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
          exception: exception,
          cloudUser: cloudUser,
          household: household,
        );

  @override
  List<Object?> get props =>
      [exception, isLoading, loadingText, cloudUser, household];
}

class AppStateWelcomeToNeighborhood extends AppState with EquatableMixin {
  const AppStateWelcomeToNeighborhood({required bool isLoading})
      : super(isLoading: isLoading, exception: null);

  @override
  List<Object?> get props => [exception, isLoading];
}

//MAIN APP STATES
class AppStateNeighborhood extends AppState with EquatableMixin {
  const AppStateNeighborhood({
    required bool isLoading,
    required exception,
    required String? loadingText,
    required CloudUser cloudUser,
    required Household household,
    required Neighborhood neighborhood,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
          exception: exception,
          cloudUser: cloudUser,
          neighborhood: neighborhood,
          household: household,
        );

  @override
  List<Object?> get props =>
      [exception, isLoading, loadingText, cloudUser, neighborhood, household];
}

//EXTENSIONS
extension GetAddresses on AppState {
  List<Address>? get addresses {
    if (this is AppStateConfirmingHomeAddress) {
      return (this as AppStateConfirmingHomeAddress).addresses;
    }
    return null;
  }
}
