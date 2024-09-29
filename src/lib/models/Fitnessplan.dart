import 'package:fitness_planner/models/exercise.dart';
import 'package:fitness_planner/models/food.dart';

class FitnessPlan {
  final String name;
  final List<Exercise> exercises;
  final List<Food> foods; 

  FitnessPlan({
    required this.name,
    required this.exercises,
    List<Food>? foods, 
  }) : foods = foods ?? []; 

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'foods': foods.map((food) => food.toMap()).toList(),
    };
  }

  factory FitnessPlan.fromFirestore(Map<String, dynamic> data) {
    String name = data['name'];
    List<dynamic> exercisesData = data['exercises'];
    List<dynamic>? foodsData = data['foods']; // Use the ? symbol for optional foods

    List<Exercise> exercises =
        exercisesData.map((exerciseData) => Exercise.fromFirestore(exerciseData)).toList();

    List<Food> foods = foodsData != null
        ? foodsData.map((foodData) => Food.fromFirestore(foodData)).toList()
        : [];

    return FitnessPlan(name: name, exercises: exercises, foods: foods);
  }
}
