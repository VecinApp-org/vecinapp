import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vecinapp/extensions/formatting/format_event_date_time.dart';
import 'package:vecinapp/services/storage/storage_exceptions.dart';
import 'package:vecinapp/services/storage/storage_provider.dart';
import 'dart:developer' as devtools show log;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FirebaseStorageProvider implements StorageProvider {
  late final Directory _cacheDir;
  late final FirebaseStorage _storage;

  @override
  Future initialize() async {
    _cacheDir = await getTemporaryDirectory();
    _storage = FirebaseStorage.instance;
  }

  @override
  Future<String> uploadProfileImage({
    required File image,
    required String userId,
  }) async {
    // check if the image is too large
    const int maxSizeInBytes = 6 * 1024 * 1024;
    if (await image.length() > maxSizeInBytes) {
      throw ImageTooLargeStorageException();
    }
    try {
      // compress the image
      devtools.log('Compressing image...');
      final compressedBytes = await _compressImage(image);

      // upload the image to Firebase Storage
      devtools.log('Uploading image...');
      final filePath = 'user/$userId/profile_image';
      final storageRef = _storage.ref(filePath);

      // Set content type for proper display in browsers and for Firebase Rules
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      final uploadTask = storageRef.putData(compressedBytes, metadata);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 4. Update local cache asynchronously and efficiently
      devtools.log('Updating local cache...');
      await _updateCache(userId: userId, imageBytes: compressedBytes);

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
  Stream<Uint8List?> getProfileImage({required String userId}) async* {
    devtools.log('$userId getProfileImage...');
    final cacheFile = File('${_cacheDir.path}/$userId/profile_image');
    late final bool cacheExists;
    // read the image from the cache
    try {
      cacheExists = cacheFile.existsSync();
      if (cacheExists) {
        yield cacheFile.readAsBytesSync();
        final lastModified = cacheFile.lastModifiedSync();
        if (lastModified
            .isAfter(DateTime.now().subtract(const Duration(minutes: 10)))) {
          devtools.log(
              '$userId Fresh. Refreshing ${lastModified.add(const Duration(minutes: 10))}');
          yield await cacheFile.readAsBytes();
          return;
        }
      }
    } catch (_) {}

    // read the image from Firebase Storage
    try {
      final filePath = 'user/$userId/profile_image';
      yield await _storage.ref(filePath).getData().then((file) async {
        if (file != null) {
          cacheFile.createSync(recursive: true);
          await cacheFile
              .writeAsBytes(file)
              .then((file) => file.setLastModifiedSync(DateTime.now()));
        }
        devtools.log('$userId Read image from Firebase Storage.');
        return file;
      });
      return;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        if (cacheExists) {
          devtools.log('$userId deleted image from local cache...');
          cacheFile.deleteSync();
        }
        devtools.log('$userId Image did not exist in Storage...');
        yield null;
        return;
      }
      // return the image from the cache
      if (cacheExists) {
        devtools.log('Reading image from local cache after Firebase error...');
        yield await cacheFile.readAsBytes();
      }
      yield null;
    } catch (_) {
      if (cacheExists) {
        devtools.log('Reading image from local cache after error...');
        yield await cacheFile.readAsBytes();
      }
      yield null;
    }
  }

  @override
  Future<void> deleteProfileImage({required String userId}) async {
    final filePath = 'user/$userId/profile_image';
    final storageRef = _storage.ref(filePath);

    try {
      // 1. Attempt to delete the remote file from Firebase Storage.
      devtools.log('Attempting to delete image from Firebase Storage...');
      await storageRef.delete();
      devtools.log('Remote image deleted successfully.');
    } on FirebaseException catch (e) {
      // If the file doesn't exist, it's a success from the user's perspective.
      // The goal is for the image to be gone, and it already is.
      if (e.code == 'object-not-found') {
        devtools.log('Image did not exist in Storage. No action needed.');
      } else {
        // This indicates a more serious problem, like a permissions error.
        devtools.log('Firebase error during deletion: ${e.message}');
        throw CouldNotDeleteImageStorageException();
      }
    } catch (e) {
      devtools.log('An unexpected error occurred during remote deletion: $e');
      throw GenericStorageException();
    }

    // 2. Attempt to delete the local file from the cache.
    // This is done in a separate try-catch because failing to delete the
    // cached file should not prevent the overall operation from succeeding.
    await _deleteFromCache(userId: userId);
  }

  /// Helper function to remove an image from the local cache.
  Future<void> _deleteFromCache({required String userId}) async {
    final cacheFile = File('${_cacheDir.path}/$userId/profile_image');
    try {
      if (await cacheFile.exists()) {
        devtools.log('Deleting image from local cache...');
        await cacheFile.delete();
        devtools.log('Local cache deleted successfully.');
      }
    } catch (e) {
      // Log the error, but don't re-throw it.
      // The remote deletion was the most critical part.
      devtools.log('Failed to delete from local cache: $e');
    }
  }

  // Helper function for compression logic
  Future<Uint8List> _compressImage(File file) async {
    devtools.log('Compressing image...');
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 512,
      minHeight: 512,
      quality: 85, // Adjust quality for a good balance
    );

    if (result == null) {
      devtools.log('Image compression failed.');
      throw Exception('Failed to compress image.'); // Custom internal exception
    }
    return result;
  }

  // Helper function for updating the cache
  Future<void> _updateCache(
      {required String userId, required Uint8List imageBytes}) async {
    final cacheFile = File('${_cacheDir.path}/$userId/profile_image');
    try {
      await cacheFile.create(recursive: true);
      await cacheFile.writeAsBytes(imageBytes);
    } catch (e) {
      devtools.log("Failed to update local cache: $e");
      // Don't throw here, failing to cache shouldn't fail the whole upload
    }
  }
}
