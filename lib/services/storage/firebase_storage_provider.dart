import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:vecinapp/services/storage/storage_exceptions.dart';
import 'package:vecinapp/services/storage/storage_provider.dart';
import 'dart:developer' as devtools show log;

class FirebaseStorageProvider implements StorageProvider {
  // Future<String> getProfileImageUrl({required String userId}) async {
  //   try {
  //     final listResult = await FirebaseStorage.instance
  //         .ref('user/$userId')
  //         .list()
  //         .then((result) => result.items);
  //     if (listResult.isEmpty) {
  //       return '';
  //     }
  //     if (listResult.length > 1) {
  //       throw GenericStorageException();
  //     }
  //     return listResult.first.getDownloadURL();
  //   } on FirebaseException catch (_) {
  //     throw GenericStorageException();
  //   }
  // }
  @override
  Future<String> uploadProfileImage({
    required File image,
    required String userId,
  }) async {
    if (image.path.isEmpty) {
      throw GenericStorageException();
    }

    final randomlink = const Uuid().v4();
    late final String url;
    try {
      url = await FirebaseStorage.instance
          .ref('user/$userId')
          .child(randomlink)
          .putFile(image)
          .then((value) => value.ref.getDownloadURL())
          .onError((error, stackTrace) => throw GenericStorageException());
    } on Exception catch (e) {
      devtools.log(e.toString() + e.hashCode.toString());
      throw CouldNotUploadImageException();
    }
    return url;
  }
}
