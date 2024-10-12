import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecinapp/services/cloud/cloud_provider.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';
import 'package:vecinapp/services/cloud/cloud_constants.dart';
import 'package:vecinapp/services/cloud/cloud_exceptions.dart';

class FirebaseCloudProvider implements CloudProvider {
  Future<void> initialize() async {}

  final rulebooks = FirebaseFirestore.instance.collection('docs');

  @override
  Future<void> deleteRulebook({
    required String rulebookId,
  }) async {
    try {
      await rulebooks.doc(rulebookId).delete();
    } catch (e) {
      throw CouldNotDeleteRulebookException();
    }
  }

  @override
  Future<void> updateRulebook({
    required String rulebookId,
    required String title,
    required String text,
  }) async {
    if (title.isEmpty || text.isEmpty) {
      throw ChannelErrorRulebookException();
    }
    try {
      await rulebooks.doc(rulebookId).update({
        titleFieldName: title,
        textFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateRulebooksException();
    }
  }

  @override
  Stream<Iterable<Rulebook>> allRulebooks({required String ownerUserId}) {
    final allRulebooks = rulebooks
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => Rulebook.fromSnapshot(doc)));
    return allRulebooks;
  }

  @override
  Future<Rulebook> createNewRulebook({
    required String ownerUserId,
    required String title,
    required String text,
  }) async {
    if (title.isEmpty || text.isEmpty) {
      throw ChannelErrorRulebookException();
    }
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
