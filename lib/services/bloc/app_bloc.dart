import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:vecinapp/extensions/geometry/is_point_in_polygon.dart';
import 'package:vecinapp/extensions/geometry/point.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/cloud/cloud_provider.dart';
import 'package:vecinapp/services/cloud/cloud_exceptions.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:vecinapp/utilities/entities/address.dart';
import 'package:vecinapp/services/geocoding/geocoding_exceptions.dart';
import 'package:vecinapp/services/geocoding/geocoding_provider.dart';
import 'package:vecinapp/services/storage/storage_provider.dart';
// ignore: unused_import
import 'dart:developer' as devtools show log;

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthProvider _authProvider;
  final CloudProvider _cloudProvider;
  final StorageProvider _storageProvider;
  final GeocodingProvider _geocodingProvider;
  AppBloc({
    required AuthProvider authProvider,
    required CloudProvider cloudProvider,
    required StorageProvider storageProvider,
    required GeocodingProvider geocodingProvider,
  })  : _authProvider = authProvider,
        _cloudProvider = cloudProvider,
        _storageProvider = storageProvider,
        _geocodingProvider = geocodingProvider,
        super(const AppStateUnInitalized(
          isLoading: true,
        )) {
    //initialize
    on<AppEventInitialize>((event, emit) async {
      add(AppEventReset());
    });

    on<AppEventReset>((event, emit) async {
      try {
        emit(const AppStateUnInitalized(
          isLoading: true,
        ));
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

        if (cloudUser == null) {
          emit(const AppStateCreatingCloudUser(
            isLoading: false,
            exception: null,
          ));
          return;
        }

        if (cloudUser.id != user.uid) {
          add(AppEventLogOut());
          return;
        }

        final household = await _cloudProvider.currentHousehold;
        if (household == null) {
          emit(const AppStateSelectingHomeAddress(
            isLoading: false,
            exception: null,
          ));
          return;
        }

        if (cloudUser.householdId != household.id) {
          add(AppEventLogOut());
          return;
        }

        final neighborhood = await _cloudProvider.currentNeighborhood;
        if (neighborhood == null) {
          emit(const AppStateNoNeighborhood(
            isLoading: false,
            exception: null,
          ));
          return;
        }

        if (cloudUser.neighborhoodId != neighborhood.id) {
          add(AppEventLogOut());
          return;
        }

        if (household.neighborhoodId != neighborhood.id) {
          add(AppEventExitHousehold());
          return;
        }

        final point = Point(x: household.latitude, y: household.longitude);
        if (Poly.isPointInPolygon(point, neighborhood.polygon) == false) {
          add(AppEventExitNeighborhood());
          return;
        }

        emit(AppStateViewingNeighborhood(
          cloudUser: cloudUser,
          exception: null,
          isLoading: false,
          neighborhood: neighborhood,
        ));
      } catch (e) {
        emit(AppStateError(
          exception: e,
          isLoading: false,
        ));
      }
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

    on<AppEventGoToLogin>((event, emit) async {
      emit(const AppStateLoggingIn(
        exception: null,
        isLoading: false,
      ));
    });

    on<AppEventLogOut>((event, emit) async {
      _authProvider.logOut();
      add(AppEventReset());
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
      add(AppEventReset());
    });

    on<AppEventSendEmailVerification>((event, emit) async {
      await _authProvider.sendEmailVerification();
      emit(state);
    });

    on<AppEventConfirmUserIsVerified>((event, emit) async {
      try {
        await _authProvider.confirmUserIsVerified();
      } on AuthException catch (e) {
        emit(AppStateNeedsVerification(
          exception: e,
          isLoading: false,
        ));
      }
      add(AppEventReset());
    });

    on<AppEventLogInWithEmailAndPassword>((event, emit) async {
      //show loading
      emit(const AppStateLoggingIn(
        exception: null,
        isLoading: true,
        loadingText: 'Entrando...',
      ));
      //log in
      try {
        final email = event.email;
        final password = event.password;
        await _authProvider.logInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on AuthException catch (e) {
        emit(
          AppStateLoggingIn(
            exception: e,
            isLoading: false,
          ),
        );
        return;
      }
      add(const AppEventReset());
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
      add(const AppEventReset());
    });

    on<AppEventSendPasswordResetEmail>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        add(const AppEventReset());
        return;
      }
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
      //check if user is logged in, verified, has a household and a neighborhood
      final user = _authProvider.currentUser;
      final cloudUser = await _cloudProvider.cachedCloudUser ??
          await _cloudProvider.currentCloudUser;
      final neighborhood = await _cloudProvider.cachedNeighborhood ??
          await _cloudProvider.currentNeighborhood;
      if (user == null ||
          !user.isEmailVerified ||
          cloudUser == null ||
          cloudUser.householdId == null ||
          cloudUser.neighborhoodId == null ||
          neighborhood == null) {
        add(const AppEventReset());
        return;
      }

      emit(AppStateViewingNeighborhood(
        cloudUser: cloudUser,
        isLoading: false,
        exception: null,
        neighborhood: neighborhood,
      ));
    });

    on<AppEventGoToProfileView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null || !user.isEmailVerified) {
        add(const AppEventReset());
        return;
      }
      final cloudUser = await _cloudProvider.cachedCloudUser ??
          await _cloudProvider.currentCloudUser;
      Household? household = await _cloudProvider.cachedHousehold ??
          await _cloudProvider.currentHousehold;
      emit(AppStateViewingProfile(
        cloudUser: cloudUser!,
        household: household,
        user: user,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToHouseholdView>((event, emit) async {
      final user = _authProvider.currentUser;
      final cloudUser = await _cloudProvider.cachedCloudUser ??
          await _cloudProvider.currentCloudUser;
      if (user == null ||
          !user.isEmailVerified ||
          cloudUser == null ||
          cloudUser.householdId == null) {
        add(const AppEventReset());
        return;
      }
      emit(AppStateViewingHousehold(
        household: event.household,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToSettingsView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null || !user.isEmailVerified) {
        add(const AppEventReset());
        return;
      }
      emit(const AppStateViewingSettings(
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToRulebooksView>((event, emit) async {
      if (!await isValidNeighborhoodAccess()) {
        add(const AppEventReset());
      }
      final cloudUser = await _cloudProvider.cachedCloudUser;
      emit(AppStateViewingRulebooks(
        isLoading: false,
        exception: null,
        cloudUser: cloudUser,
      ));
    });

    on<AppEventGoToEditRulebookView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null || !user.isEmailVerified) {
        add(const AppEventReset());
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
      if (user == null || !user.isEmailVerified) {
        add(const AppEventReset());
        return;
      }
      final cloudUser = await _cloudProvider.cachedCloudUser;
      emit(AppStateViewingRulebookDetails(
        rulebook: event.rulebook,
        isLoading: false,
        exception: null,
        cloudUser: cloudUser!,
      ));
    });

    on<AppEventGoToDeleteAccountView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null || !user.isEmailVerified) {
        add(const AppEventReset());
        return;
      }
      emit(const AppStateDeletingAccount(
        isLoading: false,
        exception: null,
      ));
    });

    //Cloud Events
    on<AppEventCreateCloudUser>((event, emit) async {
      //check if user is logged in and authenticated
      final user = _authProvider.currentUser;
      if (user == null || !user.isEmailVerified) {
        add(const AppEventReset());
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

        //check if address is valid and get full address from geocoding
        late final List<Address> validAddresses;
        try {
          validAddresses = await _geocodingProvider.getValidAddress(
            country: event.country,
            state: event.state,
            municipality: event.municipality,
            neighborhood: event.neighborhood,
            streetLine1: event.streetLine1,
            postalCode: event.postalCode,
            interior: event.interior,
            latitude: event.latitude,
            longitude: event.longitude,
          );
        } catch (e) {
          //inform user of error
          emit(AppStateSelectingHomeAddress(
            isLoading: false,
            exception: e,
          ));
          return;
        }
        //if there is no valid address, inform user
        if (validAddresses.isEmpty) {
          emit(AppStateSelectingHomeAddress(
            isLoading: false,
            exception: NoValidAddressFoundGeocodingException(),
          ));
          return;
        }
        //if there is more than one valid address, show them
        if (validAddresses.length > 1) {
          emit(AppStateConfirmingHomeAddress(
            isLoading: false,
            exception: null,
            addresses: validAddresses,
          ));
          return;
        }
        final validAddress = validAddresses.first;
        //change the user's household
        try {
          await _cloudProvider.updateHousehold(
            address: validAddress,
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
        final neighborhood = await _cloudProvider.currentNeighborhood;
        //if the user has a neighborhood, send to viewing neighborhood
        if (updatedCloudUser!.neighborhoodId != null) {
          emit(AppStateViewingNeighborhood(
            cloudUser: updatedCloudUser,
            isLoading: false,
            exception: null,
            neighborhood: neighborhood!,
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

    on<AppEventConfirmAddress>((event, emit) async {
      //start loading indicator
      emit(AppStateConfirmingHomeAddress(
        isLoading: true,
        exception: null,
        addresses: state.addresses!,
      ));
      //change the user's household
      try {
        await _cloudProvider.updateHousehold(
          address: event.address,
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
      final neighborhood = await _cloudProvider.currentNeighborhood;
      //if the user has a neighborhood, send to viewing neighborhood
      if (updatedCloudUser!.neighborhoodId != null) {
        emit(AppStateViewingNeighborhood(
          cloudUser: updatedCloudUser,
          isLoading: false,
          exception: null,
          neighborhood: neighborhood!,
        ));
      } else {
        //Send No Neighborhood (this view should try to find a neighborhood for the user's home)
        emit(const AppStateNoNeighborhood(
          isLoading: false,
          exception: null,
        ));
      }
    });

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
      final updatedCloudUser = await _cloudProvider.currentCloudUser;
      final neighborhood = await _cloudProvider.currentNeighborhood;
      emit(AppStateViewingNeighborhood(
        cloudUser: updatedCloudUser!,
        isLoading: false,
        exception: null,
        neighborhood: neighborhood!,
      ));
    });

    on<AppEventExitHousehold>((event, emit) async {
      try {
        await _cloudProvider.exitHousehold();
      } catch (_) {
        add(AppEventReset());
      }
      add(AppEventReset());
    });

    on<AppEventExitNeighborhood>((event, emit) async {
      try {
        await _cloudProvider.exitNeighborhood();
      } catch (_) {
        add(AppEventReset());
      }
      add(AppEventReset());
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
      final household = state.household;
      emit(AppStateViewingProfile(
        cloudUser: cloudUser,
        household: household,
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
          household: household,
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
        household: household,
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
      final cloudUser = await _cloudProvider.cachedCloudUser;
      emit(AppStateViewingRulebookDetails(
        rulebook: newRulebook,
        cloudUser: cloudUser!,
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
      final cloudUser = await _cloudProvider.cachedCloudUser;
      emit(AppStateViewingRulebookDetails(
        rulebook: state.rulebook!,
        isLoading: true,
        exception: null,
        cloudUser: cloudUser!,
      ));
      try {
        await _cloudProvider.deleteRulebook(
          rulebookId: state.rulebook!.id,
        );
      } on CloudException catch (e) {
        emit(AppStateViewingRulebookDetails(
          rulebook: state.rulebook!,
          cloudUser: cloudUser,
          isLoading: false,
          exception: e,
        ));
        return;
      } on Exception catch (e) {
        emit(AppStateViewingRulebookDetails(
          rulebook: state.rulebook!,
          cloudUser: cloudUser,
          isLoading: false,
          exception: e,
        ));
        return;
      }
      //Send user to rulebooks view
      emit(AppStateViewingRulebooks(
        isLoading: false,
        exception: null,
        cloudUser: cloudUser,
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
      final household = state.household;
      emit(AppStateViewingProfile(
        cloudUser: cloudUser,
        household: household,
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
          household: household,
          user: user,
          exception: e,
          isLoading: false,
        ));
        return;
      }
      emit(AppStateViewingProfile(
        cloudUser: cloudUser,
        household: household,
        user: user,
        exception: null,
        isLoading: false,
      ));
    });

    on<AppEventDeleteProfilePhoto>(
      (event, emit) async {
        //validate access
        if (!await isValidAuthUserAccess()) {
          add(const AppEventReset());
          return;
        }
        //start loading
        final user = _authProvider.currentUser!;
        final cloudUser = await _cloudProvider.cachedCloudUser;
        final household = state.household;
        emit(AppStateViewingProfile(
          cloudUser: cloudUser!,
          household: household,
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
            household: household,
            user: user,
            exception: e,
            isLoading: false,
          ));
        }

        emit(AppStateViewingProfile(
          cloudUser: cloudUser,
          household: household,
          user: user,
          exception: null,
          isLoading: false,
        ));
      },
    );
  }

  Future<bool> isValidAuthUserAccess() async {
    final authUser = _authProvider.currentUser;
    if (authUser == null || !authUser.isEmailVerified) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> isValidCloudUserAccess() async {
    final authUser = _authProvider.currentUser;
    final cloudUser = await _cloudProvider.cachedCloudUser ??
        await _cloudProvider.currentCloudUser;
    if (authUser == null ||
        !authUser.isEmailVerified ||
        cloudUser == null ||
        cloudUser.id != authUser.uid) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> isValidHouseholdAccess() async {
    final authUser = _authProvider.currentUser;
    final cloudUser = await _cloudProvider.cachedCloudUser ??
        await _cloudProvider.currentCloudUser;
    final household = await _cloudProvider.cachedHousehold ??
        await _cloudProvider.currentHousehold;
    if (authUser == null ||
        !authUser.isEmailVerified ||
        cloudUser == null ||
        cloudUser.id != authUser.uid ||
        household == null ||
        cloudUser.householdId != household.id) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> isValidNeighborhoodAccess() async {
    final authUser = _authProvider.currentUser;
    final cloudUser = await _cloudProvider.cachedCloudUser ??
        await _cloudProvider.currentCloudUser;
    final household = await _cloudProvider.cachedHousehold ??
        await _cloudProvider.currentHousehold;
    final neighborhood = await _cloudProvider.cachedNeighborhood ??
        await _cloudProvider.currentNeighborhood;

    if (authUser == null ||
        !authUser.isEmailVerified ||
        cloudUser == null ||
        cloudUser.id != authUser.uid ||
        household == null ||
        neighborhood == null ||
        neighborhood.id != cloudUser.neighborhoodId ||
        household.id != cloudUser.householdId ||
        household.neighborhoodId != neighborhood.id) {
      return false;
    } else {
      return true;
    }
  }

  Future<Uint8List?> profilePicture({required String? userId}) async {
    if (userId == null || userId.isEmpty) {
      return null;
    }
    try {
      return await _storageProvider.getProfileImage(userId: userId);
    } catch (e) {
      return null;
    }
  }

  Stream<bool> get userVerificationStream async* {
    final user = _authProvider.currentUser!;
    if (user.isEmailVerified) yield true;
    _authProvider.userChanges().listen((user) {
      if (user.isEmailVerified) {
        true;
      } else {
        false;
      }
    });
  }

  Future<Household?> otherHousehold(String? householdId) async {
    if (householdId == null || householdId.isEmpty) {
      return null;
    }
    try {
      return await _cloudProvider.otherHousehold(householdId: householdId);
    } catch (e) {
      return null;
    }
  }

  Stream<Iterable<CloudUser>> householdNeighbors(
      {required String householdId}) async* {
    yield* _cloudProvider.householdNeighbors(
      householdId: householdId,
    );
  }

  Stream<Iterable<Rulebook>> get rulebooks async* {
    final cloudUSer = await _cloudProvider.cachedCloudUser;
    yield* _cloudProvider.neighborhoodRulebooks(
      neighborhoodId: cloudUSer!.neighborhoodId!,
    );
  }
}
