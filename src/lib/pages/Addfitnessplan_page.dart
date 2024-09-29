import 'package:fitness_planner/services/InputValidator.dart';
import 'package:fitness_planner/services/fitnessplan.dart';
import 'package:fitness_planner/services/widgets/widget_tree.dart';
import 'package:flutter/material.dart';

class AddFitnessPlan extends StatefulWidget {
  final String userId;

  const AddFitnessPlan({Key? key, required this.userId}) : super(key: key);

  @override
  _AddFitnessPlanState createState() => _AddFitnessPlanState();
}

class _AddFitnessPlanState extends State<AddFitnessPlan> {
  final TextEditingController _controllerFitnessPlanName =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Fitness Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controllerFitnessPlanName,
              decoration: InputDecoration(
                labelText: 'Fitness Plan Name',
                errorText: InputValidator.validateFitnessPlanName(
                    _controllerFitnessPlanName.text),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                try {
                  String fitnessPlanName = _controllerFitnessPlanName.text;
                  await FitnessPlanService()
                      .addFitnessPlan(widget.userId, fitnessPlanName);

                 
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WidgetTree(),
                    ),
                  ).then((result) {
                    if (result != null) {
                    }
                  });
                } catch (e) {
                  print("Error: $e");
                }
              },
              child: Text('Save Fitness Plan'),
            )
          ],
        ),
      ),
    );
  }
}
