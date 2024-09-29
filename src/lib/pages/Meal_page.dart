import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_planner/services/Auth.dart';
import 'package:fitness_planner/services/fitnessplan.dart';
import 'package:fitness_planner/services/widgets/CommonWidgets.dart';
import 'package:flutter/material.dart';
import 'package:fitness_planner/services/InfoUserService.dart';

class MealPage extends StatefulWidget {
  const MealPage({Key? key}) : super(key: key);

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final User? user = Auth().currentUser;
  List<Map<String, dynamic>> filteredFoodData = [];
  FitnessPlanService fitnessPlanService = FitnessPlanService();
  Map<String, dynamic> nutritionalGoals = {};

  Future<Map<String, dynamic>> _calculateNutritionalGoals() async {
    try {
      Map<String, dynamic> nutritionalGoals =
          await InfoUserService(user!.uid).calculateNutritionalGoals();

      return nutritionalGoals;
    } catch (e) {
      print('Error calculating nutritional goals: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> _getFoodsByPlanPurpose() async {
    try {
      Map<String, dynamic> userInfo =
          await InfoUserService(user!.uid).getUserInfo();
      String gymPlanPurpose = userInfo['gymPlanPurpose'] ?? '';

      filteredFoodData = await fitnessPlanService.getFoodsByPlanPurpose(
          gymPlanPurpose, user!.uid);

      return filteredFoodData;
    } catch (e) {
      print('Error fetching foods by purpose: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Text(
                    'Meal Center',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Map<String, dynamic> goals =
                      await _calculateNutritionalGoals();

                  _showNutritionalGoals(goals);
                },
                icon: Icon(Icons.calculate),
                label: const Text('Calculate Nutritional Goals for today'),
              ),
              SizedBox(
                height: 20,
              ), 
              _buildNutritionalGoalsWidget(),
              FutureBuilder(
                future: _getFoodsByPlanPurpose(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return _buildHorizontalFoodList(snapshot.data);
                  } else {
                    return Text('No data available');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionalGoalsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                8.0, 8.0, 8.0, 16.0), 
            child: Text(
              'Nutritional Goals:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGoalTile('Protein',
                      '${nutritionalGoals['protein']} grams', Colors.red),
                  _buildGoalTile('Carbs', '${nutritionalGoals['carbs']} grams',
                      Colors.blue),
                  _buildGoalTile(
                      'Fat', '${nutritionalGoals['fat']} grams', Colors.green),
                  _buildGoalTile('Kilojoules',
                      '${nutritionalGoals['kilojoules']} kJ', Colors.indigo),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGoalTile('Sugar', '${nutritionalGoals['sugar']} grams',
                      Colors.orange),
                  _buildGoalTile(
                      'Saturated Fat',
                      '${nutritionalGoals['saturatedFat']} grams',
                      Colors.purple),
                  _buildGoalTile('Calories',
                      '${nutritionalGoals['calories']} kcal', Colors.yellow),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        if (nutritionalGoals.isNotEmpty)
          CommonWidgets.PieChartSyncFusion(
            protein: nutritionalGoals['protein'] ?? 0.0,
            carbs: nutritionalGoals['carbs'] ?? 0.0,
            fat: nutritionalGoals['fat'] ?? 0.0,
          ),
      ],
    );
  }

  Widget _buildGoalTile(String text, dynamic value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(10.0), 
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 4.0, right: 10.0),
      child: Text(
        '$text: ${value?.toString() ?? ' grams'}',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  void _showNutritionalGoals(Map<String, dynamic> goals) {
    setState(() {
      nutritionalGoals = goals;
    });
  }

  Widget _buildHorizontalFoodList(List<Map<String, dynamic>>? foods) {
    if (foods == null) {
      return CircularProgressIndicator(); 
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 18.0, 0, 16.0),
            child: Text(
              'All recommended food for you',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          height: 290, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: foods.length,
            itemBuilder: (context, index) {
              return _buildFoodCard(foods[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    String imagePath = 'images/${food['image']}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12.0), 
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 200, 
        height: 400, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              height: 120, 
              width: double.infinity, 
              fit: BoxFit.cover, 
            ),
            SizedBox(height: 8), 
            Center(
              child: Text(
                'Food Info',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 25), 
            Text('Name: ${food['name']}'),
            Text('Carbs: ${food['carbs']}'),
            Text('Fat: ${food['fat']}'),
            Text('Protein: ${food['protein']}'),
          ],
        ),
      ),
    );
  }
}
