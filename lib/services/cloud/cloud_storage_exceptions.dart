class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateRulebooksException extends CloudStorageException {}

class CouldNotGetRulebooksException extends CloudStorageException {}

class CouldNotUpdateRulebooksException extends CloudStorageException {}

class CouldNotDeleteRulebookException extends CloudStorageException {}

class ChannelErrorRulebookException extends CloudStorageException {}
