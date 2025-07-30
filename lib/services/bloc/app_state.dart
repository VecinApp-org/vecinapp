import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:vecinapp/utilities/entities/auth_user.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'package:vecinapp/utilities/entities/address.dart';

import 'package:vecinapp/utilities/entities/post_with_user.dart'; // ignore: unused_import

enum PostsStatus { initial, loading, success, failure }

@immutable
abstract class AppState {
  const AppState({
    required this.isLoading,
    required this.exception,
    this.user,
    this.loadingText,
    this.cloudUser,
    this.household,
    this.neighborhood,
    this.posts,
    this.postsStatus,
    this.hasReachedMaxPosts,
  });
  final bool isLoading;
  final Exception? exception;
  final String? loadingText;
  final AuthUser? user;
  final CloudUser? cloudUser;
  final Household? household;
  final Neighborhood? neighborhood;
  final List<PostWithUser>? posts;
  final PostsStatus? postsStatus;
  final bool? hasReachedMaxPosts;
}

class AppStateUnInitalized extends AppState {
  const AppStateUnInitalized({required bool isLoading})
      : super(
          isLoading: isLoading,
          exception: null,
        );
}

class AppStateError extends AppState with EquatableMixin {
  const AppStateError({
    required Exception? exception,
    required bool isLoading,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );
  @override
  List<Object?> get props => [exception, isLoading];
}

//AUTHENTICATION STATES
class AppStateLoggedOut extends AppState with EquatableMixin {
  const AppStateLoggedOut({
    required bool isLoading,
    required String? loadingText,
    AuthUser? user,
    required exception,
  }) : super(
          isLoading: isLoading,
          exception: exception,
          loadingText: loadingText,
          user: user,
        );

  @override
  List<Object?> get props => [exception, isLoading, loadingText, user];
}

class AppStateNeedsVerification extends AppState with EquatableMixin {
  const AppStateNeedsVerification({
    required bool isLoading,
    required exception,
  }) : super(
          isLoading: isLoading,
          exception: exception,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

//CLOUD REGISTRATION STATES
class AppStateCreatingCloudUser extends AppState with EquatableMixin {
  const AppStateCreatingCloudUser({
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateSelectingHomeAddress extends AppState with EquatableMixin {
  const AppStateSelectingHomeAddress({
    required bool isLoading,
    required exception,
  }) : super(isLoading: isLoading, exception: exception);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AppStateConfirmingHomeAddress extends AppState with EquatableMixin {
  final List<Address> addresses;
  const AppStateConfirmingHomeAddress({
    required bool isLoading,
    required exception,
    required this.addresses,
  }) : super(isLoading: isLoading, exception: exception);

  @override
  List<Object?> get props => [exception, isLoading, addresses];
}

class AppStateNoNeighborhood extends AppState with EquatableMixin {
  const AppStateNoNeighborhood({
    required bool isLoading,
    required String? loadingText,
    required exception,
    required AuthUser authUser,
    required CloudUser cloudUser,
    required Household household,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
          exception: exception,
          user: authUser,
          cloudUser: cloudUser,
          household: household,
        );

  @override
  List<Object?> get props =>
      [exception, isLoading, loadingText, cloudUser, household, user];
}

class AppStateWelcomeToNeighborhood extends AppState with EquatableMixin {
  const AppStateWelcomeToNeighborhood({required bool isLoading})
      : super(isLoading: isLoading, exception: null);

  @override
  List<Object?> get props => [exception, isLoading];
}

//MAIN APP STATES
class AppStateNeighborhood extends AppState with EquatableMixin {
  const AppStateNeighborhood({
    required bool isLoading,
    required Exception? exception,
    String? loadingText = 'Cargando...',
    required AuthUser authUser,
    required CloudUser cloudUser,
    required Household household,
    required Neighborhood neighborhood,
    List<PostWithUser> posts = const [],
    PostsStatus postsStatus = PostsStatus.initial,
    bool hasReachedMaxPosts = false,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
          exception: exception,
          user: authUser,
          cloudUser: cloudUser,
          neighborhood: neighborhood,
          household: household,
          posts: posts,
          postsStatus: postsStatus,
          hasReachedMaxPosts: hasReachedMaxPosts,
        );

  @override
  List<Object?> get props => [
        exception,
        isLoading,
        loadingText,
        user,
        cloudUser,
        neighborhood,
        household,
        posts,
      ];
}

//EXTENSIONS
extension GetAddresses on AppState {
  List<Address>? get addresses {
    if (this is AppStateConfirmingHomeAddress) {
      return (this as AppStateConfirmingHomeAddress).addresses;
    }
    return null;
  }
}

extension CopyWith on AppState {
  AppState copyWith({
    bool? isLoading,
    Exception? exception,
    String? loadingText,
    List<PostWithUser>? posts,
    PostsStatus? postsStatus,
    bool? hasReachedMaxPosts,
    CloudUser? cloudUser,
  }) {
    if (this is AppStateNeighborhood) {
      return AppStateNeighborhood(
        isLoading: isLoading ?? this.isLoading,
        exception: exception ?? this.exception,
        loadingText: loadingText ?? this.loadingText,
        authUser: user!,
        cloudUser: cloudUser ?? this.cloudUser!,
        neighborhood: neighborhood!,
        household: household!,
        posts: posts ?? this.posts!,
        postsStatus: postsStatus ?? this.postsStatus!,
        hasReachedMaxPosts: hasReachedMaxPosts ?? this.hasReachedMaxPosts!,
      );
    } else if (this is AppStateNoNeighborhood) {
      return AppStateNoNeighborhood(
          isLoading: isLoading ?? this.isLoading,
          loadingText: loadingText ?? this.loadingText,
          exception: exception ?? this.exception,
          authUser: user!,
          cloudUser: cloudUser ?? this.cloudUser!,
          household: household!);
    }
    return this;
  }
}
