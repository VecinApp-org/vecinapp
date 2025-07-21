import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:vecinapp/extensions/geometry/is_point_in_polygon.dart';
import 'package:vecinapp/extensions/geometry/point.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/loading_messages_constants.dart';
import 'package:vecinapp/services/cloud/cloud_provider.dart';
import 'package:vecinapp/services/cloud/cloud_exceptions.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:vecinapp/utilities/entities/post.dart';
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
      emit(const AppStateUnInitalized(
        isLoading: false,
      ));

      try {
        //Get AuthUser
        final authUser = _authProvider.currentUser;
        //check if user is not logged in
        if (authUser == null) {
          devtools.log('User is not logged in');
          emit(
            const AppStateWelcomeViewing(
              exception: null,
              isLoading: false,
              loadingText: null,
            ),
          );
          return;
        }

        //check if user is not verified
        if (!authUser.isEmailVerified) {
          devtools.log('User is not verified');
          emit(AppStateNeedsVerification(
            exception: null,
            isLoading: false,
          ));
          return;
        }

        //Get CloudUser
        final cloudUser = await _cloudProvider.currentCloudUser;
        //check if CloudUser does not exist
        if (cloudUser == null || cloudUser.displayName == '') {
          devtools.log('CloudUser does not exist');
          emit(const AppStateCreatingCloudUser(
            isLoading: false,
            exception: null,
          ));
          return;
        }

        //check if CloudUser is not the same as AuthUser, this should never happen
        assert(authUser.uid == cloudUser.id);

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
          devtools.log('CloudUser has no neighborhood');
          emit(AppStateNoNeighborhood(
            isLoading: false,
            loadingText: null,
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
            loadingText: null,
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
          devtools.log('Household is not in the neighborhood area');
          await _cloudProvider.exitNeighborhood();
          emit(AppStateNoNeighborhood(
            isLoading: false,
            loadingText: null,
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
          loadingText: null,
          neighborhood: neighborhood,
          household: household,
        ));
      } catch (e) {
        emit(AppStateError(
          exception: e as Exception,
          isLoading: false,
        ));
      }
    });

    //Authentication Events
    on<AppEventRegisterWithEmailAndPassword>((event, emit) async {
      //no validation required

      //start loading
      emit(const AppStateWelcomeViewing(
        exception: null,
        isLoading: true,
        loadingText: 'Registrando...',
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
        emit(AppStateWelcomeViewing(
          exception: e,
          isLoading: false,
          loadingText: null,
        ));
        return;
      }
      add(AppEventReset());
    });

    on<AppEventLogInWithEmailAndPassword>((event, emit) async {
      //no validation required

      //show loading
      emit(const AppStateWelcomeViewing(
        exception: null,
        isLoading: true,
        loadingText: 'Iniciando sesión...',
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
          AppStateWelcomeViewing(
            exception: e,
            loadingText: null,
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
        emit(AppStateWelcomeViewing(
          exception: null,
          isLoading: true,
          loadingText: 'Enviando correo...',
        ));
        await _authProvider.sendPasswordResetEmail(email: event.email);
      } on AuthException catch (e) {
        emit(AppStateWelcomeViewing(
          exception: e,
          isLoading: false,
          loadingText: null,
        ));
      }
      emit(AppStateWelcomeViewing(
        exception: null,
        isLoading: false,
        loadingText: loadingTextPasswordResetEmailSent,
      ));
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
        return;
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
      if (state is AppStateViewingNeighborhood) {
        emit(AppStateViewingNeighborhood(
          isLoading: true,
          exception: null,
          loadingText: null,
          cloudUser: state.cloudUser!,
          household: state.household!,
          neighborhood: state.neighborhood!,
        ));
      } else if (state is AppStateNoNeighborhood) {
        emit(AppStateNoNeighborhood(
          isLoading: true,
          exception: null,
          loadingText: null,
          cloudUser: state.cloudUser!,
          household: state.household!,
        ));
      }

      //delete account
      final cloudUser = await _cloudProvider.currentCloudUser;
      final household = await _cloudProvider.currentHousehold;
      final neighborhood = await _cloudProvider.currentNeighborhood;
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
        if (state is AppStateViewingNeighborhood) {
          emit(AppStateViewingNeighborhood(
            isLoading: false,
            exception: e,
            loadingText: null,
            cloudUser: cloudUser!,
            household: household!,
            neighborhood: neighborhood!,
          ));
        } else if (state is AppStateNoNeighborhood) {
          emit(AppStateNoNeighborhood(
            isLoading: false,
            exception: e,
            loadingText: null,
            cloudUser: cloudUser!,
            household: household!,
          ));
        }
        return;
      }
      add(const AppEventReset());
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
          loadingText: null,
          exception: null,
          neighborhood: neighborhood!,
          household: household!,
        ));
      } else {
        //Send No Neighborhood (this view should try to find a neighborhood for the user's home)
        emit(AppStateNoNeighborhood(
          isLoading: false,
          loadingText: null,
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
        loadingText: 'Buscando vecindad',
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
          loadingText: null,
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
        loadingText: null,
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
      //start loading indicator
      if (state is AppStateViewingNeighborhood) {
        emit(AppStateViewingNeighborhood(
          cloudUser: state.cloudUser!,
          isLoading: true,
          loadingText: null,
          exception: null,
          neighborhood: state.neighborhood!,
          household: state.household!,
        ));
      } else if (state is AppStateNoNeighborhood) {
        emit(AppStateNoNeighborhood(
          isLoading: true,
          loadingText: null,
          exception: null,
          cloudUser: state.cloudUser!,
          household: state.household!,
        ));
      }

      //exit household
      final cloudUser = await _cloudProvider.currentCloudUser;
      final household = await _cloudProvider.currentHousehold;
      final neighborhood = await _cloudProvider.currentNeighborhood;
      try {
        await _cloudProvider.exitHousehold();
      } catch (e) {
        if (state is AppStateViewingNeighborhood) {
          emit(AppStateViewingNeighborhood(
            cloudUser: cloudUser!,
            isLoading: false,
            loadingText: null,
            exception: e,
            neighborhood: neighborhood!,
            household: household!,
          ));
          return;
        } else if (state is AppStateNoNeighborhood) {
          emit(AppStateNoNeighborhood(
            isLoading: false,
            loadingText: null,
            exception: e,
            cloudUser: cloudUser!,
            household: household!,
          ));
          return;
        }
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
      if (state is AppStateNoNeighborhood) {
        emit(AppStateNoNeighborhood(
          isLoading: true,
          loadingText: null,
          exception: null,
          cloudUser: state.cloudUser!,
          household: state.household!,
        ));
      } else if (state is AppStateViewingNeighborhood) {
        emit(AppStateViewingNeighborhood(
          cloudUser: state.cloudUser!,
          isLoading: true,
          loadingText: null,
          exception: null,
          neighborhood: state.neighborhood!,
          household: state.household!,
        ));
      }
      final cloudUser = await _cloudProvider.currentCloudUser;
      final household = state.household;
      final neighborhood = state.neighborhood;
      //update display name
      try {
        await _cloudProvider.updateUserDisplayName(
          displayName: event.displayName,
        );
      } catch (e) {
        //notify user of error
        if (state is AppStateNoNeighborhood) {
          emit(AppStateNoNeighborhood(
            isLoading: false,
            loadingText: null,
            exception: e,
            cloudUser: cloudUser!,
            household: household!,
          ));
          return;
        } else if (state is AppStateViewingNeighborhood) {
          emit(AppStateViewingNeighborhood(
            cloudUser: cloudUser!,
            isLoading: false,
            loadingText: null,
            exception: e,
            neighborhood: neighborhood!,
            household: household!,
          ));
          return;
        }
        return;
      }
      //notify user of success
      final updatedUser = await _cloudProvider.currentCloudUser;
      if (state is AppStateNoNeighborhood) {
        emit(AppStateNoNeighborhood(
          isLoading: false,
          loadingText: null,
          exception: null,
          cloudUser: updatedUser!,
          household: household!,
        ));
      } else if (state is AppStateViewingNeighborhood) {
        emit(AppStateViewingNeighborhood(
          cloudUser: updatedUser!,
          isLoading: false,
          loadingText: null,
          exception: null,
          neighborhood: neighborhood!,
          household: household!,
        ));
      }
    });

    //Storage events
    on<AppEventUpdateProfilePhoto>((event, emit) async {
      //validate access
      if (!await _isValidCloudUserAccess()) {
        add(const AppEventReset());
        return;
      }
      //start loading
      if (state is AppStateNoNeighborhood) {
        emit(AppStateNoNeighborhood(
          isLoading: true,
          loadingText: null,
          exception: null,
          cloudUser: state.cloudUser!,
          household: state.household!,
        ));
      } else if (state is AppStateViewingNeighborhood) {
        emit(AppStateViewingNeighborhood(
          cloudUser: state.cloudUser!,
          isLoading: true,
          loadingText: null,
          exception: null,
          neighborhood: state.neighborhood!,
          household: state.household!,
        ));
      }
      final user = _authProvider.currentUser!;
      final cloudUser = await _cloudProvider.cachedCloudUser;
      final household = state.household;
      final neighborhood = state.neighborhood;

      //upload image
      try {
        final File image = File(event.imagePath);
        final imageUrl = await _storageProvider.uploadProfileImage(
          image: image,
          userId: user.uid!,
        );
        //update user's photo url
        await _cloudProvider.updateUserPhotoUrl(photoUrl: imageUrl);
      } catch (e) {
        if (state is AppStateNoNeighborhood) {
          emit(AppStateNoNeighborhood(
            isLoading: false,
            loadingText: null,
            exception: e,
            cloudUser: cloudUser!,
            household: household!,
          ));
          return;
        } else if (state is AppStateViewingNeighborhood) {
          emit(AppStateViewingNeighborhood(
            cloudUser: cloudUser!,
            isLoading: false,
            loadingText: null,
            exception: e,
            neighborhood: neighborhood!,
            household: household!,
          ));
          return;
        }
        return;
      }
      final newCloudUser = await _cloudProvider.currentCloudUser;
      if (state is AppStateNoNeighborhood) {
        emit(AppStateNoNeighborhood(
          isLoading: false,
          loadingText: null,
          exception: null,
          cloudUser: newCloudUser!,
          household: household!,
        ));
      } else if (state is AppStateViewingNeighborhood) {
        emit(AppStateViewingNeighborhood(
          cloudUser: newCloudUser!,
          isLoading: false,
          loadingText: null,
          exception: null,
          neighborhood: neighborhood!,
          household: household!,
        ));
      }
    });

    on<AppEventDeleteProfilePhoto>(
      (event, emit) async {
        //validate access
        if (!await _isValidCloudUserAccess()) {
          add(const AppEventReset());
          return;
        }
        //start loading
        if (state is AppStateNoNeighborhood) {
          emit(AppStateNoNeighborhood(
            isLoading: true,
            loadingText: null,
            exception: null,
            cloudUser: state.cloudUser!,
            household: state.household!,
          ));
        } else if (state is AppStateViewingNeighborhood) {
          emit(AppStateViewingNeighborhood(
            cloudUser: state.cloudUser!,
            isLoading: true,
            loadingText: null,
            exception: null,
            neighborhood: state.neighborhood!,
            household: state.household!,
          ));
        }
        final user = _authProvider.currentUser!;
        final cloudUser = await _cloudProvider.cachedCloudUser;
        final household = state.household;
        final neighborhood = state.neighborhood;
        //delete image
        try {
          await _storageProvider.deleteProfileImage(userId: user.uid!);
          await _cloudProvider.updateUserPhotoUrl(photoUrl: '');
        } catch (e) {
          //emit error
          if (state is AppStateNoNeighborhood) {
            emit(AppStateNoNeighborhood(
              isLoading: false,
              loadingText: null,
              exception: e,
              cloudUser: cloudUser!,
              household: household!,
            ));
            return;
          } else if (state is AppStateViewingNeighborhood) {
            emit(AppStateViewingNeighborhood(
              cloudUser: cloudUser!,
              isLoading: false,
              loadingText: null,
              exception: e,
              neighborhood: neighborhood!,
              household: household!,
            ));
            return;
          }
        }
        final newCloudUser = await _cloudProvider.currentCloudUser;
        //emit success
        if (state is AppStateNoNeighborhood) {
          emit(AppStateNoNeighborhood(
            isLoading: false,
            loadingText: null,
            exception: null,
            cloudUser: newCloudUser!,
            household: household!,
          ));
        } else if (state is AppStateViewingNeighborhood) {
          emit(AppStateViewingNeighborhood(
            cloudUser: newCloudUser!,
            isLoading: false,
            loadingText: null,
            exception: null,
            neighborhood: neighborhood!,
            household: household!,
          ));
        }
      },
    );

    //Rulebook Events
    on<AppEventCreateOrUpdateRulebook>((event, emit) async {
      //validate access
      if (!await _isValidNeighborhoodAccess()) {
        add(const AppEventReset());
        return;
      }
      //enable loading indicator
      emit(AppStateViewingNeighborhood(
        neighborhood: state.neighborhood!,
        cloudUser: state.cloudUser!,
        household: state.household!,
        isLoading: true,
        loadingText: loadingTextRulebookCreation,
        exception: null,
      ));
      final cloudUser = await _cloudProvider.cachedCloudUser;
      final household = await _cloudProvider.cachedHousehold;
      final neighborhood = await _cloudProvider.cachedNeighborhood;
      //check if rulebook is provided
      final rulebookId = event.rulebookId;
      if (rulebookId != null) {
        try {
          //update existing rulebook
          await _cloudProvider.updateRulebook(
            rulebookId: rulebookId,
            title: event.title,
            text: event.text,
          );
        } catch (e) {
          //inform user of error
          emit(AppStateViewingNeighborhood(
            neighborhood: neighborhood!,
            cloudUser: cloudUser!,
            household: household!,
            isLoading: false,
            loadingText: null,
            exception: e,
          ));
          return;
        }
      } else {
        //create new rulebook
        try {
          await _cloudProvider.createNewRulebook(
            title: event.title,
            text: event.text,
          );
        } catch (e) {
          //inform user of error
          emit(AppStateViewingNeighborhood(
            neighborhood: neighborhood!,
            cloudUser: cloudUser!,
            household: household!,
            isLoading: false,
            loadingText: null,
            exception: e,
          ));
          return;
        }
      }
      //Send user to rulebook details view
      emit(AppStateViewingNeighborhood(
        neighborhood: neighborhood!,
        household: household!,
        cloudUser: cloudUser!,
        isLoading: false,
        loadingText: loadingTextRulebookCreationSuccess,
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

      emit(AppStateViewingNeighborhood(
        neighborhood: state.neighborhood!,
        household: state.household!,
        cloudUser: state.cloudUser!,
        isLoading: true,
        loadingText: loadingTextRulebookDeletion,
        exception: null,
      ));
      final cloudUser = await _cloudProvider.cachedCloudUser;
      final neighborhood = await _cloudProvider.cachedNeighborhood;
      final household = await _cloudProvider.cachedHousehold;
      try {
        await _cloudProvider.deleteRulebook(
          rulebookId: event.rulebookId,
        );
      } on CloudException catch (e) {
        emit(AppStateViewingNeighborhood(
          neighborhood: neighborhood!,
          cloudUser: cloudUser!,
          household: household!,
          isLoading: false,
          loadingText: null,
          exception: e,
        ));
        return;
      } on Exception catch (e) {
        emit(AppStateViewingNeighborhood(
          neighborhood: neighborhood!,
          household: household!,
          cloudUser: cloudUser!,
          isLoading: false,
          loadingText: null,
          exception: e,
        ));
        return;
      }
      //Send user to rulebooks view
      emit(AppStateViewingNeighborhood(
        neighborhood: neighborhood!,
        cloudUser: cloudUser!,
        household: household!,
        isLoading: false,
        loadingText: loadingTextRulebookDeletionSuccess,
        exception: null,
      ));
    });

    //Event Events
    on<AppEventCreateOrUpdateEvent>((event, emit) async {
      //validate access
      if (!await _isValidNeighborhoodAccess()) {
        add(const AppEventReset());
        return;
      }
      //check if event is provided
      if (event.eventId != null) {
        //enable loading indicator
        emit(AppStateViewingNeighborhood(
          cloudUser: state.cloudUser!,
          neighborhood: state.neighborhood!,
          household: state.household!,
          isLoading: true,
          loadingText: loadingTextEventEditing,
          exception: null,
        ));
        try {
          //update existing event
          final eventId = event.eventId!;
          await _cloudProvider.updateEvent(
            eventId: eventId,
            title: event.title,
            text: event.text,
            dateStart: event.dateStart,
            dateEnd: event.dateEnd,
            placeName: event.placeName,
            location: event.location,
          );
        } catch (e) {
          //inform user of error
          emit(AppStateViewingNeighborhood(
            cloudUser: state.cloudUser!,
            neighborhood: state.neighborhood!,
            household: state.household!,
            isLoading: false,
            loadingText: null,
            exception: e,
          ));
          return;
        }
      } else {
        emit(AppStateViewingNeighborhood(
          cloudUser: state.cloudUser!,
          neighborhood: state.neighborhood!,
          household: state.household!,
          isLoading: true,
          loadingText: loadingTextEventCreation,
          exception: null,
        ));
        //create new event
        try {
          await _cloudProvider.createNewEvent(
            title: event.title,
            text: event.text,
            dateStart: event.dateStart,
            dateEnd: event.dateEnd,
            placeName: event.placeName,
            location: event.location,
          );
        } catch (e) {
          //inform user of error
          emit(AppStateViewingNeighborhood(
            cloudUser: state.cloudUser!,
            neighborhood: state.neighborhood!,
            household: state.household!,
            isLoading: false,
            loadingText: null,
            exception: e,
          ));
          return;
        }
      }
      //emit success
      emit(AppStateViewingNeighborhood(
        neighborhood: state.neighborhood!,
        isLoading: false,
        loadingText: loadingTextEventEditSuccess,
        exception: null,
        cloudUser: state.cloudUser!,
        household: state.household!,
      ));
    });

    on<AppEventDeleteEvent>((event, emit) async {
      //enable loading indicator
      emit(AppStateViewingNeighborhood(
        neighborhood: state.neighborhood!,
        household: state.household!,
        isLoading: true,
        loadingText: loadingTextDefault,
        exception: null,
        cloudUser: state.cloudUser!,
      ));
      try {
        await _cloudProvider.deleteEvent(
          eventId: event.eventId,
        );
      } on Exception catch (e) {
        emit(AppStateViewingNeighborhood(
          neighborhood: state.neighborhood!,
          household: state.household!,
          cloudUser: state.cloudUser!,
          isLoading: false,
          loadingText: null,
          exception: e,
        ));
        return;
      }
      //Send user to rulebooks view
      emit(AppStateViewingNeighborhood(
        neighborhood: state.neighborhood!,
        isLoading: false,
        loadingText: loadingTextEventDeleteSuccess,
        exception: null,
        cloudUser: state.cloudUser!,
        household: state.household!,
      ));
    });

    //Posts Events
    on<AppEventCreatePost>((event, emit) async {
      //validate access
      if (!await _isValidNeighborhoodAccess()) {
        add(const AppEventReset());
        return;
      }
      //get credentials
      final cloudUser = await _cloudProvider.cachedCloudUser;
      final neighborhood = await _cloudProvider.cachedNeighborhood;
      final household = await _cloudProvider.cachedHousehold;
      //enable loading indicator
      emit(AppStateViewingNeighborhood(
        cloudUser: cloudUser!,
        neighborhood: neighborhood!,
        household: household!,
        isLoading: true,
        loadingText: loadingTextPostCreation,
        exception: null,
      ));
      //create post
      try {
        await _cloudProvider.createNewPost(text: event.text);
      } on Exception catch (e) {
        emit(AppStateViewingNeighborhood(
          cloudUser: cloudUser,
          neighborhood: neighborhood,
          household: household,
          isLoading: false,
          loadingText: null,
          exception: e,
        ));
        return;
      }
      emit(AppStateViewingNeighborhood(
        isLoading: false,
        exception: null,
        loadingText: loadingTextPostCreationSuccess,
        cloudUser: cloudUser,
        neighborhood: neighborhood,
        household: household,
      ));
    });

    on<AppEventLikePost>(
      (event, emit) async {
        //validate access
        if (!await _isValidNeighborhoodAccess()) {
          add(const AppEventReset());
          return;
        }
        //like post
        try {
          await _cloudProvider.likePost(postId: event.postId);
        } on Exception catch (_) {
          return;
        }
      },
    );

    on<AppEventUnlikePost>(
      (event, emit) async {
        //validate access
        if (!await _isValidNeighborhoodAccess()) {
          add(const AppEventReset());
          return;
        }
        //unlike post
        try {
          await _cloudProvider.unlikePost(postId: event.postId);
        } on Exception catch (_) {
          return;
        }
      },
    );
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
  Future<CloudUser?> userFromId(String userId) async {
    if (userId.isEmpty) {
      return null;
    }
    try {
      return await _cloudProvider.userFromId(userId: userId);
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

  Stream<Iterable<Post>> get posts async* {
    final cloudUSer = await _cloudProvider.cachedCloudUser;
    yield* _cloudProvider.neighborhoodPosts(
      neighborhoodId: cloudUSer!.neighborhoodId!,
    );
  }
}
