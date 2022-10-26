import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String eventId;
  final String text;
  final String imageName;
  final DateTime date;

  const Note({
    required this.id,
    required this.eventId,
    required this.text,
    required this.date,
    this.imageName = '',
  });

  @override
  List<Object> get props => [
        id,
        eventId,
        text,
        date,
        imageName,
      ];

  Note copyWith({
    String? id,
    String? eventId,
    String? text,
    DateTime? date,
    String? imageName,
  }) {
    return Note(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      text: text ?? this.text,
      date: date ?? this.date,
      imageName: imageName ?? this.imageName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'eventId': eventId,
      'text': text,
      'date': date.millisecondsSinceEpoch,
      'imageName': imageName,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      eventId: map['eventId'] as String,
      text: map['text'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      imageName: map['imageName'] as String,
    );
  }
}
