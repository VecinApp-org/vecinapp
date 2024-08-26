import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  //final String? email;
  final bool isEmailVerified;
  final String uid;
  const AuthUser(
    //this.email,
    this.isEmailVerified,
    this.uid,
  );

  factory AuthUser.fromFirebase(User user) => AuthUser(
        //user.email,
        user.emailVerified,
        user.uid,
      );
}
