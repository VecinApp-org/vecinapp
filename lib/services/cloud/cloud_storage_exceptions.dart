class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateDocException extends CloudStorageException {}

class CouldNotGetDocsException extends CloudStorageException {}

class CouldNotUpdateDocException extends CloudStorageException {}

class CouldNotDeleteDocException extends CloudStorageException {}
