import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/auth_user.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/cloud/cloud_provider.dart';
import 'package:vecinapp/services/cloud/cloud_exceptions.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';
import 'package:vecinapp/services/storage/storage_provider.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthProvider _authProvider;
  final CloudProvider _cloudProvider;
  final StorageProvider _storageProvider;
  AppBloc({
    required AuthProvider authProvider,
    required CloudProvider cloudProvider,
    required StorageProvider storageProvider,
  })  : _authProvider = authProvider,
        _cloudProvider = cloudProvider,
        _storageProvider = storageProvider,
        super(const AppStateUnInitalized(
          isLoading: true,
        )) {
    //initialize
    on<AppEventInitialize>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(
          const AppStateRegistering(
            exception: null,
            isLoading: false,
          ),
        );
        return;
      }

      if (!user.isEmailVerified) {
        emit(AppStateNeedsVerification(
          exception: null,
          isLoading: false,
        ));
        return;
      }

      final cloudUser = await _cloudProvider.currentCloudUser;

      if (cloudUser == null || cloudUser.username == null) {
        emit(const AppStateCreatingCloudUser(
          isLoading: false,
          exception: null,
        ));
        return;
      }

      if (cloudUser.householdId == null) {
        emit(const AppStateSelectingHomeAddress(
          isLoading: false,
          exception: null,
        ));
        return;
      }

      if (cloudUser.neighborhoodId == null) {
        emit(const AppStateNoNeighborhood(
          isLoading: false,
          exception: null,
        ));
        return;
      }
      emit(const AppStateViewingNeighborhood(
        exception: null,
        isLoading: false,
      ));
    });

    //Authentication Routing Events
    on<AppEventGoToRegistration>((event, emit) async {
      emit(const AppStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });

    on<AppEventGoToForgotPassword>((event, emit) async {
      emit(AppStateResettingPassword(
        email: event.email,
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));
    });

    on<AppEventLogOut>((event, emit) async {
      _authProvider.logOut();
      emit(const AppStateLoggingIn(
        exception: null,
        isLoading: false,
      ));
    });

    //Authentication Events
    on<AppEventRegisterWithEmailAndPassword>((event, emit) async {
      final email = event.email;
      final password = event.password;
      final passwordConfirmation = event.passwordConfirmation;
      try {
        emit(const AppStateRegistering(
          exception: null,
          isLoading: true,
        ));
        await _authProvider.createUser(
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
        await _authProvider.sendEmailVerification();
      } on AuthException catch (e) {
        emit(AppStateRegistering(
          exception: e,
          isLoading: false,
        ));
        return;
      }
      emit(AppStateNeedsVerification(
        exception: null,
        isLoading: false,
      ));
    });

    on<AppEventSendEmailVerification>((event, emit) async {
      await _authProvider.sendEmailVerification();
      emit(state);
    });

    on<AppEventConfirmUserIsVerified>((event, emit) async {
      try {
        await _authProvider.confirmUserIsVerified();
        emit(const AppStateCreatingCloudUser(
          exception: null,
          isLoading: false,
        ));
      } on AuthException catch (e) {
        if (e is UserNotVerifiedAuthException) {
          emit(
            AppStateNeedsVerification(
              isLoading: false,
              exception: e,
            ),
          );
        } else if (e is NetworkRequestFailedAuthException) {
          emit(
            AppStateNeedsVerification(
              isLoading: false,
              exception: e,
            ),
          );
        } else if (e is GenericAuthException) {
          emit(
            AppStateNeedsVerification(
              isLoading: false,
              exception: e,
            ),
          );
        } else if (e is UserNotLoggedInAuthException) {
          emit(
            AppStateLoggingIn(
              exception: e,
              isLoading: false,
            ),
          );
        }
      }
    });

    on<AppEventLogInWithEmailAndPassword>((event, emit) async {
      try {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: true,
          loadingText: 'Entrando...',
        ));
        final email = event.email;
        final password = event.password;
        final user = await _authProvider.logInWithEmailAndPassword(
          email: email,
          password: password,
        );
        //disable loading
        emit(
          const AppStateLoggingIn(
            exception: null,
            isLoading: false,
          ),
        );
        //check if email is verified
        if (!user.isEmailVerified) {
          emit(AppStateNeedsVerification(
            exception: null,
            isLoading: false,
          ));
        } else {
          emit(const AppStateViewingNeighborhood(
            exception: null,
            isLoading: false,
          ));
        }
      } on AuthException catch (e) {
        emit(
          AppStateLoggingIn(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });

    on<AppEventDeleteAccount>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      emit(const AppStateDeletingAccount(
        isLoading: true,
        exception: null,
        loadingText: 'Eliminando cuenta...',
      ));
      try {
        await _authProvider.logInWithEmailAndPassword(
          email: user.email!,
          password: event.password,
        );
        await _storageProvider.deleteProfileImage(userId: user.uid!);
        await _cloudProvider.deleteCloudUser();
        await _authProvider.deleteAccount();
      } catch (e) {
        emit(AppStateDeletingAccount(
          isLoading: false,
          exception: e,
        ));
        return;
      }
      emit(const AppStateLoggingIn(
        exception: null,
        isLoading: false,
      ));
    });

    on<AppEventSendPasswordResetEmail>((event, emit) async {
      try {
        emit(AppStateResettingPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: true,
          email: event.email,
        ));
        await _authProvider.sendPasswordResetEmail(email: event.email);
        emit(AppStateResettingPassword(
          email: event.email,
          exception: null,
          hasSentEmail: true,
          isLoading: false,
        ));
      } on AuthException catch (e) {
        emit(AppStateResettingPassword(
          email: null,
          exception: e,
          hasSentEmail: false,
          isLoading: false,
        ));
      }
    });

    //Neighborhood Routing
    on<AppEventGoToNeighborhoodView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
      } else {
        emit(const AppStateViewingNeighborhood(
          isLoading: false,
          exception: null,
        ));
      }
    });

    on<AppEventGoToProfileView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      final cloudUser = await _cloudProvider.cachedCloudUser;
      emit(AppStateViewingProfile(
        cloudUser: cloudUser!,
        user: user,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToSettingsView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      emit(const AppStateViewingSettings(
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToRulebooksView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      emit(AppStateViewingRulebooks(
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToEditRulebookView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      emit(AppStateEditingRulebook(
        rulebook: event.rulebook,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToRulebookDetailsView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      emit(AppStateViewingRulebookDetails(
        rulebook: event.rulebook,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToDeleteAccountView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      emit(const AppStateDeletingAccount(
        isLoading: false,
        exception: null,
      ));
    });

    //Cloud Events
    on<AppEventCreateCloudUser>((event, emit) async {
      //check if user is logged in
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      //enable loading indicator
      emit(AppStateCreatingCloudUser(
        isLoading: true,
        exception: null,
      ));
      //create new cloud user
      try {
        await _cloudProvider.createCloudUser(
          username: event.username,
          displayName: event.displayName,
        );
      } catch (e) {
        //inform user of error
        emit(AppStateCreatingCloudUser(
          isLoading: false,
          exception: e,
        ));
        return;
      }
      //send to selecting home address
      emit(const AppStateSelectingHomeAddress(
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventUpdateHomeAddress>(
      (event, emit) async {
        //check if user is logged in
        final user = _authProvider.currentUser;
        if (user == null) {
          emit(const AppStateLoggingIn(
            exception: null,
            isLoading: false,
          ));
          return;
        }
        //enable loading indicator
        emit(AppStateSelectingHomeAddress(
          isLoading: true,
          exception: null,
        ));
        //todo: check if address is valid and get full address from geocoding
        final String fullAddress =
            '${event.street} #${event.number}. ${event.municipality}, ${event.state}, ${event.country}';
        final String addressLine1 = '${event.street} #${event.number}';
        final String groupname = event.street;
        final String? interior = event.interior;
        final double latitude = event.latitude;
        final double longitude = event.longitude;
        //change the user's household
        try {
          await _cloudProvider.changeHousehold(
            fullAddress: fullAddress,
            addressLine1: addressLine1,
            groupname: groupname,
            interior: interior,
            latitude: latitude,
            longitude: longitude,
          );
        } catch (e) {
          //inform user of error
          emit(AppStateSelectingHomeAddress(
            isLoading: false,
            exception: e,
          ));
          return;
        }
        final updatedCloudUser = await _cloudProvider.currentCloudUser;
        //if the user has a neighborhood, send to viewing neighborhood
        if (updatedCloudUser!.neighborhoodId != null) {
          emit(AppStateViewingNeighborhood(
            isLoading: false,
            exception: null,
          ));
        } else {
          //Send No Neighborhood (this view should try to find a neighborhood for the user's home)
          emit(const AppStateNoNeighborhood(
            isLoading: false,
            exception: null,
          ));
        }
      },
    );

    on<AppEventLookForNeighborhood>((event, emit) async {
      //check if user is logged in
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      //enable loading indicator
      emit(AppStateNoNeighborhood(
        isLoading: true,
        exception: null,
      ));
      //change the user's neighborhood
      try {
        await _cloudProvider.assignNeighborhood();
      } catch (_) {
        //inform user of error
        emit(AppStateNoNeighborhood(
          isLoading: false,
          exception: null,
        ));
        return;
      }
      //send to viewing neighborhood
      emit(AppStateViewingNeighborhood(
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventUpdateUserDisplayName>((event, emit) async {
      //check if user is logged in
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      //check if user is logged in to cloud
      final cloudUser = await _cloudProvider.cachedCloudUser;
      if (cloudUser == null) {
        emit(const AppStateCreatingCloudUser(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      //start loading
      emit(AppStateViewingProfile(
        cloudUser: cloudUser,
        user: user,
        exception: null,
        isLoading: true,
      ));

      //update display name
      try {
        await _cloudProvider.updateUserDisplayName(
          displayName: event.displayName,
        );
      } catch (e) {
        //notify user of error
        emit(AppStateViewingProfile(
          cloudUser: cloudUser,
          user: user,
          exception: e,
          isLoading: false,
        ));
        return;
      }
      //notify user of success
      final updatedUser = await _cloudProvider.currentCloudUser;

      emit(AppStateViewingProfile(
        cloudUser: updatedUser!,
        user: user,
        exception: null,
        isLoading: false,
      ));
    });

    on<AppEventCreateOrUpdateRulebook>((event, emit) async {
      //check if user is logged in
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      //enable loading indicator
      emit(AppStateEditingRulebook(
        rulebook: state.rulebook,
        isLoading: true,
        exception: null,
      ));
      //check if rulebook is provided
      late Rulebook newRulebook;
      if (state.rulebook != null) {
        try {
          //update existing rulebook
          await _cloudProvider.updateRulebook(
            rulebookId: state.rulebook!.id,
            title: event.title,
            text: event.text,
          );
          newRulebook = state.rulebook!.copyWith(
            newTitle: event.title,
            newText: event.text,
          );
        } catch (e) {
          //inform user of error
          emit(AppStateEditingRulebook(
            rulebook: state.rulebook,
            isLoading: false,
            exception: e,
          ));
          return;
        }
      } else {
        //create new rulebook
        try {
          newRulebook = await _cloudProvider.createNewRulebook(
            title: event.title,
            text: event.text,
          );
        } catch (e) {
          //inform user of error
          emit(AppStateEditingRulebook(
            rulebook: null,
            isLoading: false,
            exception: e,
          ));
          return;
        }
      }
      //Send user to rulebook details view
      emit(AppStateViewingRulebookDetails(
        rulebook: newRulebook,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventDeleteRulebook>((event, emit) async {
      //check if user is logged in
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      //enable loading indicator
      emit(AppStateViewingRulebookDetails(
        rulebook: state.rulebook!,
        isLoading: true,
        exception: null,
      ));
      try {
        await _cloudProvider.deleteRulebook(
          rulebookId: state.rulebook!.id,
        );
      } on CloudException catch (e) {
        emit(AppStateViewingRulebookDetails(
          rulebook: state.rulebook!,
          isLoading: false,
          exception: e,
        ));
        return;
      } on Exception catch (e) {
        emit(AppStateViewingRulebookDetails(
          rulebook: state.rulebook!,
          isLoading: false,
          exception: e,
        ));
        return;
      }
      //Send user to rulebooks view
      emit(AppStateViewingRulebooks(
        isLoading: false,
        exception: null,
      ));
    });

    //Storage events
    on<AppEventUpdateProfilePhoto>((event, emit) async {
      //check if user is logged in
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      //check if user has a cloud user
      final cloudUser = await _cloudProvider.cachedCloudUser;
      if (cloudUser == null) {
        emit(const AppStateCreatingCloudUser(
          isLoading: false,
          exception: null,
        ));
        return;
      }
      //start loading
      emit(AppStateViewingProfile(
        cloudUser: cloudUser,
        user: user,
        exception: null,
        isLoading: true,
        loadingText: 'Subiendo imagen...',
      ));

      //upload image
      try {
        final File image = File(event.imagePath);
        await _storageProvider.uploadProfileImage(
          image: image,
          userId: user.uid!,
        );
      } catch (e) {
        emit(AppStateViewingProfile(
          cloudUser: cloudUser,
          user: user,
          exception: e,
          isLoading: false,
        ));
        return;
      }
      emit(AppStateViewingProfile(
        cloudUser: cloudUser,
        user: user,
        exception: null,
        isLoading: false,
      ));
    });

    on<AppEventDeleteProfilePhoto>(
      (event, emit) async {
        //check if user is logged in
        final user = _authProvider.currentUser;
        if (user == null) {
          emit(const AppStateLoggingIn(
            exception: null,
            isLoading: false,
          ));
          return;
        }
        //check if user has a cloud user
        final cloudUser = await _cloudProvider.cachedCloudUser;
        if (cloudUser == null) {
          emit(const AppStateCreatingCloudUser(
            isLoading: false,
            exception: null,
          ));
          return;
        }
        //start loading
        emit(AppStateViewingProfile(
          cloudUser: cloudUser,
          user: user,
          exception: null,
          isLoading: true,
          loadingText: 'Eliminando imagen...',
        ));

        try {
          await _storageProvider.deleteProfileImage(userId: user.uid!);
        } catch (e) {
          emit(AppStateViewingProfile(
            cloudUser: cloudUser,
            user: user,
            exception: e,
            isLoading: false,
          ));
        }

        emit(AppStateViewingProfile(
          cloudUser: cloudUser,
          user: user,
          exception: null,
          isLoading: false,
        ));
      },
    );
  }

  Stream<Uint8List?> profilePicture() async* {
    final user = _authProvider.currentUser;
    if (user == null) {
      yield null;
    }
    try {
      yield await _storageProvider.getProfileImage(userId: user!.uid!);
    } catch (e) {
      yield null;
    }
  }

  Stream<AuthUser> get userStream => _authProvider.userChanges();

  Stream<Iterable<Rulebook>> get rulebooks async* {
    final cloudUSer = await _cloudProvider.cachedCloudUser;
    yield* _cloudProvider.neighborhoodRulebooks(
      neighborhoodId: cloudUSer!.neighborhoodId!,
    );
  }
}
