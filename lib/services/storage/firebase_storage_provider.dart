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
  Future<String> uploadProfileImage({
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
      final downloadUrl = await FirebaseStorage.instance
          .ref('user/$userId')
          .child('profile_image')
          .putFile(tempFile)
          .then((value) => value.ref.getDownloadURL());
      // delete the temporary file
      await tempFile.delete();
      // save the image to the cache directory
      devtools.log('Saving image to cache directory...');
      final cacheDir = await getApplicationDocumentsDirectory();
      final cacheFile = File('${cacheDir.path}/$userId/profile_image');
      cacheFile.createSync(recursive: true);
      cacheFile.writeAsBytesSync(compressedImage);
      // return the download URL
      return downloadUrl;
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
  Future<Uint8List?> getProfileImage({required String userId}) async {
    // create a cache directory
    final cacheDir = await getApplicationDocumentsDirectory();
    final cacheFile = File('${cacheDir.path}/$userId/profile_image');

    // check if the file exists
    if (cacheFile.existsSync()) {
      // return the cached image
      return cacheFile.readAsBytes();
    }
    late final Uint8List? imageBytes;
    try {
      final filePath = 'user/$userId/profile_image';
      //check if the image exists in Firebase Storage
      final storageRef = FirebaseStorage.instance.ref(filePath);
      final listResult = await storageRef.list();
      if (listResult.items.isNotEmpty) {
        // return the image from Firebase Storage
        imageBytes = await FirebaseStorage.instance.ref(filePath).getData();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
    if (imageBytes == null) {
      return null;
    }
    // save the image to the cache directory
    cacheFile.createSync(recursive: true);
    cacheFile.writeAsBytesSync(imageBytes);
    return imageBytes;
  }

  @override
  Future<void> deleteProfileImage({required String userId}) async {
    // delete the image from Firebase Storage
    try {
      final filePath = 'user/$userId/profile_image';
      await FirebaseStorage.instance.ref(filePath).delete();
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
      if (cacheFile.existsSync()) {
        await cacheFile.delete();
      }
    } catch (_) {
      // ignore
    }
    devtools.log('Profile image deleted');
  }
}
