import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_doc.dart';
import 'package:vecinapp/services/cloud/cloud_sorage_constants.dart';
import 'package:vecinapp/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final docs = FirebaseFirestore.instance.collection('docs');

  Future<void> deleteDoc({
    required String documentId,
  }) async {
    try {
      await docs.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteDocException();
    }
  }

  Future<void> updateDoc({
    required String documentId,
    required String title,
    required String text,
  }) async {
    try {
      await docs.doc(documentId).update({
        titleFieldName: title,
        textFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateDocException();
    }
  }

  Stream<Iterable<CloudDoc>> allDocs({required String ownerUserId}) {
    final allDocs = docs
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudDoc.fromSnapshot(doc)));
    return allDocs;
  }

  Future<CloudDoc> createNewDoc({
    required String ownerUserId,
    required String title,
    required String text,
  }) async {
    final document = await docs.add({
      ownerUserIdFieldName: ownerUserId,
      titleFieldName: title,
      textFieldName: text,
    });
    final fetchedDoc = await document.get();

    return CloudDoc(
      documentId: fetchedDoc.id,
      ownerUserId: ownerUserId,
      title: title,
      text: text,
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() {
    return _shared;
  }
}
