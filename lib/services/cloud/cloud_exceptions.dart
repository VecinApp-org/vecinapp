class CloudException implements Exception {
  const CloudException();
}

// General
class CouldNotInitializeCloudProviderException extends CloudException {}

class CloudProviderNotInitializedException extends CloudException {}

class ChannelErrorCloudException extends CloudException {}

// Rulebooks

class CouldNotUpdateRulebookException extends CloudException {}

class CouldNotDeleteRulebookException extends CloudException {}

class CouldNotCreateRulebookException extends CloudException {}

class CouldNotGetRulebookException extends CloudException {}

// Users
class UserDoesNotExistException extends CloudException {}

class CouldNotCreateCloudUserException extends CloudException {}

class CouldNotUpdateUserException extends CloudException {}

class CouldNotDeleteCloudUserException extends CloudException {}

class UserAlreadyExistsException extends CloudException {}

class UserRequiresHouseholdException extends CloudException {}

// Households
class CouldNotGetHouseholdException extends CloudException {}

class CouldNotUpdateHouseholdException extends CloudException {}

class CouldNotExitHouseholdException extends CloudException {}

// Neighborhood
class CouldNotAssignNeighborhoodException extends CloudException {}

class CouldNotExitNeighborhoodException extends CloudException {}

// Events
class CouldNotCreateEventException extends CloudException {}

class CouldNotGetEventsException extends CloudException {}

class CouldNotDeleteEventException extends CloudException {}

class CouldNotUpdateEventException extends CloudException {}
