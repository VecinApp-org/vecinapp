import 'package:vecinapp/services/auth/auth_user.dart';
import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:vecinapp/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

import 'dart:developer' as devtools show log;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (passwordConfirmation.isEmpty || password.isEmpty || email.isEmpty) {
      throw ChannelErrorAuthException();
    }
    if (password != passwordConfirmation) {
      throw PasswordConfirmationDoesNotMatchAuthException();
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return currentUser!;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw EmailAlreadyInUseAuthException();
        case 'network-request-failed':
          throw NetworkRequestFailedAuthException();
        case 'weak-password':
          throw WeakPasswordAuthException();
        case 'invalid-email':
          throw InvalidEmailAuthException();
        case 'channel-error':
          throw ChannelErrorAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    devtools.log(user.toString());
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw InvalidEmailAuthException();
        case 'invalid-credential':
          throw InvalidCredentialAuthException();
        case 'network-request-failed':
          throw NetworkRequestFailedAuthException();
        case 'channel-error':
          throw ChannelErrorAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user != null) {
      try {
        await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'network-request-failed':
            throw NetworkRequestFailedAuthException();
          case 'too-many-requests':
            throw TooManyRequestsAuthException();
          default:
            devtools.log('Unexpected error while sending email: ${e.code}');
            throw GenericAuthException();
        }
      }
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Stream<AuthUser> userChanges() {
    return FirebaseAuth.instance.userChanges().map(
          (user) => AuthUser.fromFirebase(user!),
        );
  }

  @override
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      try {
        await FirebaseAuth.instance.currentUser!.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw RequiresRecentLoginAuthException();
        } else if (e.code == 'network-request-failed') {
          throw NetworkRequestFailedAuthException();
        } else {
          throw GenericAuthException();
        }
      }
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<AuthUser> confirmUserIsVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw UserNotLoggedInAuthException();
    }

    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedAuthException();
      } else {
        throw GenericAuthException();
      }
    }

    final userReloaded = currentUser;

    if (userReloaded == null) {
      throw UserNotLoggedInAuthException();
    }

    if (userReloaded.isEmailVerified) {
      return userReloaded;
    } else {
      throw UserNotVerifiedAuthException();
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'network-request-failed':
          throw NetworkRequestFailedAuthException();
        case 'channel-error':
          throw ChannelErrorAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> updateUserDisplayName(String displayName) async {
    final user = currentUser;
    if (user == null) {
      throw UserNotLoggedInAuthException();
    }

    if (displayName.isEmpty) {
      throw ChannelErrorAuthException();
    }

    if (displayName == user.displayName) {
      return user;
    }

    try {
      await FirebaseAuth.instance.currentUser!.updateDisplayName(displayName);
      await FirebaseAuth.instance.currentUser!.reload();
    } on FirebaseAuthException catch (e) {
      devtools.log(e.code.toString());
      if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }

    final AuthUser? userReloaded = currentUser;
    if (userReloaded == null) {
      throw UserNotLoggedInAuthException();
    }

    return userReloaded;
  }
}
