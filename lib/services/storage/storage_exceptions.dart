class StorageException implements Exception {
  final String message;
  const StorageException({this.message = 'Error de almacenamiento'});
}

class GenericStorageException extends StorageException {
  const GenericStorageException({String? message})
      : super(message: 'Error de almacenamiento');
}

class CouldNotUploadImageStorageException extends StorageException {
  const CouldNotUploadImageStorageException({String? message})
      : super(message: 'No se pudo subir la imagen');
}

class ImageNotFoundStorageException extends StorageException {
  const ImageNotFoundStorageException({String? message})
      : super(message: 'Imagen no encontrada');
}

class ImageTooLargeStorageException extends StorageException {
  const ImageTooLargeStorageException({String? message})
      : super(message: 'La imagen es demasiado grande');
}

class CouldNotDeleteImageStorageException extends StorageException {
  const CouldNotDeleteImageStorageException({String? message})
      : super(message: 'No se pudo eliminar la imagen');
}
