import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  //final String? email;
  final bool isEmailVerified;
  final String uid;
  final String? email;
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
    required this.uid,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        //user.email,
        isEmailVerified: user.emailVerified,
        uid: user.uid,
        email: user.email,
      );
}
