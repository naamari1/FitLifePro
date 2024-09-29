import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_planner/models/Event.dart';

class CalendarService {
  Future<void> addEvent(EventForCalender event, String userId) async {
    try {
      CollectionReference eventsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events');

      var existingEvents = (await eventsCollection.get()).docs;
      var currentEvents = existingEvents.isNotEmpty
          ? existingEvents[0]['events'] as List<dynamic>
          : [];

      currentEvents.add({
        'title': event.title,
        'description': event.description,
        'from': event.from,
        'to': event.to,
        'isAllDay': event.isAllDay,
        'backgroundColor': event.backgroundColor.value,
      });

      await eventsCollection
          .doc(existingEvents.isNotEmpty ? existingEvents[0].id : null)
          .update({
        'events': currentEvents,
      });
    } catch (e) {
      print("Error adding event to array: $e");
    }
  }

  Future<List<EventForCalender>> getAllEvents(String userId) async {
    try {
      CollectionReference eventsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events');

      var existingEvents = (await eventsCollection.get()).docs;

      if (existingEvents.isNotEmpty) {
        var eventsArray = existingEvents[0]['events'] as List<dynamic>;

        List<EventForCalender> events = eventsArray.map((eventData) {
          return EventForCalender(
            title: eventData['title'],
            description: eventData['description'],
            from: (eventData['from'] as Timestamp).toDate(),
            to: (eventData['to'] as Timestamp).toDate(),
            isAllDay: eventData['isAllDay'],
            backgroundColor: Color(eventData['backgroundColor']),
          );
        }).toList();

        return events;
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting events: $e");
      return [];
    }
  }

 Future<void> deleteEvent(String userId, DateTime from, DateTime to) async {
    try {
      CollectionReference eventsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events');

      var existingEvents = (await eventsCollection.get()).docs;

      if (existingEvents.isNotEmpty) {
        var eventsArray = existingEvents[0]['events'] as List<dynamic>;

        eventsArray.removeWhere((event) =>
            event['from'] == Timestamp.fromDate(from) &&
            event['to'] == Timestamp.fromDate(to));

        await eventsCollection
            .doc(existingEvents.isNotEmpty ? existingEvents[0].id : null)
            .update({
          'events': eventsArray,
        });
      }
    } catch (e) {
      print("Error deleting event: $e");
    }
  }
  
}

