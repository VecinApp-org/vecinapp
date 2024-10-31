import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vecinapp/services/storage/storage_exceptions.dart';
import 'package:vecinapp/services/storage/storage_provider.dart';
import 'dart:developer' as devtools show log;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FirebaseStorageProvider implements StorageProvider {
  @override
  Future<void> uploadProfileImage({
    required File image,
    required String userId,
  }) async {
    // check if the image is too large
    const int maxSizeInBytes = 6 * 1024 * 1024;
    if (image.lengthSync() > maxSizeInBytes) {
      throw ImageTooLargeStorageException();
    }
    try {
      // compress the image
      devtools.log('Compressing image...');
      final compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        minWidth: 200,
        minHeight: 200,
      );
      // check if the image is compressed
      if (compressedImage == null) {
        devtools.log('Failed to compress image...');
        throw CouldNotUploadImageStorageException();
      }
      // create a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image');
      await tempFile.writeAsBytes(compressedImage);
      // upload the image to Firebase Storage
      devtools.log('Uploading image...');
      await FirebaseStorage.instance
          .ref('user/$userId')
          .child('profile_image')
          .putFile(tempFile);
      // delete the temporary file
      await tempFile.delete();
      // save the image to the cache directory
      devtools.log('Saving image to cache directory...');
      final cacheDir = await getApplicationDocumentsDirectory();
      final cacheFile = File('${cacheDir.path}/$userId/profile_image');
      cacheFile.createSync(recursive: true);
      cacheFile.writeAsBytesSync(compressedImage);
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'object-not-found':
          throw ImageNotFoundStorageException();
        case 'network-request-failed':
          throw CouldNotUploadImageStorageException();
        default:
          throw GenericStorageException();
      }
    } on Exception catch (e) {
      devtools.log(e.toString() + e.hashCode.toString());
      throw GenericStorageException();
    }
  }

  @override
  Future<Uint8List> getProfileImage({required String userId}) async {
    // create a cache directory
    final cacheDir = await getApplicationDocumentsDirectory();
    final cacheFile = File('${cacheDir.path}/$userId/profile_image');

    // check if the file exists
    if (cacheFile.existsSync()) {
      // return the cached image
      return cacheFile.readAsBytes();
    }
    //download the image
    try {
      final Uint8List imageBytes = await FirebaseStorage.instance
          .ref('user/$userId')
          .child('profile_image')
          .getData()
          .then((value) => value as Uint8List);
      // save the image to the cache directory
      cacheFile.createSync(recursive: true);
      cacheFile.writeAsBytesSync(imageBytes);
      return imageBytes;
    } catch (e) {
      // throw an exception if the image couldn't be downloaded
      throw ImageNotFoundStorageException();
    }
  }

  @override
  Future<void> deleteProfileImage({required String userId}) async {
    // delete the image from Firebase Storage
    try {
      await FirebaseStorage.instance
          .ref('user/$userId')
          .child('profile_image')
          .delete()
          .then((value) => devtools.log('Profile image deleted'))
          .onError((error, stackTrace) => devtools.log(error.toString()));
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'object-not-found':
          return;
        default:
          throw CouldNotDeleteImageStorageException();
      }
    } catch (e) {
      throw GenericStorageException();
    }
    // delete the image from the cache directory
    try {
      final cacheDir = await getApplicationDocumentsDirectory();
      final cacheFile = File('${cacheDir.path}/$userId/profile_image');
      cacheFile.deleteSync();
    } catch (_) {
      // ignore
    }
  }
}
