import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/pages/EventEditing_page.dart';
import 'package:fitness_planner/services/widgets/Tasks_widget.dart';
import 'package:fitness_planner/services/EventDataSource.dart';
import 'package:fitness_planner/services/EventProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalenderWidget extends StatelessWidget {
  const CalenderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    Provider.of<EventProvider>(context, listen: false).fillEvents(user!.uid);
    final events = Provider.of<EventProvider>(context).events;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Calendar Page'),
        centerTitle: true,
      ),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: EventDataSource(events),
        initialSelectedDate: DateTime.now(),
        onLongPress: (details) {
          final provider = Provider.of<EventProvider>(context, listen: false);
          provider.setDate(details.date!);
          showModalBottomSheet(
              context: context, builder: (context) => TasksWidget());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventEditingPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
