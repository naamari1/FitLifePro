import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/models/BodyProgression.dart';
import 'package:fitness_planner/services/Auth.dart';
import 'package:fitness_planner/services/BodyProgrssionService.dart';
import 'package:fitness_planner/services/InputValidator.dart';
import 'package:fitness_planner/services/widgets/CommonWidgets.dart';
import 'package:flutter/material.dart';

class BodyProgressionPage extends StatefulWidget {
  const BodyProgressionPage({Key? key}) : super(key: key);

  @override
  State<BodyProgressionPage> createState() => _BodyProgressionPageState();
}

class _BodyProgressionPageState extends State<BodyProgressionPage> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController muscleController = TextEditingController();
  final TextEditingController fatController = TextEditingController();

  BodyProgressionService bodyProgressionService = BodyProgressionService();
  late List<BodyProgression> bodyProgressions = [];
  final User? user = Auth().currentUser;

  bool showAddDataFields = false;
  String buttonText = 'Add body progression';

  @override
  void initState() {
    super.initState();
    bodyProgressionService = BodyProgressionService();
    loadBodyProgressions();
  }

  Future<void> loadBodyProgressions() async {
    bodyProgressions = await bodyProgressionService.getAllEvents(user!.uid);
    setState(() {});
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Validation Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Body Progression'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (showAddDataFields == true) {
                    buttonText = 'Add Body Progression';
                    showAddDataFields = false;
                  } else {
                    buttonText = 'X';
                    showAddDataFields = true;
                  }
                });
              },
              child: Text(buttonText),
            ),
            SizedBox(height: 16),
            if (showAddDataFields)
              Column(
                children: [
                  CommonWidgets.myCustomTextFieldProgression(
                    controller: weightController,
                    labelText: 'Weight',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter weight';
                      }
                      return null;
                    },
                  ),
                  CommonWidgets.myCustomTextFieldProgression(
                    controller: muscleController,
                    labelText: 'Muscle in percentage',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter muscle percentage';
                      }
                      if (InputValidator.containsSpecialCharacters(value)) {
                        return 'Muscle percentage should not contain special characters';
                      }
                      return null;
                    },
                  ),
                  CommonWidgets.myCustomTextFieldProgression(
                    controller: fatController,
                    labelText: 'Fat in percentage',
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter fat percentage';
                      }
                      if (InputValidator.containsSpecialCharacters(value)) {
                        return 'Fat percentage should not contain special characters';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (InputValidator.isEmpty(weightController.text) ||
                          InputValidator.isEmpty(muscleController.text) ||
                          InputValidator.isEmpty(fatController.text)) {
                        await _showErrorDialog('All fields must be filled in');
                        return;
                      }

                      if (InputValidator.containsSpecialCharacters(
                              muscleController.text) ||
                          InputValidator.containsSpecialCharacters(
                              fatController.text)) {
                        await _showErrorDialog(
                            'Muscle and Fat percentages should not contain special characters');
                        return;
                      }

                      await bodyProgressionService.addBodyProgression(
                        user!.uid,
                        BodyProgression(
                          weight: double.parse(weightController.text),
                          muscle: double.parse(muscleController.text),
                          fat: double.parse(fatController.text),
                          date: DateTime.now(),
                        ),
                      );
                      loadBodyProgressions();
                      setState(() {
                        showAddDataFields = false;
                        buttonText = 'Add Body Progression';
                      });
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  height: 500,
                  child: CommonWidgets.bodyProgressionChartSyncFusion(
                    bodyProgression: bodyProgressions,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
