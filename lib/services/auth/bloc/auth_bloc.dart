import 'package:bloc/bloc.dart';
import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUnInitalized()) {
    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    // register with email and password
    on<AuthEventRegisterWithEmailAndPassword>((event, emit) async {
      final email = event.email;
      final password = event.password;
      final passwordConfirmation = event.passwordConfirmation;
      try {
        await provider.createUser(
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e));
      }
    });
    //initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });
    //login with email and password
    on<AuthEventLogInWithEmailAndPassword>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
        ),
      );
      final email = event.email;
      final password = event.password;
      try {
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
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateLoggedIn(user));
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
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
    //delete account
    on<AuthEventDeleteAccount>((event, emit) async {
      try {
        await provider.deleteAccount();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    on<AuthEventShouldRegister>((event, emit) async {
      emit(const AuthStateRegistering(exception: null));
    });
  }
}
