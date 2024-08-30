import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:vecinapp/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText,
  });
}

class AuthStateUnInitalized extends AuthState {
  const AuthStateUnInitalized({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateRegistering({
    required this.exception,
    required bool isLoading,
  }) : super(isLoading: isLoading);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateLoggedIn extends AuthState with EquatableMixin {
  final AuthUser user;
  final Exception? exception;
  const AuthStateLoggedIn({
    required this.user,
    required this.exception,
    required bool isLoading,
  }) : super(isLoading: isLoading);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateNeedsVerification extends AuthState with EquatableMixin {
  final AuthUser user;
  final Exception? exception;
  const AuthStateNeedsVerification({
    required this.user,
    required bool isLoading,
    required this.exception,
  }) : super(
          isLoading: isLoading,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}
