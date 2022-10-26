import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Event extends Equatable {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastActivity;
  final IconData iconData;

  final bool isFavorite;
  final bool isComplete;

  const Event({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.iconData,
    required this.lastActivity,
    this.isFavorite = false,
    this.isComplete = false,
  });

  @override
  List<Object> get props => [
        id,
        title,
        lastMessage,
        iconData,
        isFavorite,
        isComplete,
      ];

  Event copyWith({
    String? id,
    String? title,
    String? lastMessage,
    DateTime? lastActivity,
    IconData? iconData,
    bool? isFavorite,
    bool? isComplete,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivity: lastActivity ?? this.lastActivity,
      iconData: iconData ?? this.iconData,
      isFavorite: isFavorite ?? this.isFavorite,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'lastActivity': lastActivity.millisecondsSinceEpoch,
      'iconData': iconData.codePoint,
      'isFavorite': isFavorite,
      'isComplete': isComplete,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      lastMessage: map['lastMessage'] as String,
      lastActivity:
          DateTime.fromMillisecondsSinceEpoch(map['lastActivity'] as int),
      iconData: IconData(map['iconData'] as int, fontFamily: 'MaterialIcons'),
      isFavorite: map['isFavorite'] as bool,
      isComplete: map['isComplete'] as bool,
    );
  }
}
