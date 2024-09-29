import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/services/Auth.dart';
import 'package:fitness_planner/services/InfoUserService.dart';
import 'package:fitness_planner/services/fitnessplan.dart';
import 'package:fitness_planner/services/widgets/widget_tree.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  int currentStep = 0;
  bool isWeightSubmitted = false;
  bool isHeightSubmitted = false;
  bool isAgeSubmitted = false;
  bool isPurposeSubmitted = false;
  bool isExperienceSubmitted = false;

  late double weight;
  late double height;
  late int age;
  String purpose = '';
  String experience = '';
  String? experianceFromDB = '';

  final User? user = Auth().currentUser;

  FitnessPlanService fitnessPlanService = FitnessPlanService();

  bool get allStepsCompleted =>
      isWeightSubmitted &&
      isPurposeSubmitted &&
      isExperienceSubmitted &&
      isHeightSubmitted &&
      isAgeSubmitted;

  void nextStep() {
    setState(() {
      if (currentStep < 2) {
        currentStep++;
      }
    });
  }

  void previousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stepper(
              currentStep: currentStep,
              onStepTapped: (step) {
              },
              onStepContinue: nextStep,
              onStepCancel: previousStep,
              steps: [
                Step(
                  title: Text('Body Info'),
                  content: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Weight (kg)'),
                        onChanged: (value) {
                          setState(() {
                            weight = double.parse(value);
                            isWeightSubmitted = true;
                          });
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Height (cm)'),
                        onChanged: (value) {
                          setState(() {
                            height = double.parse(value);
                            isHeightSubmitted = true;
                          });
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Age'),
                        onChanged: (value) {
                          setState(() {
                            age = int.parse(value);
                            isAgeSubmitted = true;
                          });
                        },
                      ),
                    ],
                  ),
                  isActive: currentStep >= 0,
                  state: isWeightSubmitted
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: Text('Purpose of Gym Plan'),
                  content: Column(
                    children: [
                      RadioListTile(
                        title: Text('Gain Muscle'),
                        value: 'gain_muscle',
                        groupValue: purpose,
                        onChanged: (value) {
                          setState(() {
                            purpose = value as String;
                            isPurposeSubmitted = true; 
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Lose Fat'),
                        value: 'lose_fat',
                        groupValue: purpose,
                        onChanged: (value) {
                          setState(() {
                            purpose = value as String;
                            isPurposeSubmitted = true; 
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Maintain'),
                        value: 'maintain',
                        groupValue: purpose,
                        onChanged: (value) {
                          setState(() {
                            purpose = value as String;
                            isPurposeSubmitted = true; 
                            setState(() {
                              isPurposeSubmitted = true;
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  isActive: currentStep >= 1,
                  state: isPurposeSubmitted
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: Text('Experience Level'),
                  content: Column(
                    children: [
                      RadioListTile(
                        title: Text('Experienced'),
                        value: 'experienced',
                        groupValue: experience,
                        onChanged: (value) {
                          setState(() {
                            experience = value as String;
                            isExperienceSubmitted =
                                true; 
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Little Experience'),
                        value: 'little_experience',
                        groupValue: experience,
                        onChanged: (value) {
                          setState(() {
                            experience = value as String;
                            isExperienceSubmitted =
                                true; 
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('No Experience'),
                        value: 'no_experience',
                        groupValue: experience,
                        onChanged: (value) {
                          setState(() {
                            experience = value as String;
                            isExperienceSubmitted =
                                true; 
                          });
                        },
                      ),
                    ],
                  ),
                  isActive: currentStep >= 2,
                  state: isExperienceSubmitted
                      ? StepState.complete
                      : StepState.indexed,
                ),
              ],
            ),
            if (allStepsCompleted)
              ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                                "Creating your new fitness plan with meal schedule and calculating your BMI..."),
                          ],
                        ),
                      );
                    },
                  );

                  try {
                    await Future.delayed(Duration(seconds: 2));

                    await InfoUserService(user!.uid)
                        .addBodyInfo(weight, height, age);
                    await InfoUserService(user!.uid)
                        .updateGymPlanPurpose(purpose);
                    await InfoUserService(user!.uid)
                        .updateExperienceLevel(experience);

                    experianceFromDB =
                        await InfoUserService(user!.uid).getExperienceLevel();

                    await fitnessPlanService
                        .createInitialFitnessPlanWithMealPlan(
                            user!.uid, experianceFromDB!, purpose);

                    Navigator.pop(context);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => WidgetTree()),
                    );
                  } catch (e) {
                    print("Error: $e");

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("An error occurred. Please try again."),
                      ),
                    );
                  }
                },
                child: Text('Submit'),
              ),
          ],
        ),
      ),
    );
  }
}
