class AuthException implements Exception {
  final String message;
  const AuthException({this.message = 'Error de autenticación'});
}

// login exceptions
class InvalidCredentialAuthException extends AuthException {
  const InvalidCredentialAuthException()
      : super(message: 'La combinación de correo y contraseña es incorrecta');
}

// register exceptions
class EmailAlreadyInUseAuthException extends AuthException {
  const EmailAlreadyInUseAuthException()
      : super(message: 'Ese correo ya tiene una cuenta asociada');
}

class WeakPasswordAuthException extends AuthException {
  const WeakPasswordAuthException()
      : super(message: 'La contraseña es muy débil');
}

class PasswordConfirmationDoesNotMatchAuthException extends AuthException {
  const PasswordConfirmationDoesNotMatchAuthException()
      : super(message: 'Las contraseñas no coinciden');
}

// delete user exceptions
class RequiresRecentLoginAuthException extends AuthException {
  const RequiresRecentLoginAuthException()
      : super(message: 'Para eso es necesario volver a iniciar sesión');
}

// send email verification exceptions
class TooManyRequestsAuthException extends AuthException {
  const TooManyRequestsAuthException()
      : super(message: 'Demasiados intentos, espera unos minutos');
}

class UserNotVerifiedAuthException extends AuthException {
  const UserNotVerifiedAuthException()
      : super(message: 'Aún no has verificado tu correo');
}

// input exceptions
class ChannelErrorAuthException extends AuthException {
  const ChannelErrorAuthException() : super(message: 'Dejaste algo vacío');
}

class InvalidEmailAuthException extends AuthException {
  const InvalidEmailAuthException()
      : super(message: 'El correo está mal escrito');
}

// network exceptions
class NetworkRequestFailedAuthException extends AuthException {
  const NetworkRequestFailedAuthException() : super(message: 'No hay internet');
}

// general exceptions
class GenericAuthException extends AuthException {
  const GenericAuthException() : super(message: 'Error de autenticación');
}

class UserNotLoggedInAuthException extends AuthException {
  const UserNotLoggedInAuthException()
      : super(message: 'Para eso necesitas iniciar sesión');
}
