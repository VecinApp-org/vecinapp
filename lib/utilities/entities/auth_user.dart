import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart' show immutable;

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.phoneNumber,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
      );

  @override
  String toString() {
    return 'AuthUser{isEmailVerified: $isEmailVerified, uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber}';
  }
}
