class CloudException implements Exception {
  const CloudException();
}

class CouldNotCreateRulebooksException extends CloudException {}

class CouldNotGetRulebooksException extends CloudException {}

class CouldNotUpdateRulebooksException extends CloudException {}

class CouldNotDeleteRulebookException extends CloudException {}

class ChannelErrorRulebookException extends CloudException {}

class CouldNotCreateCloudUserException extends CloudException {}

class CouldNotUpdateUserException extends CloudException {}

class CloudProviderNotInitializedException extends CloudException {}

class CouldNotInitializeCloudProviderException extends CloudException {}

class UserAlreadyExistsException extends CloudException {}

class CouldNotUpdateHouseholdException extends CloudException {}

class UserDoesNotExistException extends CloudException {}

class UserRequiresHouseholdException extends CloudException {}

class CouldNotAssignNeighborhoodException extends CloudException {}

class CouldNotCreateRulebookException extends CloudException {}

class CouldNotGetRulebookException extends CloudException {}

class CouldNotDeleteCloudUserException extends CloudException {}
