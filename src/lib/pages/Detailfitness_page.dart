import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/services/Auth.dart';
import 'package:fitness_planner/models/fitnessplan.dart';
import 'package:fitness_planner/models/food.dart';
import 'package:fitness_planner/pages/addexercise_page.dart';
import 'package:fitness_planner/pages/Newrecord_page.dart';
import 'package:fitness_planner/services/fitnessplan.dart';
import 'package:flutter/material.dart';

class DetailFitness extends StatefulWidget {
  final String fitnessPlanName;
  DetailFitness({required this.fitnessPlanName, Key? key}) : super(key: key);

  @override
  _DetailFitnessState createState() => _DetailFitnessState();
}

class _DetailFitnessState extends State<DetailFitness> {
  final User? user = Auth().currentUser;
  late Future<FitnessPlan?> fitnessPlanFuture;
  late FitnessPlan? fitnessPlan;

  @override
  void initState() {
    super.initState();
    fitnessPlanFuture = FitnessPlanService().GetFitnessPlanDetails(
      user!.uid,
      widget.fitnessPlanName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        title: Text(widget.fitnessPlanName),
      ),
      body: Column(
        children: [
          Flexible(
            child: Center(
              child: FutureBuilder<FitnessPlan?>(
                future: fitnessPlanFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    fitnessPlan = snapshot.data;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _fitnessPlanDetailsCardWidget(fitnessPlan!),
                          _FoodListWidget(foods: fitnessPlan!.foods),
                        ],
                      ),
                    );
                  } else {
                    return Text('Fitness plan not found.');
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _addExerciseButton(),
    );
  }

  Widget _addExerciseButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: FloatingActionButton.extended(
              heroTag: 'addExerciseButton',
              onPressed: () async {
                // Navigate and wait for a result
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseSelectionPage(
                      selectedExercises: fitnessPlan?.exercises ?? [],
                      fitnessPlanName: fitnessPlan!.name,
                    ),
                  ),
                );

                if (result != null) {
                  var updatedFitnessPlan = result;

                 
                  setState(() {
                    fitnessPlanFuture = Future.value(updatedFitnessPlan);
                  });
                }
              },
              icon: Icon(Icons.add),
              label: Text('Add Exercise'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fitnessPlanDetailsCardWidget(FitnessPlan fitnessPlan) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        height: 550,
        child: Card(
          margin: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.blue, 
                child: ListTile(
                  title: Text(
                    fitnessPlan.name,
                    style: TextStyle(color: Colors.white), 
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final exercise = fitnessPlan.exercises[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Image.asset(
                              'images/${exercise.image}',
                            ),
                            title: Text(exercise.name),
                          ),
                          Column(
                            children: exercise.records.map((record) {
                              return ListTile(
                                title: Text(
                                  'Reps: ${record.reps}, Sets: ${record.sets}',
                                ),
                                subtitle:
                                    Text('Date: ${record.date.toLocal()}'),
                                trailing: Text(
                                  'Weight (kg): ${record.weight.toStringAsFixed(1)}',
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FloatingActionButton(
                                heroTag: 'addRecordButton$index',
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewRecordPage(
                                        userId: user!.uid,
                                        fitnessPlanName: widget.fitnessPlanName,
                                        exercise: exercise,
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    fitnessPlanFuture = FitnessPlanService()
                                        .GetFitnessPlanDetails(
                                            user!.uid, widget.fitnessPlanName);
                                  });
                                },
                                mini: true,
                                child: Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: fitnessPlan.exercises.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _FoodListWidget({required List<Food> foods}) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.blue,
            child: ListTile(
              title: Text(
                'Foods for this fitness plan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Column(
            children: foods.map((food) {
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(food.name),
                      leading: Image.asset('images/${food.image}'),
                    ),
                    ListTile(
                      title: Text('Carbs: ${food.carbs}g'),
                      subtitle: Text('Fat: ${food.fat}g'),
                      trailing: Text('Protein: ${food.protein}g'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
