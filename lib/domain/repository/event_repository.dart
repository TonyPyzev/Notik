import 'dart:async';

import '../../data/models/event.dart';
import '../../data/models_collection.dart';
import '../database/firebase/realtime/realtime_provider.dart';
import '../database/i_database_provider.dart';

class EventRepository {
  late final IDatabaseProvider _provider;

  EventRepository() {
    _provider = RealtimeProvider(
      collection: ModelsCollection.event,
    );
  }

  Stream<List<Event>> fetchEvents() {
    final controller = StreamController<List<Event>>();

    _provider.read().listen(
      (event) {
        final events = <Event>[];
        final data = (event.snapshot.value ?? {}) as Map;

        data.forEach(
          (key, value) {
            events.add(Event.fromMap({'id': key, ...value}));
          },
        );

        controller.add(events);
      },
    );

    return controller.stream;
  }

  Future<void> createEvent(Event event) async {
    await _provider.create(event.toMap());
  }

  Future<void> updateEvent(Event event) async {
    await _provider.update(event.toMap());
  }

  Future<void> deleteEvent(Event event) async {
    await _provider.delete(event.toMap());
  }
}
