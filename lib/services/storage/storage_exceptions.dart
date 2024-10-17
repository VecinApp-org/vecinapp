class StorageException implements Exception {
  const StorageException();
}

class GenericStorageException implements StorageException {}

class CouldNotUploadImageException implements StorageException {}
