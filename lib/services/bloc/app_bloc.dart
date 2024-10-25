import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
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

      final cloudUser = _cloudProvider.currentUser;

      if (cloudUser == null) {
        emit(const AppStateCreatingCloudUser(
          isLoading: false,
          exception: null,
        ));
        return;
      }

      if (cloudUser.homeId == null) {
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
      emit(const AppStateViewingHome(
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
          emit(const AppStateViewingHome(
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
      ));
      try {
        await _authProvider.logInWithEmailAndPassword(
          email: user.email!,
          password: event.password,
        );
        await _authProvider.deleteAccount();
      } on AuthException catch (e) {
        emit(AppStateDeletingAccount(
          isLoading: false,
          exception: e,
        ));
        return;
      } catch (_) {
        emit(AppStateDeletingAccount(
          isLoading: false,
          exception: GenericAuthException(),
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

    on<AppEventUpdateUserDisplayName>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
        return;
      }
      emit(AppStateViewingProfile(
        user: user,
        exception: null,
        isLoading: true,
      ));

      try {
        await _authProvider.updateUserDisplayName(event.displayName);
      } on AuthException catch (e) {
        emit(AppStateViewingProfile(
          user: user,
          exception: e,
          isLoading: false,
        ));
        return;
      }

      final updatedUser = _authProvider.currentUser!;
      emit(AppStateViewingProfile(
        user: updatedUser,
        exception: null,
        isLoading: false,
      ));
    });

    //Main App Routing
    on<AppEventGoToHomeView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
      } else {
        emit(const AppStateViewingHome(
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
      emit(AppStateViewingProfile(
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
      final rulebooks = _cloudProvider.allRulebooks(ownerUserId: user.uid!);
      emit(AppStateViewingRulebooks(
        rulebooks: rulebooks,
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
      late final Rulebook newRulebook;
      try {
        if (state.rulebook != null) {
          //update rulebook if provided
          await _cloudProvider.updateRulebook(
            rulebookId: state.rulebook!.id,
            title: event.title,
            text: event.text,
          );
          newRulebook = state.rulebook!.copyWith(
            newTitle: event.title,
            newText: event.text,
          );
        } else {
          //create new rulebook if not provided
          newRulebook = await _cloudProvider.createNewRulebook(
            ownerUserId: user.uid!,
            title: event.title,
            text: event.text,
          );
        }
      } on CloudException catch (e) {
        emit(AppStateEditingRulebook(
          rulebook: state.rulebook,
          isLoading: false,
          exception: e,
        ));
        return;
      } on Exception catch (e) {
        emit(AppStateEditingRulebook(
          rulebook: state.rulebook,
          isLoading: false,
          exception: e,
        ));
        return;
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
        rulebooks: _cloudProvider.allRulebooks(ownerUserId: user.uid!),
        isLoading: false,
        exception: null,
      ));
    });

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

      //start loading
      emit(AppStateViewingProfile(
        user: user,
        exception: null,
        isLoading: true,
        loadingText: 'Subiendo imagen...',
      ));

      try {
        final File image = File(event.imagePath);
        await _storageProvider.uploadProfileImage(
          image: image,
          userId: user.uid!,
        );
      } catch (e) {
        emit(AppStateViewingProfile(
          user: user,
          exception: e,
          isLoading: false,
        ));
        return;
      }
      emit(AppStateViewingProfile(
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

        //start loading
        emit(AppStateViewingProfile(
          user: user,
          exception: null,
          isLoading: true,
          loadingText: 'Eliminando imagen...',
        ));

        try {
          await _storageProvider.deleteProfileImage(userId: user.uid!);
        } catch (e) {
          emit(AppStateViewingProfile(
            user: user,
            exception: e,
            isLoading: false,
          ));
        }

        emit(AppStateViewingProfile(
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
      return;
    }
    try {
      yield await _storageProvider.getProfileImage(userId: user.uid!);
    } catch (e) {
      yield null;
    }
  }
}
