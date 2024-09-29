import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/services/Auth.dart';
import 'package:fitness_planner/models/exercise.dart';
import 'package:fitness_planner/services/fitnessplan.dart';
import 'package:flutter/material.dart';

class ExerciseSelectionPage extends StatefulWidget {
  final List<Exercise> selectedExercises;
  final String fitnessPlanName;

  const ExerciseSelectionPage(
      {Key? key,
      required this.selectedExercises,
      required this.fitnessPlanName})
      : super(key: key);

  @override
  State<ExerciseSelectionPage> createState() =>
      _ExerciseSelectionPageState(selectedExercises);
}

class _ExerciseSelectionPageState extends State<ExerciseSelectionPage> {
  final User? user = Auth().currentUser;
  List<Exercise> selectedExercises = []; 
  late List<Exercise> allExercises = []; 

  _ExerciseSelectionPageState(this.selectedExercises);

  Future<List<Exercise>> getAllExercises() async {
    try {
      List<String> exerciseIds =
          await FitnessPlanService().getExerciseIdsForUser(user!.uid);

      List<Exercise> allExercises = [];

      for (String exerciseId in exerciseIds) {
        List<Map<String, dynamic>>? exercisesData =
            await FitnessPlanService().getExerciseById(exerciseId);

        if (exercisesData != null && exercisesData.isNotEmpty) {
          for (Map<String, dynamic> exerciseData in exercisesData) {
            Exercise exercise = Exercise.fromFirestore(exerciseData);

            allExercises.add(exercise);
          }
        }
      }

      return allExercises;
    } catch (e) {
      print("Error fetching exercises: $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    getAllExercises().then((exercises) {
      setState(() {
        allExercises = exercises;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Exercise Selection'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Exercise>>(
              future: getAllExercises(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  allExercises = snapshot.data!;
                  return ListView.builder(
                    itemCount: allExercises.length,
                    itemBuilder: (BuildContext context, int index) {
                      Exercise exercise = allExercises[index];

                      bool isSelected = selectedExercises.any(
                          (selectedExercise) =>
                              selectedExercise.name == exercise.name);

                      return Card(
                        child: CheckboxListTile(
                          title: Text(exercise.name),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                selectedExercises.add(exercise);
                              }
                            });
                          },
                          secondary: Image.asset('images/${exercise.image}'),
                        ),
                      );
                    },
                  );
                } else {
                  return Text('Error fetching exercises.');
                }
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {

              await FitnessPlanService().addMultipleExercisesToFitnessPlan(
                user!.uid,
                widget
                    .fitnessPlanName, 
                selectedExercises,
              );

              var updatedFitnessPlan =
                  await FitnessPlanService().GetFitnessPlanDetails(
                user!.uid,
                widget.fitnessPlanName,
              );

              Navigator.pop(context,
                  updatedFitnessPlan); 
            },
            icon: Icon(Icons.save), 
            label: Text('Save'), 
          ),
        ],
      ),
    );
  }
}
