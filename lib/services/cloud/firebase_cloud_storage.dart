import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';
import 'package:vecinapp/services/cloud/cloud_sorage_constants.dart';
import 'package:vecinapp/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() {
    return _shared;
  }

  final rulebooks = FirebaseFirestore.instance.collection('docs');

  Future<void> deleteRulebook({
    required String rulebookId,
  }) async {
    try {
      await rulebooks.doc(rulebookId).delete();
    } catch (e) {
      throw CouldNotDeleteDocException();
    }
  }

  Future<void> updateRulebook({
    required String rulebookId,
    required String title,
    required String text,
  }) async {
    try {
      await rulebooks.doc(rulebookId).update({
        titleFieldName: title,
        textFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateDocException();
    }
  }

  Stream<Iterable<Rulebook>> allRulebooks({required String ownerUserId}) {
    final allRulebooks = rulebooks
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => Rulebook.fromSnapshot(doc)));
    return allRulebooks;
  }

  Future<Rulebook> createNewRulebook({
    required String ownerUserId,
    required String title,
    required String text,
  }) async {
    final rulebook = await rulebooks.add({
      ownerUserIdFieldName: ownerUserId,
      titleFieldName: title,
      textFieldName: text,
    });
    final fetchedRulebook = await rulebook.get();

    return Rulebook(
      id: fetchedRulebook.id,
      ownerUserId: ownerUserId,
      title: title,
      text: text,
    );
  }
}
