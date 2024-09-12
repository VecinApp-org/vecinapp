import 'package:bloc/bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
//import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/auth/bloc/auth_state.dart';
import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUnInitalized(
          isLoading: true,
        )) {
    //initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(
          const AuthStateRegistering(
            exception: null,
            isLoading: false,
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(AuthStateNeedsVerification(
          user: user,
          exception: null,
          isLoading: false,
        ));
      } else {
        emit(AuthStateLoggedIn(
          exception: null,
          user: user,
          isLoading: false,
        ));
      }
    });
    // register with email and password
    on<AuthEventRegisterWithEmailAndPassword>((event, emit) async {
      final email = event.email;
      final password = event.password;
      final passwordConfirmation = event.passwordConfirmation;
      try {
        emit(const AuthStateRegistering(
          exception: null,
          isLoading: true,
        ));
        final user = await provider.createUser(
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
        await provider.sendEmailVerification();
        emit(AuthStateNeedsVerification(
          user: user,
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });
    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    //check if email is verified
    on<AuthEventConfirmUserIsVerified>((event, emit) async {
      try {
        final userVerified = await provider.confirmUserIsVerified();
        emit(AuthStateLoggedIn(
          user: userVerified,
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        final user = provider.currentUser!;
        if (e is UserNotVerifiedAuthException) {
          emit(
            AuthStateNeedsVerification(
              user: user,
              isLoading: false,
              exception: e,
            ),
          );
        } else if (e is NetworkRequestFailedAuthException) {
          emit(
            AuthStateNeedsVerification(
              user: user,
              isLoading: false,
              exception: e,
            ),
          );
        } else if (e is GenericAuthException) {
          emit(
            AuthStateNeedsVerification(
              user: user,
              isLoading: false,
              exception: e,
            ),
          );
        } else if (e is UserNotLoggedInAuthException) {
          emit(
            AuthStateLoggedOut(
              exception: e,
              isLoading: false,
            ),
          );
        }
      }
    });
    //login with email and password
    on<AuthEventLogInWithEmailAndPassword>((event, emit) async {
      try {
        emit(const AuthStateLoggedOut(
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
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
        //check if email is verified
        if (!user.isEmailVerified) {
          emit(AuthStateNeedsVerification(
            user: user,
            exception: null,
            isLoading: false,
          ));
        } else {
          emit(AuthStateLoggedIn(
            exception: null,
            user: user,
            isLoading: false,
          ));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });
    //log out
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });
    //delete account
    on<AuthEventDeleteAccount>((event, emit) async {
      try {
        await provider.deleteAccount();
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        if (state is AuthStateLoggedIn) {
          final actualUser = (state as AuthStateLoggedIn).user;
          emit(AuthStateLoggedIn(
            user: actualUser,
            exception: e,
            isLoading: false,
          ));
        } else {
          emit(AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ));
        }
      }
    });
    //send to register view
    on<AuthEventShouldRegister>((event, emit) async {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });
    //forgot password
    on<AuthEventForgotPassword>((event, emit) async {
      emit(AuthStateResettingPassword(
        email: event.email,
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));
    });
    //send password reset email
    on<AuthEventSendPasswordResetEmail>((event, emit) async {
      try {
        emit(AuthStateResettingPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: true,
          email: event.email,
        ));
        await provider.sendPasswordResetEmail(email: event.email);
        emit(AuthStateResettingPassword(
          email: event.email,
          exception: null,
          hasSentEmail: true,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateResettingPassword(
          email: null,
          exception: e,
          hasSentEmail: false,
          isLoading: false,
        ));
      }
    });
  }
}
