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
import 'package:vecinapp/utilities/entities/event.dart';
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
      devtools.log('AppEventReset');
      try {
        //Start loading
        emit(const AppStateUnInitalized(
          isLoading: false,
        ));

        //Get AuthUser
        final user = _authProvider.currentUser;

        //check if user is not logged in
        if (user == null) {
          emit(
            const AppStateWelcomeViewing(
              exception: null,
              isLoading: false,
            ),
          );
          return;
        }

        //check if user is not verified
        if (!user.isEmailVerified) {
          emit(AppStateNeedsVerification(
            exception: null,
            isLoading: false,
          ));
          return;
        }

        //Get CloudUser
        final cloudUser = await _cloudProvider.currentCloudUser;

        //check if CloudUser does not exist
        if (cloudUser == null) {
          emit(const AppStateCreatingCloudUser(
            isLoading: false,
            exception: null,
          ));
          return;
        }

        //check if CloudUser is not the same as AuthUser, this should never happen
        assert(user.uid == cloudUser.id);

        //check if CloudUser is in a Household
        if (cloudUser.householdId == null) {
          devtools.log('CloudUser is not in a Household');
          emit(const AppStateSelectingHomeAddress(
            isLoading: false,
            exception: null,
          ));
          return;
        }

        //get Household
        final household = await _cloudProvider.currentHousehold;

        //check if Household does not exist, this would mean the Household was deleted
        if (household == null) {
          devtools.log('Household does not exist');
          await _cloudProvider.exitHousehold();
          emit(const AppStateSelectingHomeAddress(
            isLoading: false,
            exception: null,
          ));
          return;
        }

        //check if CloudUser has a wrong HouseholdId, this should never happen
        assert(cloudUser.householdId == household.id);

        //check if user has a neighborhood
        if (cloudUser.neighborhoodId == null) {
          emit(AppStateNoNeighborhood(
            isLoading: false,
            exception: null,
            cloudUser: cloudUser,
            household: household,
          ));
          return;
        }

        //get Neighborhood
        final neighborhood = await _cloudProvider.currentNeighborhood;

        //check if Neighborhood does not exist, this would mean the neighborhood was deleted
        if (neighborhood == null) {
          await _cloudProvider.exitNeighborhood();
          emit(AppStateNoNeighborhood(
            isLoading: false,
            exception: null,
            cloudUser: cloudUser,
            household: household,
          ));
          return;
        }

        //check if CloudUser, Household and Neighborhood do not match, this should never happen
        assert(cloudUser.neighborhoodId == neighborhood.id &&
            neighborhood.id == household.neighborhoodId);

        //check if household is not in the neighborhood area.
        //this would mean the neighborhood area was edited and the household no longer belongs to the neighborhood.
        final point = Point(x: household.latitude, y: household.longitude);
        if (Poly.isPointInPolygon(point, neighborhood.polygon) == false) {
          await _cloudProvider.exitNeighborhood();
          emit(AppStateNoNeighborhood(
            isLoading: false,
            exception: null,
            cloudUser: cloudUser,
            household: household,
          ));
          return;
        }

        //emit success
        emit(AppStateViewingNeighborhood(
          cloudUser: cloudUser,
          exception: null,
          isLoading: false,
          neighborhood: neighborhood,
          household: household,
        ));
      } catch (e) {
        emit(AppStateError(
          exception: e,
          isLoading: false,
        ));
      }
    });

    //Authentication Routing

    on<AppEventGoToWelcomeView>((event, emit) async {
      emit(const AppStateWelcomeViewing(
        exception: null,
        isLoading: false,
      ));
    });

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

    on<AppEventGoToNoNeighborhoodView>((event, emit) async {
      emit(AppStateNoNeighborhood(
        exception: null,
        isLoading: false,
        cloudUser: state.cloudUser!,
        household: state.household!,
      ));
    });

    //Authentication Events
    on<AppEventRegisterWithEmailAndPassword>((event, emit) async {
      //no validation required

      //start loading
      emit(const AppStateRegistering(
        exception: null,
        isLoading: true,
      ));
      //create user
      try {
        final email = event.email;
        final password = event.password;
        final passwordConfirmation = event.passwordConfirmation;
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

    on<AppEventLogInWithEmailAndPassword>((event, emit) async {
      //no validation required

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

    on<AppEventSendPasswordResetEmail>((event, emit) async {
      //no validation required

      //send email
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

    on<AppEventLogOut>((event, emit) async {
      await _authProvider.logOut();
      add(AppEventReset());
    });

    on<AppEventSendEmailVerification>((event, emit) async {
      //validate access
      if (!_isValidAuthUserAccess()) {
        add(const AppEventReset());
        return;
      }
      //start loading
      emit(const AppStateNeedsVerification(
        exception: null,
        isLoading: true,
      ));
      try {
        await _authProvider.sendEmailVerification();
      } catch (e) {
        emit(AppStateNeedsVerification(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AppEventConfirmUserIsVerified>((event, emit) async {
      //validate access
      if (!_isValidAuthUserAccess()) {
        add(const AppEventReset());
        return;
      }
      //start loading
      emit(const AppStateNeedsVerification(
        exception: null,
        isLoading: true,
      ));
      //confirm verification
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

    on<AppEventDeleteAccount>((event, emit) async {
      //validate access
      if (!await _isValidCloudUserAccess()) {
        add(const AppEventReset());
        return;
      }

      //show loading
      emit(const AppStateDeletingAccount(
        isLoading: true,
        exception: null,
        loadingText: 'Eliminando cuenta...',
      ));

      //delete account
      try {
        final user = _authProvider.currentUser;
        final cloudUser = await _cloudProvider.currentCloudUser;
        await _authProvider.logInWithEmailAndPassword(
          email: user!.email!,
          password: event.password,
        );
        await _storageProvider.deleteProfileImage(userId: cloudUser!.id);
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

    //Neighborhood Routing
    on<AppEventGoToNeighborhoodView>((event, emit) async {
      final neighborhood = await _cloudProvider.cachedNeighborhood;
      final cloudUser = await _cloudProvider.cachedCloudUser;
      final household = await _cloudProvider.cachedHousehold;
      emit(AppStateViewingNeighborhood(
        cloudUser: cloudUser!,
        isLoading: false,
        exception: null,
        neighborhood: neighborhood!,
        household: household!,
      ));
    });

    on<AppEventGoToProfileView>((event, emit) async {
      final user = _authProvider.currentUser;
      final cloudUser = await _cloudProvider.currentCloudUser;
      final household = await _cloudProvider.currentHousehold;
      final neighborhood = await _cloudProvider.currentNeighborhood;
      emit(AppStateViewingProfile(
        cloudUser: cloudUser!,
        neighborhood: neighborhood,
        household: household,
        user: user!,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToHouseholdView>((event, emit) async {
      emit(AppStateViewingHousehold(
        household: event.household,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToNeighborhoodDetailsView>((event, emit) async {
      emit(AppStateViewingNeighborhoodDetails(
        neighborhood: event.neighborhood,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToSettingsView>((event, emit) async {
      emit(const AppStateViewingSettings(
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToDeleteAccountView>((event, emit) async {
      emit(const AppStateDeletingAccount(
        isLoading: false,
        exception: null,
      ));
    });

    //Cloud User Events
    on<AppEventCreateCloudUser>((event, emit) async {
      //validate access
      if (!_isValidAuthUserAccess()) {
        add(const AppEventReset());
        return;
      }
      //create new cloud user
      try {
        await _cloudProvider.createCloudUser(
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
      add(const AppEventReset());
    });

    on<AppEventUpdateHomeAddress>(
      (event, emit) async {
        //validate access
        if (!await _isValidCloudUserAccess()) {
          add(const AppEventReset());
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
            street: event.street,
            housenumber: event.houseNumber,
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
        add(const AppEventReset());
      },
    );

    on<AppEventConfirmAddress>((event, emit) async {
      //validate access
      if (!await _isValidCloudUserAccess()) {
        add(const AppEventReset());
        return;
      }
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
      final household = await _cloudProvider.currentHousehold;
      //if the user has a neighborhood, send to viewing neighborhood
      if (updatedCloudUser!.neighborhoodId != null) {
        emit(AppStateViewingNeighborhood(
          cloudUser: updatedCloudUser,
          isLoading: false,
          exception: null,
          neighborhood: neighborhood!,
          household: household!,
        ));
      } else {
        //Send No Neighborhood (this view should try to find a neighborhood for the user's home)
        emit(AppStateNoNeighborhood(
          isLoading: false,
          exception: null,
          cloudUser: updatedCloudUser,
          household: household!,
        ));
      }
    });

    on<AppEventLookForNeighborhood>((event, emit) async {
      //validate access
      if (!await _isValidHouseholdAccess()) {
        add(const AppEventReset());
        return;
      }
      //enable loading indicator
      emit(AppStateNoNeighborhood(
        isLoading: true,
        exception: null,
        cloudUser: state.cloudUser!,
        household: state.household!,
      ));
      //change the user's neighborhood
      try {
        await _cloudProvider.assignNeighborhood();
      } catch (_) {
        //inform user of error
        emit(AppStateNoNeighborhood(
          isLoading: false,
          exception: null,
          cloudUser: state.cloudUser!,
          household: state.household!,
        ));
        return;
      }
      //send to viewing neighborhood
      final updatedCloudUser = await _cloudProvider.currentCloudUser;
      final neighborhood = await _cloudProvider.currentNeighborhood;
      final household = await _cloudProvider.currentHousehold;
      emit(AppStateViewingNeighborhood(
        cloudUser: updatedCloudUser!,
        isLoading: false,
        exception: null,
        neighborhood: neighborhood!,
        household: household!,
      ));
    });

    on<AppEventExitHousehold>((event, emit) async {
      //validate access
      if (!await _isValidHouseholdAccess()) {
        add(const AppEventReset());
        return;
      }
      //exit household
      try {
        await _cloudProvider.exitHousehold();
      } catch (_) {
        add(AppEventReset());
      }
      add(AppEventReset());
    });

    on<AppEventUpdateUserDisplayName>((event, emit) async {
      //validate access
      if (!await _isValidCloudUserAccess()) {
        add(const AppEventReset());
        return;
      }
      //start loading
      final user = _authProvider.currentUser;
      final cloudUser = await _cloudProvider.currentCloudUser;
      final household = state.household;
      final neighborhood = state.neighborhood;
      emit(AppStateViewingProfile(
        cloudUser: cloudUser!,
        household: household,
        neighborhood: neighborhood,
        user: user!,
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
          neighborhood: neighborhood,
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
        neighborhood: neighborhood,
        user: user,
        exception: null,
        isLoading: false,
      ));
    });

    //Storage events
    on<AppEventUpdateProfilePhoto>((event, emit) async {
      //validate access
      if (!await _isValidCloudUserAccess()) {
        add(const AppEventReset());
        return;
      }
      //start loading
      final user = _authProvider.currentUser;
      final cloudUser = await _cloudProvider.cachedCloudUser;
      final household = state.household;
      final neighborhood = state.neighborhood;
      emit(AppStateViewingProfile(
        cloudUser: cloudUser!,
        household: household,
        neighborhood: neighborhood,
        user: user!,
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
          neighborhood: neighborhood,
          user: user,
          exception: e,
          isLoading: false,
        ));
        return;
      }
      emit(AppStateViewingProfile(
        cloudUser: cloudUser,
        household: household,
        neighborhood: neighborhood,
        user: user,
        exception: null,
        isLoading: false,
      ));
    });

    on<AppEventDeleteProfilePhoto>(
      (event, emit) async {
        //validate access
        if (!await _isValidCloudUserAccess()) {
          add(const AppEventReset());
          return;
        }
        //start loading
        final user = _authProvider.currentUser!;
        final cloudUser = await _cloudProvider.cachedCloudUser;
        final household = state.household;
        final neighborhood = state.neighborhood;
        emit(AppStateViewingProfile(
          cloudUser: cloudUser!,
          household: household,
          neighborhood: neighborhood,
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
            neighborhood: neighborhood,
            user: user,
            exception: e,
            isLoading: false,
          ));
        }

        emit(AppStateViewingProfile(
          cloudUser: cloudUser,
          household: household,
          neighborhood: neighborhood,
          user: user,
          exception: null,
          isLoading: false,
        ));
      },
    );

    //Rulebook Routing
    on<AppEventGoToRulebooksView>((event, emit) async {
      final cloudUser = await _cloudProvider.cachedCloudUser;
      final neighborhood = await _cloudProvider.cachedNeighborhood;
      final household = await _cloudProvider.cachedHousehold;
      emit(AppStateViewingRulebooks(
        isLoading: false,
        exception: null,
        cloudUser: cloudUser,
        neighborhood: neighborhood,
        household: household,
      ));
    });

    on<AppEventGoToEditRulebookView>((event, emit) async {
      emit(AppStateEditingRulebook(
        rulebook: event.rulebook,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToRulebookDetailsView>((event, emit) async {
      final cloudUser = await _cloudProvider.cachedCloudUser;
      emit(AppStateViewingRulebookDetails(
        rulebook: event.rulebook,
        isLoading: false,
        exception: null,
        cloudUser: cloudUser!,
      ));
    });

    //Rulebook Events
    on<AppEventCreateOrUpdateRulebook>((event, emit) async {
      //validate access
      if (!await _isValidNeighborhoodAccess()) {
        add(const AppEventReset());
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
          final rulebookId = state.rulebook!.id;
          await _cloudProvider.updateRulebook(
            rulebookId: rulebookId,
            title: event.title,
            text: event.text,
          );
          newRulebook =
              await _cloudProvider.getRulebook(rulebookId: rulebookId);
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
      //validate access
      if (!await _isValidNeighborhoodAccess()) {
        add(const AppEventReset());
        return;
      }
      //enable loading indicator
      final cloudUser = await _cloudProvider.cachedCloudUser;
      final neighborhood = await _cloudProvider.cachedNeighborhood;
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
      final household = await _cloudProvider.cachedHousehold;
      emit(AppStateViewingRulebooks(
        neighborhood: neighborhood,
        isLoading: false,
        exception: null,
        cloudUser: cloudUser,
        household: household,
      ));
    });

    //Event Routing
    on<AppEventGoToEventsView>((event, emit) async {
      final cloudUser = await _cloudProvider.cachedCloudUser;
      final neighborhood = await _cloudProvider.cachedNeighborhood;
      final household = await _cloudProvider.cachedHousehold;
      emit(AppStateViewingEvents(
        isLoading: false,
        exception: null,
        cloudUser: cloudUser,
        neighborhood: neighborhood,
        household: household,
      ));
    });

    on<AppEventGoToEditEventView>((event, emit) async {
      emit(AppStateEditingEvent(
        event: event.event,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventGoToEventDetailsView>((event, emit) async {
      final cloudUser = await _cloudProvider.cachedCloudUser;
      emit(AppStateViewingEventDetails(
        event: event.event,
        isLoading: false,
        exception: null,
        cloudUser: cloudUser!,
      ));
    });

    //Event Events
    on<AppEventCreateOrUpdateEvent>((event, emit) async {
      //validate access
      if (!await _isValidNeighborhoodAccess()) {
        add(const AppEventReset());
        return;
      }
      //enable loading indicator
      emit(AppStateEditingEvent(
        event: state.event,
        isLoading: true,
        exception: null,
      ));
      //check if event is provided
      late Event newEvent;
      if (state.event != null) {
        try {
          //update existing event
          final eventId = state.event!.id;
          await _cloudProvider.updateEvent(
            eventId: eventId,
            title: event.title,
            text: event.text,
            dateStart: event.dateStart,
            dateEnd: event.dateEnd,
            placeName: event.placeName,
            location: event.location,
          );
          newEvent = await _cloudProvider.getEvent(eventId: eventId);
        } catch (e) {
          //inform user of error
          emit(AppStateEditingEvent(
            event: state.event,
            isLoading: false,
            exception: e,
          ));
          return;
        }
      } else {
        //create new event
        try {
          newEvent = await _cloudProvider.createNewEvent(
            title: event.title,
            text: event.text,
            dateStart: event.dateStart,
            dateEnd: event.dateEnd,
            placeName: event.placeName,
            location: event.location,
          );
        } catch (e) {
          //inform user of error
          emit(AppStateEditingEvent(
            event: null,
            isLoading: false,
            exception: e,
          ));
          return;
        }
      }
      //Send user to event details view
      final cloudUser = await _cloudProvider.cachedCloudUser;
      emit(AppStateViewingEventDetails(
        event: newEvent,
        cloudUser: cloudUser!,
        isLoading: false,
        exception: null,
      ));
    });

    on<AppEventDeleteEvent>((event, emit) async {
      //validate access
      if (!await _isValidNeighborhoodAccess()) {
        add(const AppEventReset());
        return;
      }
      //enable loading indicator
      final cloudUser = await _cloudProvider.cachedCloudUser;
      final neighborhood = await _cloudProvider.cachedNeighborhood;
      final household = await _cloudProvider.cachedHousehold;
      emit(AppStateViewingEventDetails(
        event: state.event!,
        isLoading: true,
        exception: null,
        cloudUser: cloudUser!,
      ));
      try {
        await _cloudProvider.deleteEvent(
          eventId: state.event!.id,
        );
      } on Exception catch (e) {
        emit(AppStateViewingEventDetails(
          event: state.event!,
          cloudUser: cloudUser,
          isLoading: false,
          exception: e,
        ));
        return;
      }
      //Send user to rulebooks view
      emit(AppStateViewingNeighborhood(
        neighborhood: neighborhood!,
        isLoading: false,
        exception: null,
        cloudUser: cloudUser,
        household: household!,
      ));
    });
  }

  //Private methods
  bool _isValidAuthUserAccess() {
    final authUser = _authProvider.currentUser;
    if (authUser == null) {
      return false;
    } else {
      return true;
    }
  }

  bool _isValidAuthUserVerificationAccess() {
    final authUser = _authProvider.currentUser;
    if (_isValidAuthUserAccess() == false ||
        authUser!.isEmailVerified == false) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> _isValidCloudUserAccess() async {
    final authUser = _authProvider.currentUser;
    final cloudUser = await _cloudProvider.cachedCloudUser ??
        await _cloudProvider.currentCloudUser;
    if (_isValidAuthUserVerificationAccess() == false ||
        cloudUser == null ||
        cloudUser.id != authUser!.uid) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> _isValidHouseholdAccess() async {
    final cloudUser = await _cloudProvider.cachedCloudUser ??
        await _cloudProvider.currentCloudUser;
    final household = await _cloudProvider.cachedHousehold ??
        await _cloudProvider.currentHousehold;
    if (await _isValidCloudUserAccess() == false ||
        household == null ||
        cloudUser!.householdId != household.id) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> _isValidNeighborhoodAccess() async {
    final cloudUser = await _cloudProvider.cachedCloudUser ??
        await _cloudProvider.currentCloudUser;
    final household = await _cloudProvider.cachedHousehold ??
        await _cloudProvider.currentHousehold;
    final neighborhood = await _cloudProvider.cachedNeighborhood ??
        await _cloudProvider.currentNeighborhood;

    if (await _isValidHouseholdAccess() == false ||
        neighborhood == null ||
        neighborhood.id != cloudUser!.neighborhoodId ||
        household!.neighborhoodId != neighborhood.id) {
      return false;
    } else {
      return true;
    }
  }

  //Public methods
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

  Stream<Iterable<Event>> get events async* {
    final cloudUSer = await _cloudProvider.cachedCloudUser;
    yield* _cloudProvider.neighborhoodEvents(
      neighborhoodId: cloudUSer!.neighborhoodId!,
    );
  }
}
