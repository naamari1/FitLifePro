import 'package:fitness_planner/models/exercise.dart';
import 'package:fitness_planner/models/exerciserecord.dart';
import 'package:fitness_planner/services/InputValidator.dart';
import 'package:fitness_planner/services/fitnessplan.dart';
import 'package:fitness_planner/services/widgets/CommonWidgets.dart';
import 'package:flutter/material.dart';

class NewRecordPage extends StatefulWidget {
  final String userId;
  final String fitnessPlanName;
  final Exercise exercise;

  NewRecordPage(
      {required this.userId,
      required this.fitnessPlanName,
      required this.exercise});

  @override
  State<NewRecordPage> createState() => _NewRecordPageState();
}

class _NewRecordPageState extends State<NewRecordPage> {
  late TextEditingController repsController = TextEditingController();
  late TextEditingController setsController = TextEditingController();
  late TextEditingController weightController = TextEditingController();

  Widget _saveButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          String? repsValidation = InputValidator.validateNumericalValue(
              repsController.text, 'Reps');
          String? setsValidation = InputValidator.validateNumericalValue(
              setsController.text, 'Sets');
          String? weightValidation = InputValidator.validateNumericalValue(
              weightController.text, 'Weight');

          if (repsValidation == null &&
              setsValidation == null &&
              (weightValidation == null || weightValidation == '')) {
            int reps = int.parse(repsController.text);
            int sets = int.parse(setsController.text);
            double weight = 0; 

            if (weightController.text.isNotEmpty) {
              try {
                weight = double.parse(weightController.text);
              } catch (e) {
                print('Error parsing weight: $e');
              }
            }

            await FitnessPlanService().addExerciseRecord(
              widget.userId,
              widget.fitnessPlanName,
              widget.exercise,
              ExerciseRecord(
                reps: reps,
                sets: sets,
                weight: weight,
                date: DateTime.now(),
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Record saved successfully!'),
              ),
            );

            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Validation failed. $repsValidation $setsValidation $weightValidation'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          print('Error during parsing: $e');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Text('Save'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Record')),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CommonWidgets.entryFieldRecords('Reps', repsController),
            CommonWidgets.entryFieldRecords('Sets', setsController),
            CommonWidgets.entryFieldRecords('Weight', weightController),
            _saveButton(),
          ],
        ),
      ),
    );
  }
}
