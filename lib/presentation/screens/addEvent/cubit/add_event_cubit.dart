import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/event.dart';
import '../../../../domain/repository/event_repository.dart';

part 'add_event_state.dart';

class AddEventCubit extends Cubit<AddEventState> {
  final EventRepository _eventRepository;
  AddEventCubit(this._eventRepository) : super(const AddEventState());

  Future<void> fabHandler(Event event) async {
    switch (state.status) {
      case AddEventStatus.create:
        await _addEvent(event);
        break;
      case AddEventStatus.update:
        await _updateEvent(event);
        break;
    }
  }

  void selectIcon(IconData icon) {
    icon == state.selectedIcon
        ? emit(state.copyWith(selectedIcon: Icons.abc))
        : emit(state.copyWith(selectedIcon: icon));
  }

  void clearState() {
    emit(state.copyWith(selectedIcon: Icons.abc));
  }

  void setUpdatingStatus() {
    emit(state.copyWith(status: AddEventStatus.update));
  }

  void setCreatingStatus() {
    emit(state.copyWith(status: AddEventStatus.create));
  }

  Future<void> _addEvent(Event event) async {
    await _eventRepository.createEvent(event);
  }

  Future<void> _updateEvent(Event event) async {
    await _eventRepository.updateEvent(event);
  }
}
