import 'package:fitness_planner/pages/EventViewing_page.dart';
import 'package:fitness_planner/services/EventDataSource.dart';
import 'package:fitness_planner/services/EventProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TasksWidget extends StatefulWidget {
  const TasksWidget({super.key});

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  final CalendarController _controller = CalendarController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final selectedEvents = provider.eventsOfSelectedDate;

    if (selectedEvents.isEmpty) {
      return Center(
        child: Text(
          'No events',
          style: TextStyle(fontSize: 24),
        ),
      );
    }

    _controller.displayDate = provider.selectedDate;

    return SfCalendarTheme(
      data: SfCalendarThemeData(
        timeTextStyle: TextStyle(fontSize: 15),
      ),
      child: SfCalendar(
        view: CalendarView.timelineDay,
        dataSource: EventDataSource(provider.events),
        controller: _controller,
        onTap: (details) {
          if (details.appointments == null) return;
          final event = details.appointments!.first;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventViewingPage(
                event: event,
              ),
            ),
          );
        },
      ),
    );
  }
}
