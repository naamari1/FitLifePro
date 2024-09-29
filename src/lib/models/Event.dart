import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventForCalender {
  final String title;
  final String description;
  final DateTime from;
  final DateTime to;
  final bool isAllDay;
  final Color backgroundColor;

  const EventForCalender({
    required this.title,
    required this.description,
    required this.from,
    required this.to,
    this.isAllDay = false,
    this.backgroundColor = Colors.lightGreen,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'from': from,
      'to': to,
      'isAllDay': isAllDay,
      'backgroundColor': backgroundColor.value,
    };
  }

  factory EventForCalender.fromFirestore(Map<String, dynamic> map) {
    return EventForCalender(
      title: map['title'],
      description: map['description'],
      from: (map['from'] as Timestamp).toDate(),
      to: (map['to'] as Timestamp).toDate(),
      isAllDay: map['isAllDay'],
      backgroundColor: Color(map['backgroundColor']),
    );
  }
}
