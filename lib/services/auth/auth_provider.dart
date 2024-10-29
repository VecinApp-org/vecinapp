import 'package:flutter/foundation.dart';
import 'package:vecinapp/services/auth/auth_user.dart';

@immutable
abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> logInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String passwordConfirmation,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Stream<AuthUser> userChanges();
  Future<void> deleteAccount();
  Future<AuthUser> confirmUserIsVerified();
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> updateUserPhotoUrl({required String photoUrl});
}
