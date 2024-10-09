import 'package:bloc/bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
//import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/services/bloc/app_event.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc(AuthProvider provider)
      : super(const AppStateUnInitalized(
          isLoading: true,
        )) {
    //initialize
    on<AppEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
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
    // register with email and password
    on<AppEventRegisterWithEmailAndPassword>((event, emit) async {
      final email = event.email;
      final password = event.password;
      final passwordConfirmation = event.passwordConfirmation;
      try {
        emit(const AppStateRegistering(
          exception: null,
          isLoading: true,
        ));
        final user = await provider.createUser(
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
        await provider.sendEmailVerification();
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
    // send email verification
    on<AppEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    //check if email is verified
    on<AppEventConfirmUserIsVerified>((event, emit) async {
      try {
        final userVerified = await provider.confirmUserIsVerified();
        emit(AppStateViewingHome(
          user: userVerified,
          exception: null,
          isLoading: false,
        ));
      } on AuthException catch (e) {
        final user = provider.currentUser!;
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
    //login with email and password
    on<AppEventLogInWithEmailAndPassword>((event, emit) async {
      try {
        emit(const AppStateLoggingIn(
          exception: null,
          isLoading: true,
          loadingText: 'Entrando...',
        ));
        final email = event.email;
        final password = event.password;
        final user = await provider.logInWithEmailAndPassword(
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
    //log out
    on<AppEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
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
    //delete account
    on<AppEventDeleteAccount>((event, emit) async {
      try {
        await provider.deleteAccount();
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
    //send to register view
    on<AppEventGoToRegistration>((event, emit) async {
      emit(const AppStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });
    //forgot password
    on<AppEventGoToForgotPassword>((event, emit) async {
      emit(AppStateResettingPassword(
        email: event.email,
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));
    });
    //send password reset email
    on<AppEventSendPasswordResetEmail>((event, emit) async {
      try {
        emit(AppStateResettingPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: true,
          email: event.email,
        ));
        await provider.sendPasswordResetEmail(email: event.email);
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
  }
}
