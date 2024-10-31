class StorageException implements Exception {
  const StorageException();
}

class GenericStorageException implements StorageException {}

class CouldNotUploadImageStorageException implements StorageException {}

class ImageNotFoundStorageException implements StorageException {}

class ImageTooLargeStorageException implements StorageException {}

class CouldNotDeleteImageStorageException implements StorageException {}
