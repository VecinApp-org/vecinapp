import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart' show immutable;

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String? uid;
  final String? email;
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
    required this.uid,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        uid: user.uid,
        email: user.email,
      );
}
