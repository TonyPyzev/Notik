import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/event.dart';
import '../../../../domain/repository/event_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final EventRepository _eventRepository;

  HomeCubit(
    this._eventRepository,
  ) : super(const HomeState()) {
    _fetchEventsToState();
  }

  Future<void> addToFavorite(Event event) async {
    await _eventRepository.updateEvent(event.copyWith(isFavorite: true));
  }

  Future<void> removeFromFavorite(Event event) async {
    await _eventRepository.updateEvent(event.copyWith(isFavorite: false));
  }

  Future<void> deleteEvent(Event event) async {
    await _eventRepository.deleteEvent(event);
  }

  void selectPage(int index) {
    emit(state.copyWith(selectedPage: index));
  }

  void _fetchEventsToState() {
    _eventRepository.fetchEvents().listen(_sortEvents);
  }

  void _sortEvents(List<Event> allEvents) {
    final favoriveEvents = <Event>[];
    final events = <Event>[];

    for (var element in allEvents) {
      if (element.isFavorite) {
        favoriveEvents.add(element);
      } else {
        events.add(element);
      }
    }

    favoriveEvents.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    events.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

    emit(state.copyWith(
      favoriteEvents: favoriveEvents,
      events: events,
    ));
  }
}
