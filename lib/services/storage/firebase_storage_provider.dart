import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vecinapp/services/storage/storage_exceptions.dart';
import 'package:vecinapp/services/storage/storage_provider.dart';
import 'dart:developer' as devtools show log;

class FirebaseStorageProvider implements StorageProvider {
  @override
  Future<String> uploadProfileImage({
    required File image,
    required String userId,
  }) async {
    if (image.path.isEmpty) {
      throw GenericStorageException();
    }
    late final String url;
    try {
      // create file and get url
      url = await FirebaseStorage.instance
          .ref('user/$userId')
          .child('profile_image')
          .putFile(image)
          .then((value) {
        return value.ref.getDownloadURL();
      }).onError((error, stackTrace) => throw GenericStorageException());
    } on Exception catch (e) {
      devtools.log(e.toString() + e.hashCode.toString());
      throw CouldNotUploadImageException();
    }
    return url;
  }

  @override
  Future<Uint8List> getProfileImage({required String userId}) async {
    devtools.log('Getting image');
    // Check if image is cached

    return await FirebaseStorage.instance
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
  }
}
