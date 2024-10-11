import 'package:bloc/bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
//import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/cloud/cloud_provider.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthProvider _authProvider;
  final CloudProvider _cloudProvider;
  AppBloc({
    required AuthProvider authProvider,
    required CloudProvider cloudProvider,
  })  : _authProvider = authProvider,
        _cloudProvider = cloudProvider,
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
      } else if (!user.isEmailVerified) {
        emit(AppStateNeedsVerification(
          user: user,
          exception: null,
          isLoading: false,
        ));
      } else {
        emit(AppStateViewingHome(
          exception: null,
          user: user,
          isLoading: false,
        ));
      }
    });

    on<AppEventRegisterWithEmailAndPassword>((event, emit) async {
      final email = event.email;
      final password = event.password;
      final passwordConfirmation = event.passwordConfirmation;
      try {
        emit(const AppStateRegistering(
          exception: null,
          isLoading: true,
        ));
        final user = await _authProvider.createUser(
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
        await _authProvider.sendEmailVerification();
        emit(AppStateNeedsVerification(
          user: user,
          exception: null,
          isLoading: false,
        ));
      } on AuthException catch (e) {
        emit(AppStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AppEventSendEmailVerification>((event, emit) async {
      await _authProvider.sendEmailVerification();
      emit(state);
    });

    on<AppEventConfirmUserIsVerified>((event, emit) async {
      try {
        final userVerified = await _authProvider.confirmUserIsVerified();
        emit(AppStateViewingHome(
          user: userVerified,
          exception: null,
          isLoading: false,
        ));
      } on AuthException catch (e) {
        final user = _authProvider.currentUser!;
        if (e is UserNotVerifiedAuthException) {
          emit(
            AppStateNeedsVerification(
              user: user,
              isLoading: false,
              exception: e,
            ),
          );
        } else if (e is NetworkRequestFailedAuthException) {
          emit(
            AppStateNeedsVerification(
              user: user,
              isLoading: false,
              exception: e,
            ),
          );
        } else if (e is GenericAuthException) {
          emit(
            AppStateNeedsVerification(
              user: user,
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
            user: user,
            exception: null,
            isLoading: false,
          ));
        } else {
          emit(AppStateViewingHome(
            exception: null,
            user: user,
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

    on<AppEventLogOut>((event, emit) async {
      try {
        await _authProvider.logOut();
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
      } on AuthException catch (e) {
        emit(AppStateLoggingIn(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AppEventDeleteAccount>((event, emit) async {
      try {
        await _authProvider.deleteAccount();
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
      } on AuthException catch (e) {
        if (state is AppStateViewingHome) {
          final actualUser = (state as AppStateViewingHome).user;
          emit(AppStateViewingHome(
            user: actualUser,
            exception: e,
            isLoading: false,
          ));
        } else {
          emit(AppStateLoggingIn(
            exception: e,
            isLoading: false,
          ));
        }
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

    //Authentication Events
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

    //Main App Routing
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

    on<AppEventGoToHomeView>((event, emit) async {
      final user = _authProvider.currentUser;
      if (user == null) {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: false,
        ));
      } else {
        emit(AppStateViewingHome(
          user: user,
          isLoading: false,
          exception: null,
        ));
      }
    });

    on<AppEventGoToSettingsView>((event, emit) async {
      emit(const AppStateViewingSettings(
        isLoading: false,
        exception: null,
      ));
    });
  }
}
