class CloudException implements Exception {
  final String message;
  const CloudException({this.message = 'Error de nube'});
}

// General
class CouldNotInitializeCloudProviderException extends CloudException {
  const CouldNotInitializeCloudProviderException()
      : super(message: 'Could not initialize cloud provider');
}

class CloudProviderNotInitializedException extends CloudException {
  const CloudProviderNotInitializedException()
      : super(message: 'Cloud provider not initialized');
}

class ChannelErrorCloudException extends CloudException {
  const ChannelErrorCloudException() : super(message: 'Dejaste algo vacío');
}

// Rulebooks
class CouldNotUpdateRulebookException extends CloudException {
  const CouldNotUpdateRulebookException()
      : super(message: 'No se pudo actualizar el reglamento');
}

class CouldNotDeleteRulebookException extends CloudException {
  const CouldNotDeleteRulebookException()
      : super(message: 'No se pudo borrar el reglamento');
}

class CouldNotCreateRulebookException extends CloudException {
  const CouldNotCreateRulebookException()
      : super(message: 'No se pudo crear el reglamento');
}

class CouldNotGetRulebookException extends CloudException {
  const CouldNotGetRulebookException()
      : super(message: 'No se pudo obtener el reglamento');
}

// Users
class UserDoesNotExistException extends CloudException {
  const UserDoesNotExistException() : super(message: 'El usuario no existe');
}

class CouldNotCreateCloudUserException extends CloudException {
  const CouldNotCreateCloudUserException()
      : super(message: 'No se pudo crear el usuario');
}

class CouldNotUpdateUserException extends CloudException {
  const CouldNotUpdateUserException()
      : super(message: 'No se pudo actualizar el usuario');
}

class CouldNotDeleteCloudUserException extends CloudException {
  const CouldNotDeleteCloudUserException()
      : super(message: 'No se pudo borrar el usuario');
}

class UserAlreadyExistsException extends CloudException {
  const UserAlreadyExistsException() : super(message: 'El usuario ya existe');
}

class UserRequiresHouseholdException extends CloudException {
  const UserRequiresHouseholdException()
      : super(message: 'El usuario debe pertenecer a un hogar');
}

// Households
class CouldNotGetHouseholdException extends CloudException {
  const CouldNotGetHouseholdException()
      : super(message: 'No se pudo obtener el hogar');
}

class CouldNotUpdateHouseholdException extends CloudException {
  const CouldNotUpdateHouseholdException()
      : super(message: 'No se pudo actualizar el hogar');
}

class CouldNotExitHouseholdException extends CloudException {
  const CouldNotExitHouseholdException()
      : super(message: 'No se pudo salir del hogar');
}

// Neighborhood
class CouldNotAssignNeighborhoodException extends CloudException {
  const CouldNotAssignNeighborhoodException()
      : super(message: 'No se pudo asignar la vecindad');
}

class CouldNotExitNeighborhoodException extends CloudException {
  const CouldNotExitNeighborhoodException()
      : super(message: 'No se pudo salir de la vecindad');
}

// Events
class CouldNotCreateEventException extends CloudException {
  const CouldNotCreateEventException()
      : super(message: 'No se pudo crear el evento');
}

class CouldNotGetEventsException extends CloudException {
  const CouldNotGetEventsException()
      : super(message: 'No se pudo obtener los eventos');
}

class CouldNotGetEventException extends CloudException {
  const CouldNotGetEventException()
      : super(message: 'No se pudo obtener el evento');
}

class CouldNotDeleteEventException extends CloudException {
  const CouldNotDeleteEventException()
      : super(message: 'No se pudo borrar el evento');
}

class CouldNotUpdateEventException extends CloudException {
  const CouldNotUpdateEventException()
      : super(message: 'No se pudo actualizar el evento');
}

class EventStartsAfterEndsCloudException extends CloudException {
  const EventStartsAfterEndsCloudException()
      : super(message: 'La fecha de inicial debe ser antes de la fecha final');
}

class EventDateInvalidCloudException extends CloudException {
  const EventDateInvalidCloudException()
      : super(message: 'La fecha del evento es demasiado lejana');
}

// Posts
class CouldNotCreatePostException extends CloudException {
  const CouldNotCreatePostException() : super(message: 'Inténtalo de nuevo');
}

class CouldNotGetPostException extends CloudException {
  const CouldNotGetPostException()
      : super(message: 'No se pudo obtener la publicación');
}

class CouldNotDeletePostException extends CloudException {
  const CouldNotDeletePostException()
      : super(message: 'No se pudo borrar la publicación');
}

// Admin
class PermissionDeniedCloudException extends CloudException {
  const PermissionDeniedCloudException() : super(message: 'Permiso denegado');
}
