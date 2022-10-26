part of 'chat_cubit.dart';

class ChatState extends Equatable {
  final ChatStatus status;
  final Event event;
  final List<Event> events;
  final List<Note> notes;
  final List<Note> searchingNotes;
  final Set<String> selectedNotesIds;

  final String editingNoteId;
  final String selectedEventId;

  final XFile? image;

  const ChatState({
    this.status = ChatStatus.initial,
    required this.event,
    this.events = const [],
    this.notes = const [],
    this.searchingNotes = const [],
    this.selectedNotesIds = const {},
    this.editingNoteId = '',
    this.selectedEventId = '',
    this.image,
  });

  @override
  List<Object?> get props => [
        status,
        event,
        events,
        notes,
        searchingNotes,
        selectedNotesIds,
        editingNoteId,
        selectedEventId,
        image,
      ];

  ChatState copyWith({
    ChatStatus? status,
    Event? event,
    List<Event>? events,
    List<Note>? notes,
    List<Note>? searchingNotes,
    Set<String>? selectedNotesIds,
    String? editingNoteId,
    String? selectedEventId,
    XFile? image,
  }) {
    return ChatState(
      status: status ?? this.status,
      event: event ?? this.event,
      events: events ?? this.events,
      notes: notes ?? this.notes,
      searchingNotes: searchingNotes ?? this.searchingNotes,
      selectedNotesIds: selectedNotesIds ?? this.selectedNotesIds,
      editingNoteId: editingNoteId ?? this.editingNoteId,
      selectedEventId: selectedEventId ?? this.selectedEventId,
      image: image ?? this.image,
    );
  }
}

enum ChatStatus {
  initial,
  searching,
  editingNote,
  sendTo,
  forwardTo,
}
