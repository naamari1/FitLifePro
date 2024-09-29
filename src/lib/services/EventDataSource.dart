import 'dart:ui';
import 'package:fitness_planner/models/Event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<EventForCalender> appointments) {
    this.appointments = appointments;
  }

  EventForCalender getEvent(int index) => appointments![index] as EventForCalender;

  

  @override
  DateTime getStartTime(int index) {
    return getEvent(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return getEvent(index).to;
  }

  @override
  String getSubject(int index) {
    return getEvent(index).title;
  }

  @override
  Color getColor(int index) {
    return getEvent(index).backgroundColor;
  }

  @override
  bool isAllDay(int index) {
    return getEvent(index).isAllDay;
  }

}