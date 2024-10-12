class CloudException implements Exception {
  const CloudException();
}

class CouldNotCreateRulebooksException extends CloudException {}

class CouldNotGetRulebooksException extends CloudException {}

class CouldNotUpdateRulebooksException extends CloudException {}

class CouldNotDeleteRulebookException extends CloudException {}

class ChannelErrorRulebookException extends CloudException {}
