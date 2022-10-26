import 'dart:async';

import '../../data/models/note.dart';
import '../../data/models_collection.dart';
import '../database/firebase/realtime/realtime_provider.dart';
import '../database/i_database_provider.dart';

class NoteRepository with NoteAccessExtension {
  late final IDatabaseProvider _provider;

  NoteRepository(String eventId) {
    _provider = RealtimeProvider(
      collection: ModelsCollection.note,
      eventId: eventId,
    );
  }

  Stream<List<Note>> fetchNotes() {
    final controller = StreamController<List<Note>>();

    _provider.read().listen(
      (event) {
        final notes = <Note>[];
        final data = (event.snapshot.value ?? {}) as Map;

        data.forEach(
          (key, value) {
            notes.add(Note.fromMap({'id': key, ...value}));
          },
        );

        controller.add(notes);
      },
    );

    return controller.stream;
  }

  Future<void> createNote(Note note) async {
    await _provider.create(note.toMap());
  }

  Future<void> updateNote(Note note) async {
    await _provider.update(note.toMap());
  }

  Future<void> deleteNote(Note note) async {
    await _provider.delete(note.toMap());
  }
}

mixin NoteAccessExtension {
  Future<void> createNoteForAnotherEvent(String eventId, Note note) async {
    late final provider = RealtimeProvider(
      collection: ModelsCollection.note,
      eventId: eventId,
    );

    await provider.create(note.toMap());
  }
}
