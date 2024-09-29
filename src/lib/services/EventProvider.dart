import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/models/Event.dart';
import 'package:fitness_planner/services/Auth.dart';
import 'package:fitness_planner/services/CalenderService.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class EventProvider with ChangeNotifier {
  List<EventForCalender> _events = [];
  DateTime _selectedDate = DateTime.now();
  CalendarService calendarService = CalendarService();
  List<EventForCalender> get events => _events;
  final User? user = Auth().currentUser;

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<EventForCalender> get eventsOfSelectedDate {
    return _events
        .where((event) =>
            event.from.year == _selectedDate.year &&
            event.from.month == _selectedDate.month &&
            event.from.day == _selectedDate.day)
        .toList();
  }

  void setEvents(List<EventForCalender> events) {
    _events.clear();
    _events.addAll(events);
    notifyListeners();
  }

  void fillEvents(String userId) async {
    var events = await calendarService.getAllEvents(userId);
    _events = events;
  }

 
  void addEvent(EventForCalender event) {
    _events.add(event);
    notifyListeners();
  }

  void deleteEvent(EventForCalender event) {
    _events.remove(event);
    notifyListeners();
  }
}
