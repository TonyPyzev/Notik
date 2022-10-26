import 'package:firebase_database/firebase_database.dart';

import '../../../../data/models_collection.dart';
import '../../i_database_provider.dart';

class RealtimeProvider implements IDatabaseProvider {
  final FirebaseDatabase _instance = FirebaseDatabase.instance;
  final ModelsCollection collection;

  late final DatabaseReference _ref;

  RealtimeProvider({
    required this.collection,
    String? eventId,
  }) {
    try {
      switch (collection) {
        case ModelsCollection.event:
          _ref = _instance.ref().child(collection.toString());
          break;
        case ModelsCollection.note:
          if (eventId != null) {
            _ref = _instance.ref().child('${collection.toString()}/$eventId');
          } else {
            throw Exception('Add event id');
          }

          break;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> create(Map<String, dynamic> data) async {
    try {
      final newRef = _ref.push();
      final refKey = newRef.key;
      data['id'] = refKey;
      await newRef.set(data);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Stream read() {
    try {
      return _ref.onValue;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> update(Map<String, dynamic> data) async {
    try {
      await _ref.child(data['id']).update(data);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> delete(Map<String, dynamic> data) async {
    try {
      await _ref.child(data['id']).remove();
    } catch (e) {
      throw Exception(e);
    }
  }
}
