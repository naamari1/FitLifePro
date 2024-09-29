import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_planner/models/exercise.dart';
import 'package:fitness_planner/models/exerciserecord.dart';
import 'package:fitness_planner/models/fitnessplan.dart';
import 'package:fitness_planner/models/food.dart';

class FitnessPlanService {
  Future<List<String>> getFitnessPlanNames(String userId) async {
    try {
      QuerySnapshot fitnessPlansSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fitnessplans')
          .get();

      List<String> planNames = fitnessPlansSnapshot.docs
          .where((doc) => (doc.get('name') as String) != 'data')
          .map((doc) => doc.get('name') as String)
          .toList();

      return planNames;
    } catch (e) {
      print("Error fetching fitness plan names: $e");
      return [];
    }
  }

  Future<List<String>> getMealsPlanNames(String userId) async {
    try {
      QuerySnapshot mealPlansSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fitnessplans')
          .get();

      List<String> planNames = mealPlansSnapshot.docs
          .where((doc) => (doc.get('Meal') as String) != 'data')
          .map((doc) => doc.get('Meal') as String)
          .toList();

      return planNames;
    } catch (e) {
      print("Error fetching fitness plan names: $e");
      return [];
    }
  }

  Future<FitnessPlan?> GetFitnessPlanDetails(
      String userId, String fitnessPlanName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fitnessplans')
          .where('name', isEqualTo: fitnessPlanName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference<Object?> fitnessPlanRef =
            querySnapshot.docs.first.reference;

        DocumentSnapshot fitnessPlanSnapshot = await fitnessPlanRef.get();

        if (fitnessPlanSnapshot.exists) {
          FitnessPlan fitnessPlan = FitnessPlan.fromFirestore(
              fitnessPlanSnapshot.data() as Map<String, dynamic>);
          return fitnessPlan;
        } else {
          print("Fitness Plan document does not exist");
          return null;
        }
      } else {
        print("Fitness Plan not found");
        return null;
      }
    } catch (e) {
      print("Error fetching fitness plan details: $e");
      return null;
    }
  }

  Future<FitnessPlan?> GetMealPlanDetails(
      String userId, String mealPlanName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('mealplans')
          .where('name', isEqualTo: mealPlanName)
          .limit(1) // Limit to 1 document (assuming names are unique)
          .get();

      DocumentReference<Object?>? mealPlanRef = querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.first.reference
          : null;

      if (mealPlanRef != null) {
        // Get the fitness plan document snapshot
        DocumentSnapshot mealPlanSnapshot = await mealPlanRef.get();

        // Convert Firestore data to FitnessPlan using the factory method
        FitnessPlan mealPlan = FitnessPlan.fromFirestore(
            mealPlanSnapshot.data() as Map<String, dynamic>);
        return mealPlan;
      } else {
        // Fitness plan does not exist
        print("Fitness Plan not found");
        return null;
      }
    } catch (e) {
      print("Error fetching fitness plan details: $e");
      return null;
    }
  }

  Future<DocumentReference<Object?>?> getFitnessPlanReference(
    String userId,
    String fitnessPlanName,
  ) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fitnessplans')
          .where('name', isEqualTo: fitnessPlanName)
          .limit(1) // Limit to 1 document (assuming names are unique)
          .get();

      return querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.first.reference
          : null;
    } catch (e) {
      print("Error fetching fitness plan reference: $e");
      return null;
    }
  }

  Future<DocumentReference<Object?>?> getMealPlanReference(
    String userId,
    String mealPlanName,
  ) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('fitnessplans')
          .where('name', isEqualTo: mealPlanName)
          .limit(1) // Limit to 1 document (assuming names are unique)
          .get();

      return querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.first.reference
          : null;
    } catch (e) {
      print("Error fetching fitness plan reference: $e");
      return null;
    }
  }

  Future<void> addExerciseRecord(
    String userId,
    String fitnessPlanName,
    Exercise exercise,
    ExerciseRecord exerciseRecord,
  ) async {
    try {
      // Get the reference to the fitness plan document
      DocumentReference<Object?>? fitnessPlanRef =
          await getFitnessPlanReference(userId, fitnessPlanName);

      if (fitnessPlanRef != null) {
        // Check if the document exists before updating
        DocumentSnapshot<Object?> fitnessPlanSnapshot =
            await fitnessPlanRef.get();

        if (fitnessPlanSnapshot.exists) {
          // Get the list of exercises from the fitness plan
          List<dynamic>? exercises =
              fitnessPlanSnapshot['exercises'] as List<dynamic>?;

          // Find the index of the target exercise in the list
          int index =
              exercises?.indexWhere((e) => e['name'] == exercise.name) ?? -1;

          if (index != -1) {
            // Exercise found, update its 'records' field
            List<dynamic> records =
                exercises![index]['records'] as List<dynamic>;

            records.add({
              'reps': exerciseRecord.reps,
              'sets': exerciseRecord.sets,
              'weight': exerciseRecord.weight,
              'date': Timestamp.fromDate(exerciseRecord.date),
            });

            // Update the fitness plan document with the modified 'exercises' list
            await fitnessPlanRef.update({
              'exercises': exercises,
            });
          } else {
            print('Exercise not found in the fitness plan.');
          }
        } else {
          print('Fitness plan document does not exist.');
        }
      } else {
        print('Fitness plan document reference not found.');
      }
    } catch (e) {
      print("Error adding exercise record: $e");
    }
  }

  Future<DocumentReference> createExerciseCollection() async {
    try {
      CollectionReference exercisesCollection =
          FirebaseFirestore.instance.collection('exercises');

      // List of exercises with levels
      List<Map<String, dynamic>> exercises = [
        // Low-level exercises
        {'name': 'Pushup', 'image': 'pushup.png', 'level': 'no_experience'},
        {'name': 'Sit-up', 'image': 'situp.png', 'level': 'no_experience'},
        {'name': 'Squats', 'image': 'squats.png', 'level': 'no_experience'},
        {'name': 'Lunges', 'image': 'lunges.png', 'level': 'no_experience'},
        {'name': 'Plank', 'image': 'plank.png', 'level': 'no_experience'},

        // Medium-level exercises
        {
          'name': 'Pull-up',
          'image': 'pullup.png',
          'level': 'little_experience'
        },
        {
          'name': 'Burpees',
          'image': 'burpees.png',
          'level': 'little_experience'
        },
        {
          'name': 'Mountain Climbers',
          'image': 'mountainclimbers.png',
          'level': 'little_experience'
        },
        {
          'name': 'Jumping Jacks',
          'image': 'jumpingjacks.png',
          'level': 'little_experience'
        },
        {
          'name': 'Cycling',
          'image': 'cycling.png',
          'level': 'little_experience'
        },

        // Hard-level exercises
        {'name': 'Deadlift', 'image': 'deadlift.png', 'level': 'experienced'},
        {'name': 'Box Jumps', 'image': 'boxjumps.png', 'level': 'experienced'},
        {
          'name': 'Handstand Push-ups',
          'image': 'handstandpushups.png',
          'level': 'experienced'
        },
        {
          'name': 'Kettlebell Swings',
          'image': 'kettlebellswings.png',
          'level': 'experienced'
        },
        {
          'name': 'Battle Ropes',
          'image': 'battleropes.png',
          'level': 'experienced'
        },
      ];

      // Add exercises to the collection
      DocumentReference exercisesDocument =
          await exercisesCollection.add({'exercises': exercises});

      return exercisesDocument;
    } catch (e) {
      print("Error creating exercise collection: $e");
      throw e;
    }
  }

  Future<DocumentReference> createFoodCollection() async {
    try {
      CollectionReference foodsCollection =
          FirebaseFirestore.instance.collection('foods');

      List<Map<String, dynamic>> foods = [
        {
          'name': 'Chicken Breast',
          'carbs': 0.0,
          'fat': 1.0,
          'protein': 30.0,
          'image': 'chickenbreast.png'
        },
        {
          'name': 'Salmon',
          'carbs': 0.0,
          'fat': 12.0,
          'protein': 25.0,
          'image': 'Salmon.png'
        },
        {
          'name': 'Quinoa',
          'carbs': 40.0,
          'fat': 3.0,
          'protein': 8.0,
          'image': 'Quinoa.png'
        },
        {
          'name': 'Avocado',
          'carbs': 12.0,
          'fat': 15.0,
          'protein': 2.0,
          'image': 'Avocado.png'
        },
        {
          'name': 'Broccoli',
          'carbs': 6.0,
          'fat': 0.5,
          'protein': 3.0,
          'image': 'broccoli.png'
        },
        {
          'name': 'Sweet Potato',
          'carbs': 26.0,
          'fat': 0.2,
          'protein': 2.0,
          'image': 'SweetPotato.png'
        },
        {
          'name': 'Almonds',
          'carbs': 6.0,
          'fat': 14.0,
          'protein': 6.0,
          'image': 'Almonds.png'
        },
        {
          'name': 'Greek Yogurt',
          'carbs': 7.0,
          'fat': 4.0,
          'protein': 15.0,
          'image': 'GreekYogurt.png'
        },
        {
          'name': 'Oatmeal',
          'carbs': 28.0,
          'fat': 3.5,
          'protein': 5.0,
          'image': 'Oatmeal.png'
        },
        {
          'name': 'Eggs',
          'carbs': 1.0,
          'fat': 6.0,
          'protein': 7.0,
          'image': 'Eggs.png'
        },
        {
          'name': 'Banana',
          'carbs': 27.0,
          'fat': 0.3,
          'protein': 1.3,
          'image': 'Banana.png'
        },
        {
          'name': 'Spinach',
          'carbs': 1.0,
          'fat': 0.5,
          'protein': 1.0,
          'image': 'Spinach.png'
        },
        {
          'name': 'Brown Rice',
          'carbs': 45.0,
          'fat': 1.0,
          'protein': 5.0,
          'image': 'BrownRice.png'
        },
        {
          'name': 'Cottage Cheese',
          'carbs': 6.0,
          'fat': 2.0,
          'protein': 14.0,
          'image': 'CottageCheese.png'
        },
        {
          'name': 'Blueberries',
          'carbs': 21.0,
          'fat': 0.5,
          'protein': 1.0,
          'image': 'Blueberries.png'
        },
        {
          'name': 'Beef',
          'carbs': 0.0,
          'fat': 20.0,
          'protein': 25.0,
          'image': 'Beef.png'
        },
        {
          'name': 'Pork Chops',
          'carbs': 0.0,
          'fat': 15.0,
          'protein': 30.0,
          'image': 'PorkChops.png'
        },
        {
          'name': 'Pasta',
          'carbs': 40.0,
          'fat': 2.0,
          'protein': 8.0,
          'image': 'Pasta.png'
        },
        {
          'name': 'Cheddar Cheese',
          'carbs': 2.0,
          'fat': 10.0,
          'protein': 7.0,
          'image': 'CheddarCheese.png'
        },
        {
          'name': 'Apples',
          'carbs': 30.0,
          'fat': 0.5,
          'protein': 0.3,
          'image': 'Apples.png'
        },
        {
          'name': 'Peanut Butter',
          'carbs': 6.0,
          'fat': 16.0,
          'protein': 7.0,
          'image': 'PeanutButter.png'
        },
        {
          'name': 'Tuna',
          'carbs': 0.0,
          'fat': 1.0,
          'protein': 25.0,
          'image': 'Tuna.png'
        },
        {
          'name': 'Asparagus',
          'carbs': 5.0,
          'fat': 0.2,
          'protein': 3.0,
          'image': 'Asparagus.png'
        },
        {
          'name': 'Potatoes',
          'carbs': 30.0,
          'fat': 0.2,
          'protein': 2.0,
          'image': 'Potatoes.png'
        },
        {
          'name': 'Walnuts',
          'carbs': 4.0,
          'fat': 18.0,
          'protein': 4.0,
          'image': 'Walnuts.png'
        },
        {
          'name': 'Milk',
          'carbs': 12.0,
          'fat': 8.0,
          'protein': 8.0,
          'image': 'Milk.png'
        },
        {
          'name': 'Carrots',
          'carbs': 12.0,
          'fat': 0.3,
          'protein': 1.0,
          'image': 'Carrots.png'
        },
        {
          'name': 'Shrimp',
          'carbs': 1.0,
          'fat': 1.0,
          'protein': 24.0,
          'image': 'Shrimp.png'
        },
        {
          'name': 'Oranges',
          'carbs': 20.0,
          'fat': 0.2,
          'protein': 1.0,
          'image': 'Oranges.png'
        },
        {
          'name': 'Cauliflower',
          'carbs': 5.0,
          'fat': 0.3,
          'protein': 2.0,
          'image': 'Cauliflower.png'
        },
        {
          'name': 'Black Beans',
          'carbs': 40.0,
          'fat': 0.5,
          'protein': 15.0,
          'image': 'BlackBeans.png'
        },
      ];

      DocumentReference foodsDocument =
          await foodsCollection.add({'foods': foods});

      return foodsDocument;
    } catch (e) {
      print("Error creating food collection: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>?> getExerciseById(String exerciseId) async {
    try {
      // Reference to the specific exercise document using its ID
      DocumentReference exerciseDocument =
          FirebaseFirestore.instance.doc('exercises/$exerciseId');

      // Get the document snapshot
      DocumentSnapshot exerciseSnapshot = await exerciseDocument.get();

      // Check if the document exists
      if (exerciseSnapshot.exists) {
        // Extract the list of exercises from the "exercises" key in the document
        List<dynamic> exercisesList = exerciseSnapshot['exercises'] ?? [];

        // Convert the list to a List<Map<String, dynamic>>
        List<Map<String, dynamic>> exercisesDataList =
            List<Map<String, dynamic>>.from(exercisesList);

        return exercisesDataList;
      } else {
        print("Exercise with ID $exerciseId not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching exercise with ID $exerciseId: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getFoodById(String foodId) async {
    try {
      DocumentReference foodDocument =
          FirebaseFirestore.instance.doc('foods/$foodId');

      DocumentSnapshot foodSnapshot = await foodDocument.get();

      if (foodSnapshot.exists) {
        List<dynamic> foodsList = foodSnapshot['foods'] ?? [];

        List<Map<String, dynamic>> foodsDataList =
            List<Map<String, dynamic>>.from(foodsList);

        return foodsDataList;
      } else {
        print("Exercise with ID $foodId not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching exercise with ID $foodId: $e");
      return null;
    }
  }

  Future<List<String>> getExerciseIdsForUser(String userId) async {
    try {
      // Reference to the user document
      DocumentReference userDocument =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Get the user document snapshot
      DocumentSnapshot userSnapshot = await userDocument.get();

      // Check if the user document exists
      if (userSnapshot.exists) {
        // Extract exercise reference from the 'exercises' field
        DocumentReference? exerciseReference = userSnapshot['exercises'];

        if (exerciseReference != null) {
          // Convert exercise reference to exercise ID
          String exerciseId = exerciseReference.path.split('/').last;

          return [exerciseId];
        } else {
          print('No exercise reference found for user with ID $userId.');
          return [];
        }
      } else {
        print('User with ID $userId not found.');
        return [];
      }
    } catch (e) {
      print('Error fetching exercise ID for user $userId: $e');
      return [];
    }
  }

  Future<List<String>> getFoodIdsForUser(String userId) async {
    try {
      // Reference to the user document
      DocumentReference userDocument =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Get the user document snapshot
      DocumentSnapshot userSnapshot = await userDocument.get();

      // Check if the user document exists
      if (userSnapshot.exists) {
        // Extract exercise reference from the 'exercises' field
        DocumentReference? foodReference = userSnapshot['foods'];

        if (foodReference != null) {
          // Convert exercise reference to exercise ID
          String foodId = foodReference.path.split('/').last;

          return [foodId];
        } else {
          print('No food reference found for user with ID $userId.');
          return [];
        }
      } else {
        print('User with ID $userId not found.');
        return [];
      }
    } catch (e) {
      print('Error fetching food ID for user $userId: $e');
      return [];
    }
  }

  Future<void> addMultipleExercisesToFitnessPlan(
    String userId,
    String fitnessPlanName,
    List<Exercise> exercisesToAdd,
  ) async {
    try {
      // Get the reference to the fitness plan document
      DocumentReference<Object?>? fitnessPlanRef =
          await getFitnessPlanReference(userId, fitnessPlanName);

      if (fitnessPlanRef != null) {
        // Check if the document exists before updating
        DocumentSnapshot<Object?> fitnessPlanSnapshot =
            await fitnessPlanRef.get();

        if (fitnessPlanSnapshot.exists) {
          // Get the list of exercises from the fitness plan
          List<dynamic>? existingExercises =
              fitnessPlanSnapshot['exercises'] as List<dynamic>?;

          // Convert existingExercises to List<Map<String, dynamic>> for easier manipulation
          List<Map<String, dynamic>> exercisesList =
              List.from(existingExercises ?? []);

          // Check if the exercise is already in the fitness plan
          for (Exercise exercise in exercisesToAdd) {
            bool exerciseExists =
                exercisesList.any((e) => e['name'] == exercise.name);

            if (!exerciseExists) {
              // Add the new exercise to the 'exercises' list
              exercisesList.add({
                'name': exercise.name,
                'image': exercise.image,
                'level': exercise.level,
                'records': [], // You can initialize records as an empty list
              });
            } else {
              print(
                  'Exercise ${exercise.name} already exists in the fitness plan.');
            }
          }

          // Update the fitness plan document with the modified 'exercises' list
          await fitnessPlanRef.update({
            'exercises': exercisesList,
          });
        } else {
          print('Fitness plan document does not exist.');
        }
      } else {
        print('Fitness plan document reference not found.');
      }
    } catch (e) {
      print("Error adding exercises to fitness plan: $e");
    }
  }

  Future<List<String>> addFitnessPlan(
      String userId, String fitnessPlanName) async {
    try {
      // Reference to the user's fitness plans collection
      CollectionReference<Object?> fitnessPlansCollection =
          FirebaseFirestore.instance.collection('users/$userId/fitnessplans');

      // Check if the fitness plan with the same name already exists
      QuerySnapshot<Object?> existingFitnessPlan = await fitnessPlansCollection
          .where('name', isEqualTo: fitnessPlanName)
          .get();

      if (existingFitnessPlan.docs.isNotEmpty) {
        // Fitness plan with the same name already exists
        print('Fitness plan with name $fitnessPlanName already exists.');
        return [];
      }

      // Add the fitness plan to the collection
      await fitnessPlansCollection.add({
        'name': fitnessPlanName,
        'exercises': [], // Initialize exercises as an empty list
      });

      print('Fitness plan added successfully.');
    } catch (e) {
      print('Error adding fitness plan: $e');
      // Handle the error if needed
    }

    // Return the updated list of fitness plans
    return await FitnessPlanService().getFitnessPlanNames(userId);
  }

  Future<List<String>> addFitnessPlanWithMeals(
      String userId, String fitnessPlanName, String mealPlanName) async {
    try {
      // Reference to the user's fitness plans collection
      CollectionReference<Object?> fitnessPlansCollection =
          FirebaseFirestore.instance.collection('users/$userId/fitnessplans');

      // Check if the fitness plan with the same name already exists
      QuerySnapshot<Object?> existingFitnessPlan = await fitnessPlansCollection
          .where('name', isEqualTo: fitnessPlanName)
          .get();

      if (existingFitnessPlan.docs.isNotEmpty) {
        // Fitness plan with the same name already exists
        print('Fitness plan with name $fitnessPlanName already exists.');
        return [];
      }

      // Add the fitness plan to the collection
      await fitnessPlansCollection.add({
        'name': fitnessPlanName,
        'exercises': [],
        'foods': [], // Initialize exercises as an empty list
        'Meal': mealPlanName
      });

      print('Fitness plan added successfully.');
    } catch (e) {
      print('Error adding fitness plan: $e');
      // Handle the error if needed
    }

    // Return the updated list of fitness plans
    return await FitnessPlanService().getFitnessPlanNames(userId);
  }

  Future<List<String>> addMealsPlan(String userId, String MealsPlanName) async {
    try {
      // Reference to the user's fitness plans collection
      CollectionReference<Object?> mealPlansCollection =
          FirebaseFirestore.instance.collection('users/$userId/fitnessplans');

      // Check if the fitness plan with the same name already exists
      QuerySnapshot<Object?> existingFitnessPlan = await mealPlansCollection
          .where('Meal', isEqualTo: MealsPlanName)
          .get();

      if (existingFitnessPlan.docs.isNotEmpty) {
        // Fitness plan with the same name already exists
        print('Meals plan with name $MealsPlanName already exists.');
        return [];
      }

      // Add the fitness plan to the collection
      await mealPlansCollection.add({
        'Meal': MealsPlanName,
        'foods': [], // Initialize exercises as an empty list
      });

      print('Fitness plan added successfully.');
    } catch (e) {
      print('Error adding fitness plan: $e');
      // Handle the error if needed
    }

    // Return the updated list of fitness plans
    return await FitnessPlanService().getMealsPlanNames(userId);
  }

  Future<List<String>> createInitialFitnessPlan(
      String userId, String experienceLevel) async {
    try {
      // Get the list of exercises based on the user's experience level
      List<Map<String, dynamic>> exercises =
          await getExercisesByExperienceLevel(experienceLevel, userId);

      // Create a unique fitness plan name based on the experience level
      String fitnessPlanName = 'Initial Fitness Plan - $experienceLevel';

      // Add the fitness plan to the user's collection
      List<String> updatedFitnessPlans =
          await addFitnessPlan(userId, fitnessPlanName);

      if (updatedFitnessPlans.isNotEmpty) {
        // Add each exercise to the newly created fitness plan
        for (Map<String, dynamic> exercise in exercises) {
          await addExerciseToFitnessPlan(
            userId,
            fitnessPlanName,
            Exercise(
              name: exercise['name'] as String,
              image: exercise['image'] as String,
              level: exercise['level'] as String,
              records: [],
            ),
          );
        }

        // Return the updated list of fitness plans
        return updatedFitnessPlans;
      }
    } catch (e) {
      print('Error creating initial fitness plan: $e');
      // Handle the error if needed
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> getFoodsByPlanPurpose(
    String purpose,
    String userId,
  ) async {
    try {
      List<String> foodIds =
          await FitnessPlanService().getFoodIdsForUser(userId);
      List<Food> allFoods = [];

      // Iterate through each food ID
      for (String foodId in foodIds) {
        // Call the method to get information for a specific food
        List<Map<String, dynamic>>? foodsData =
            await FitnessPlanService().getFoodById(foodId);

        // Check if food data is available
        if (foodsData != null && foodsData.isNotEmpty) {
          // Iterate through each food data and create Exercise instances
          for (Map<String, dynamic> foodData in foodsData) {
            // Create an Exercise instance using the factory constructor
            Food food = Food.fromFirestore(foodData);

            // Add the food to the overall list
            allFoods.add(food);
          }
        }
      }

      // Filter foods based on purpose
      List<Food> filteredFoods = [];
      switch (purpose) {
        case 'gain_muscle':
          filteredFoods = allFoods.where((food) => food.protein > 10).toList();
          break;
        case 'lose_fat':
          filteredFoods = allFoods.where((food) => food.fat < 10).toList();
          break;
        case 'maintain':
          filteredFoods = allFoods.where((food) => food.fat <= 15).toList();
          break;
        default:
          print('Invalid purpose');
      }

      // Now you have the filtered foods
      print('Filtered Foods: $filteredFoods');

      // If you need to return the filtered foods as a list of maps, you can convert them
      List<Map<String, dynamic>> filteredFoodData =
          filteredFoods.map((food) => food.toMap()).toList();

      return filteredFoodData;
    } catch (e) {
      print('Error fetching foods by purpose: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getExercisesByExperienceLevel(
      String experienceLevel, String userId) async {
    try {
      List<String> exerciseIds =
          await FitnessPlanService().getExerciseIdsForUser(userId);

      List<Exercise> allExercises = [];

      // Iterate through each exercise ID
      for (String exerciseId in exerciseIds) {
        // Call the method to get information for a specific exercise
        List<Map<String, dynamic>>? exercisesData =
            await FitnessPlanService().getExerciseById(exerciseId);

        // Check if exercise data is available
        if (exercisesData != null && exercisesData.isNotEmpty) {
          // Iterate through each exercise data and create Exercise instances
          for (Map<String, dynamic> exerciseData in exercisesData) {
            // Create an Exercise instance using the factory constructor
            Exercise exercise = Exercise.fromFirestore(exerciseData);

            // Add the exercise to the overall list
            allExercises.add(exercise);
          }
        }
      }

      // Filter exercises based on experience level
      List<Exercise> filteredExercises = allExercises
          .where((exercise) => exercise.level == experienceLevel)
          .toList();

      // Now you have the filtered exercises
      print('Filtered Exercises: $filteredExercises');

      // If you need to return the filtered exercises as a list of maps, you can convert them
      List<Map<String, dynamic>> filteredExercisesData =
          filteredExercises.map((exercise) => exercise.toMap()).toList();

      return filteredExercisesData;
    } catch (e) {
      print('Error fetching exercises by experience level: $e');
      throw e;
    }
  }

  Future<void> addExerciseToFitnessPlan(
    String userId,
    String fitnessPlanName,
    Exercise exercise,
  ) async {
    try {
      // Get the reference to the fitness plan document
      DocumentReference<Object?>? fitnessPlanRef =
          await getFitnessPlanReference(userId, fitnessPlanName);

      if (fitnessPlanRef != null) {
        // Check if the document exists before updating
        DocumentSnapshot<Object?> fitnessPlanSnapshot =
            await fitnessPlanRef.get();

        if (fitnessPlanSnapshot.exists) {
          // Get the list of exercises from the fitness plan
          List<dynamic>? exercises =
              fitnessPlanSnapshot['exercises'] as List<dynamic>?;

          // Check if the exercise is already in the fitness plan
          bool exerciseExists =
              exercises?.any((e) => e['name'] == exercise.name) ?? false;

          if (!exerciseExists) {
            // Add the new exercise to the 'exercises' list
            exercises?.add({
              'name': exercise.name,
              'image': exercise.image,
              'level': exercise.level,
              'records': [], // You can initialize records as an empty list
            });

            // Update the fitness plan document with the modified 'exercises' list
            await fitnessPlanRef.update({
              'exercises': exercises,
            });
          } else {
            print('Exercise already exists in the fitness plan.');
          }
        } else {
          print('Fitness plan document does not exist.');
        }
      } else {
        print('Fitness plan document reference not found.');
      }
    } catch (e) {
      print("Error adding exercise to fitness plan: $e");
    }
  }

  Future<void> addFoodToFitnessPlan(
    String userId,
    String fitnessPlanName,
    Food food,
  ) async {
    try {
      // Get the reference to the fitness plan document
      DocumentReference<Object?>? fitnessPlanRef =
          await getFitnessPlanReference(userId, fitnessPlanName);

      if (fitnessPlanRef != null) {
        // Check if the document exists before updating
        DocumentSnapshot<Object?> fitnessPlanSnapshot =
            await fitnessPlanRef.get();

        if (fitnessPlanSnapshot.exists) {
          // Get the list of foods from the fitness plan
          List<dynamic>? foods = fitnessPlanSnapshot['foods'] as List<dynamic>?;

          // Check if the 'foods' list is null or empty
          if (foods == null) {
            foods = [];
          }

          // Check if the food already exists in the fitness plan
          bool foodExists =
              foods.any((f) => f != null && f['name'] == food.name) ?? false;

          if (!foodExists) {
            // Add the new food to the 'foods' list
            foods.add(food.toMap());

            // Update the fitness plan document with the modified 'foods' list
            await fitnessPlanRef.update({
              'foods': foods,
            });
          } else {
            // Food already exists in the fitness plan
            // You might want to update the existing food or handle it as needed
            print('Food already exists in the fitness plan.');
          }
        } else {
          print('Fitness plan document does not exist.');
        }
      } else {
        print('Fitness plan document reference not found.');
      }
    } catch (e) {
      print("Error adding food to fitness plan: $e");
    }
  }

  Future<List<String>> createInitialFitnessPlanWithMealPlan(
      String userId, String experienceLevel, String purpose) async {
    try {
      // Get the list of exercises based on the user's experience level
      List<Map<String, dynamic>> exercises =
          await getExercisesByExperienceLevel(experienceLevel, userId);

      List<Map<String, dynamic>> foods =
          await getFoodsByPlanPurpose(purpose, userId);

      // Create a unique fitness plan name based on the experience level
      String fitnessPlanName = 'Initial Fitness Plan - $experienceLevel';
      String mealsPlanName = 'Initial Meals Plan - $purpose';

      // Add the fitness plan to the user's collection
      List<String> updatedFitnessPlans =
          await addFitnessPlanWithMeals(userId, fitnessPlanName, mealsPlanName);

      if (updatedFitnessPlans.isNotEmpty) {
        // Add each exercise to the newly created fitness plan
        for (Map<String, dynamic> exercise in exercises) {
          await addExerciseToFitnessPlan(
            userId,
            fitnessPlanName,
            Exercise(
              name: exercise['name'] as String,
              image: exercise['image'] as String,
              level: exercise['level'] as String,
              records: [],
            ),
          );
        }

        for (Map<String, dynamic> food in foods) {
          await addFoodToFitnessPlan(
            userId,
            fitnessPlanName,
            Food(
              name: food['name'] as String,
              carbs: food['carbs'] as double,
              fat: food['fat'] as double,
              protein: food['protein'] as double,
              image: food['image'] as String,
            ),
          );
        }
      }

      // Add each food to the newly created meals plan
    } catch (e) {
      print('Error creating initial fitness plan: $e');
      // Handle the error if needed
    }

    return [];
  }
}
