import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/services/auth/auth_user.dart';
import 'package:vecinapp/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) =>
      provider.createUser(
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      provider.logInWithEmailAndPassword(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Stream<AuthUser> userChanges() => provider.userChanges();

  @override
  Future<void> deleteAccount() => provider.deleteAccount();

  @override
  Future<void> reload() => provider.reload();
}
