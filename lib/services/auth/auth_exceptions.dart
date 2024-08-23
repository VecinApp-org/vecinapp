// login exceptions
class InvalidCredentialAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// register exceptions
class EmailAlreadyInUseAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

// input exceptions
class ChannelErrorAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// network exceptions
class NetworkRequestFailedAuthException implements Exception {}

// general exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
