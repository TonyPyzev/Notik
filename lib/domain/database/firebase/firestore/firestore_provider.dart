import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../data/models/event.dart';
import '../../../../data/models/note.dart';
import '../../../../data/models_collection.dart';
import '../../i_database_provider.dart';

class FirestoreProvider implements IDatabaseProvider {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;
  final ModelsCollection collection;

  FirestoreProvider({
    required this.collection,
  });

  @override
  Future<void> create(Map<String, dynamic> data) async {
    try {
      final doc = _instance.collection(collection.toString()).doc();
      data['id'] = doc.id;
      doc.set(data);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Stream<List> read() {
    try {
      switch (collection) {
        case ModelsCollection.event:
          return _instance.collection(collection.toString()).snapshots().map(
                (snapshot) => snapshot.docs
                    .map((doc) => Event.fromMap(doc.data()))
                    .toList(),
              );

        case ModelsCollection.note:
          return _instance.collection(collection.toString()).snapshots().map(
                (snapshot) => snapshot.docs
                    .map(
                      (doc) => Note.fromMap(doc.data()),
                    )
                    .toList(),
              );
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> update(Map<String, dynamic> data) async {
    try {
      final doc = _instance.collection(collection.toString()).doc(data['id']);
      await doc.update(data);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> delete(Map<String, dynamic> data) async {
    try {
      final doc = _instance.collection(collection.toString()).doc(data['id']);
      await doc.delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
