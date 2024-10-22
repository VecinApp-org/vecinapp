import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vecinapp/services/storage/storage_exceptions.dart';
import 'package:vecinapp/services/storage/storage_provider.dart';
import 'dart:developer' as devtools show log;

class FirebaseStorageProvider implements StorageProvider {
  @override
  Future<void> uploadProfileImage({
    required File image,
    required String userId,
  }) async {
    if (image.path.isEmpty) {
      throw GenericStorageException();
    }
    try {
      // upload the image to Firebase Storage
      await FirebaseStorage.instance
          .ref('user/$userId')
          .child('profile_image')
          .putFile(image)
          .onError((error, stackTrace) => throw GenericStorageException());
      // save the image to the cache directory

      final cacheDir = await getApplicationDocumentsDirectory();
      final cacheFile = File('${cacheDir.path}/$userId/profile_image');
      cacheFile.createSync(recursive: true);
      cacheFile.writeAsBytesSync(image.readAsBytesSync());
    } on Exception catch (e) {
      devtools.log(e.toString() + e.hashCode.toString());
      throw CouldNotUploadImageException();
    }
  }

  @override
  Future<Uint8List> getProfileImage({required String userId}) async {
    devtools.log('Getting image');
    // create a cache directory
    final cacheDir = await getApplicationDocumentsDirectory();
    final cacheFile = File('${cacheDir.path}/$userId/profile_image');

    // check if the file exists
    if (cacheFile.existsSync()) {
      // return the cached image
      return cacheFile.readAsBytes();
    }
    try {
      // try to download the image from Firebase Storage
      final Uint8List imageBytes = await FirebaseStorage.instance
          .ref('user/$userId')
          .child('profile_image')
          .getData()
          .then((value) => value as Uint8List)
          .onError((error, stackTrace) {
        if (error is FirebaseException) {
          if (error.code == 'storage/object-not-found') {
            throw ImageNotFoundStorageException();
          }
          devtools.log('Firebase Storage Error: ${error.toString()}');
          throw GenericStorageException();
        } else {
          devtools.log('Error: ${error.toString()}');
          throw GenericStorageException();
        }
      });

      // save the image to the cache directory
      cacheFile.createSync(recursive: true);
      cacheFile.writeAsBytesSync(imageBytes);
      return imageBytes;
    } catch (e) {
      rethrow;
    }
  }
}
