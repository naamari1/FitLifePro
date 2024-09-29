import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/services/Auth.dart';
import 'package:fitness_planner/models/Event.dart';
import 'package:fitness_planner/services/CalenderService.dart';
import 'package:fitness_planner/services/EventProvider.dart';
import 'package:fitness_planner/services/Utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventEditingPage extends StatefulWidget {
  final EventForCalender? event;

  const EventEditingPage({
    Key? key,
    this.event,
  }) : super(key: key);

  @override
  State<EventEditingPage> createState() => _EventEditingPageState();
}

class _EventEditingPageState extends State<EventEditingPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime fromDate;
  late DateTime toDate;
  late TextEditingController titleController = TextEditingController();
  late TextEditingController descriptionController;
  final User? user = Auth().currentUser;
  CalendarService calendarService = CalendarService();

  @override
  void initState() {
    super.initState();

    fromDate = DateTime.now();
    toDate = DateTime.now().add(Duration(hours: 2));
    descriptionController =
        TextEditingController(text: widget.event?.description);
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        actions: buildEditingActions(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildTitle(),
              SizedBox(height: 12.0),
              buildDescription(), 
              SizedBox(height: 12.0),
              buildDateTimePickers(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDescription() => TextFormField(
        style: TextStyle(fontSize: 18),
        maxLines: 3, 
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Add Description',
        ),
        controller: descriptionController,
      );

  List<Widget> buildEditingActions() => [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
          ),
          onPressed: saveForm,
          icon: Icon(Icons.done),
          label: Text('SAVE'),
        ),
      ];

  Widget buildTitle() => TextFormField(
        style: TextStyle(fontSize: 24),
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Add Title',
        ),
        onFieldSubmitted: (_) => saveForm(),
        validator: (title) =>
            title != null && title.isEmpty ? 'Title cannot be empty' : null,
        controller: titleController,
      );

  Widget buildDateTimePickers() => Column(
        children: [
          buildFrom(),
          SizedBox(height: 12.0),
          buildTo(),
        ],
      );

  Widget buildFrom() => buildHeader(
      header: 'From',
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: buildDropdownField(
              text: Utils.toDate(fromDate),
              onClicked: () => pickFromDate(pickDate: true),
            ),
          ),
          Expanded(
            child: buildDropdownField(
              text: Utils.toTime(fromDate),
              onClicked: () => pickFromDate(pickDate: false),
            ),
          ),
        ],
      ));

  Widget buildTo() => buildHeader(
      header: 'To',
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: buildDropdownField(
              text: Utils.toDate(toDate),
              onClicked: () => pickToDateTime(pickDate: true),
            ),
          ),
          Expanded(
            child: buildDropdownField(
              text: Utils.toTime(toDate),
              onClicked: () => pickToDateTime(pickDate: false),
            ),
          ),
        ],
      ));

  Widget buildDropdownField({
    required String text,
    required VoidCallback onClicked,
  }) =>
      ListTile(
        title: Text(text),
        trailing: Icon(Icons.arrow_drop_down),
        onTap: onClicked,
      );

  Widget buildHeader({
    required String header,
    required Widget child,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          child,
        ],
      );

  Future pickFromDate({required bool pickDate}) async {
    final date = await pickDateTime(fromDate, pickDate: pickDate);

    if (date == null) return;

    if (date.isAfter(toDate)) {
      toDate = DateTime(
        date.year,
        date.month,
        date.day,
        toDate.hour,
        toDate.minute,
      );
    }

    setState(() => fromDate = date);
  }

  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(toDate,
        pickDate: pickDate, firstDate: pickDate ? fromDate : null);

    if (date == null) return;

    if (date.isAfter(toDate)) {
      toDate = DateTime(
        date.year,
        date.month,
        date.day,
        toDate.hour,
        toDate.minute,
      );
    }

    setState(() => toDate = date);
  }

  Future pickDateTime(
    DateTime initialDate, {
    required bool pickDate,
    DateTime? firstDate,
  }) async {
    if (pickDate) {
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2015, 8),
        lastDate: DateTime(2101),
      );

      if (date == null) return null;

      final time = Duration(
        hours: initialDate.hour,
        minutes: initialDate.minute,
      );

      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (timeOfDay == null) return null;

      final date = DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
      );

      final time = Duration(
        hours: timeOfDay.hour,
        minutes: timeOfDay.minute,
      );

      return date.add(time);
    }
  }

  Future saveForm() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final eventForCalender = EventForCalender(
        title: titleController.text,
        description: descriptionController
            .text, 
        from: fromDate,
        to: toDate,
        isAllDay: false,
      );

      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.addEvent(eventForCalender);

      await calendarService.addEvent(eventForCalender, user!.uid);
      Provider.of<EventProvider>(context, listen: false).fillEvents(user!.uid);

      Navigator.of(context).pop();
    }
  }

  Future deleteEvent() async {
    final provider = Provider.of<EventProvider>(context, listen: false);
    provider.deleteEvent(widget.event!);

    Navigator.of(context).pop();
  }
}
