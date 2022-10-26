import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/event.dart';
import '../../../../data/models/note.dart';
import '../../../../domain/repository/event_repository.dart';
import '../../../../domain/repository/note_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  late NoteRepository _noteRepository;

  ChatCubit() : super(ChatState(event: _defaultEvent));

  void init() {
    _noteRepository = NoteRepository(
      state.event.id,
    );
    _fetchNotesToState();
  }

  void clearState() {
    emit(state.copyWith(
      status: ChatStatus.initial,
      event: _defaultEvent,
      events: [],
      notes: [],
      searchingNotes: [],
      selectedNotesIds: {},
      editingNoteId: '',
      selectedEventId: '',
    ));
  }

  void setEvent(Event event) {
    emit(state.copyWith(event: event));
  }

  void setEvents(List<Event> events) {
    emit(state.copyWith(events: events));
  }

  void createNote(Note note) {
    final noteWithEventId = note.copyWith(
      eventId: state.event.id,
      imageName: state.image != null ? state.image!.name : '',
    );

    _unloadImage();
    _noteRepository.createNote(noteWithEventId);
    _updateEvent(noteWithEventId);
  }

  Future<void> deleteNote(Note note) async {
    await _noteRepository.deleteNote(note);
    await _updateEvent(state.notes.first);
  }

  void searchNotes(String text) {
    if (text.isEmpty) {
      emit(state.copyWith(searchingNotes: state.notes));
    }
    final searchingNotes = state.notes
        .where((element) =>
            element.text.toLowerCase().contains(text.toLowerCase()))
        .toList();

    emit(state.copyWith(searchingNotes: searchingNotes));
  }

  void setEditingNoteId(String noteId) {
    emit(state.copyWith(editingNoteId: noteId));
  }

  void editNote(String newText) {
    final note = state.notes
        .firstWhere((element) => element.id == state.editingNoteId)
        .copyWith(text: newText);

    _noteRepository.updateNote(note);
  }

  void selectEvent(String eventId) {
    if (state.selectedEventId == eventId) {
      emit(state.copyWith(selectedEventId: ''));
    } else {
      emit(state.copyWith(selectedEventId: eventId));
    }
  }

  void sendToEvent(Note note) {
    final noteWithEventId = note.copyWith(
      eventId: state.selectedEventId,
    );

    _noteRepository.createNoteForAnotherEvent(
      state.selectedEventId,
      noteWithEventId,
    );
    _updateEvent(noteWithEventId);
  }

  void forwardToEvent() {
    final selectedNotes = state.notes
        .where((note) => state.selectedNotesIds.contains(note.id))
        .toList();

    for (var note in selectedNotes) {
      final noteWithEventId = note.copyWith(
        eventId: state.selectedEventId,
        date: DateTime.now(),
      );
      _noteRepository.createNoteForAnotherEvent(
        state.selectedEventId,
        noteWithEventId,
      );
      _noteRepository.deleteNote(noteWithEventId);

      _updateEvent(noteWithEventId);
    }
  }

  void selectNote(Note note) {
    final selectedNotesIds = state.selectedNotesIds.toSet();

    if (selectedNotesIds.contains(note.id)) {
      selectedNotesIds.remove(note.id);
      if (selectedNotesIds.isEmpty) {
        emit(state.copyWith(
          status: ChatStatus.initial,
        ));
      }
    } else {
      selectedNotesIds.add(note.id);
    }

    emit(state.copyWith(
      selectedNotesIds: selectedNotesIds,
    ));
  }

  void setImage(XFile image) {
    emit(state.copyWith(
      image: image,
    ));
  }

  void setStatus(ChatStatus status) {
    switch (status) {
      case ChatStatus.initial:
        break;
      case ChatStatus.searching:
        emit(state.copyWith(
          status: ChatStatus.searching,
        ));
        break;
      case ChatStatus.editingNote:
        emit(state.copyWith(
          status: ChatStatus.editingNote,
        ));
        break;
      case ChatStatus.sendTo:
        emit(state.copyWith(
          status: ChatStatus.sendTo,
        ));
        break;
      case ChatStatus.forwardTo:
        emit(state.copyWith(
          status: ChatStatus.forwardTo,
        ));
        break;
    }
  }

  void resetStatus() {
    switch (state.status) {
      case ChatStatus.initial:
        break;
      case ChatStatus.searching:
        emit(state.copyWith(
          status: ChatStatus.initial,
          searchingNotes: [],
        ));
        break;
      case ChatStatus.editingNote:
        emit(state.copyWith(
          status: ChatStatus.initial,
          editingNoteId: '',
        ));
        break;
      case ChatStatus.sendTo:
        emit(state.copyWith(
          status: ChatStatus.initial,
          selectedEventId: '',
        ));
        break;
      case ChatStatus.forwardTo:
        emit(state.copyWith(
          status: ChatStatus.initial,
          selectedEventId: '',
          selectedNotesIds: {},
        ));
        break;
    }
  }

  Future<String> uploadImage(String imageName) async {
    late final _storage = FirebaseStorage.instance;
    return await _storage.ref('images/$imageName').getDownloadURL();
  }

  void _fetchNotesToState() {
    _noteRepository.fetchNotes().listen((notes) {
      notes.sort(((a, b) => b.date.compareTo(a.date)));
      emit(state.copyWith(notes: notes));
    });
  }

  Future<void> _updateEvent(Note note) async {
    final eventRep = EventRepository();
    final event = state.events
        .firstWhere((element) => element.id == note.eventId)
        .copyWith(
          lastActivity: note.date,
          lastMessage:
              note.text.isEmpty ? 'Image' : _lastMessageTrimmer(note.text),
        );

    await eventRep.updateEvent(event);
  }

  String _lastMessageTrimmer(String text) {
    if (text.length <= 23) {
      return text;
    } else {
      return '${text.substring(0, 20)}...';
    }
  }

  Future<void> _unloadImage() async {
    final image = state.image;

    print('_unloadImage');

    if (image != null) {
      late final _storage = FirebaseStorage.instance;
      final imageFile = File(image.path);

      try {
        await _storage.ref('images/${image.name}').putFile(imageFile);
        print('image loaded');
      } catch (e) {
        print(e);
      }

      emit(ChatState(
        status: ChatStatus.initial,
        event: state.event,
        events: state.events,
        notes: state.notes,
        searchingNotes: state.searchingNotes,
        selectedNotesIds: state.selectedNotesIds,
        editingNoteId: state.editingNoteId,
        selectedEventId: state.selectedEventId,
        image: null,
      ));
    }
  }
}

final _defaultEvent = Event(
  id: '',
  title: 'Loading...',
  lastMessage: 'No messages',
  iconData: Icons.abc,
  lastActivity: DateTime.now(),
);
