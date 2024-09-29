import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/services/Auth.dart';
import 'package:fitness_planner/models/Event.dart';
import 'package:fitness_planner/services/CalenderService.dart';
import 'package:fitness_planner/services/EventProvider.dart';
import 'package:fitness_planner/services/Utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventViewingPage extends StatelessWidget {
  final EventForCalender event;

  const EventViewingPage({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        actions: buildViewingActions(context, event),
      ),
      body: ListView(
        padding: EdgeInsets.all(32),
        children: <Widget>[
          buildDateTime(event),
          SizedBox(height: 32),
          Text(
            event.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            event.description,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget buildDateTime(EventForCalender event) {
    return Column(
      children: [
        buildDate(event.isAllDay ? 'All-day' : 'From', event.from),
        if (!event.isAllDay) buildDate('To', event.to),
      ],
    );
  }

  Widget buildDate(String title, DateTime date) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            Utils.toDate(date),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ],
      );

  List<Widget> buildViewingActions(
          BuildContext context, EventForCalender event) =>
      [
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            CalendarService calendarService = CalendarService();
            final User? user = Auth().currentUser;

            final provider = Provider.of<EventProvider>(context, listen: false);
            provider.deleteEvent(event);
            calendarService.deleteEvent(user!.uid, event.from, event.to);
            Provider.of<EventProvider>(context, listen: false).fillEvents(user.uid);

            Navigator.of(context).pop();
          },
        )
      ];
}
