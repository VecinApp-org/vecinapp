class AuthException implements Exception {
  const AuthException();
}

// login exceptions
class InvalidCredentialAuthException implements AuthException {}

// register exceptions
class EmailAlreadyInUseAuthException implements AuthException {}

class WeakPasswordAuthException implements AuthException {}

class PasswordConfirmationDoesNotMatchAuthException implements AuthException {}

// delete user exceptions
class RequiresRecentLoginAuthException implements AuthException {}

// send email verification exceptions
class TooManyRequestsAuthException implements AuthException {}

class UserNotVerifiedAuthException implements AuthException {}

// input exceptions
class ChannelErrorAuthException implements AuthException {}

class InvalidEmailAuthException implements AuthException {}

// network exceptions
class NetworkRequestFailedAuthException implements AuthException {}

// general exceptions
class GenericAuthException implements AuthException {}

class UserNotLoggedInAuthException implements AuthException {}
