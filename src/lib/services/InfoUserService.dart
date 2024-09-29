import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class InfoUserService {
  final String userId;

  InfoUserService(this.userId);

  Future<void> addBodyInfo(double weight, double height, int age) async {
    try {
      // Reference to the user's document
      DocumentReference userDocument =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Update the user's document with the body information
      await userDocument.update({
        'bodyInfo': {
          'weight': weight,
          'height': height,
          'age': age,
        },
      });

      print('Body information added successfully.');
    } catch (e) {
      print('Error adding body information: $e');
      // Handle the error if needed
    }
  }

  Future<bool> hasBodyInfo() async {
  try {
    // Reference to the user document
    DocumentReference userDocument =
        FirebaseFirestore.instance.collection('users').doc(userId);

    // Get the user document snapshot
    DocumentSnapshot userSnapshot = await userDocument.get();

    // Check if 'bodyInfo' field exists in the document
    return userSnapshot.exists && userSnapshot['bodyInfo'] != null;
  } catch (e) {
    print('Error checking bodyInfo: $e');
    // Handle the error if needed
    return false; // Return false in case of an error
  }
}


  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      // Reference to the user document
      DocumentReference userDocument =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Get the user document snapshot
      DocumentSnapshot userSnapshot = await userDocument.get();

      // Return a Map containing 'bodyInfo' and 'gymPlanPurpose'
      if (userSnapshot.exists) {
        Map<String, dynamic> userInfo = {
          'bodyInfo': userSnapshot['bodyInfo'] as Map<String, dynamic>,
          'gymPlanPurpose': userSnapshot['gymPlanPurpose'] as String,
        };

        return userInfo;
      } else {
        // Return null if the document doesn't exist
        return {};
      }
    } catch (e) {
      print('Error fetching user info: $e');
      // Handle the error if needed
      throw e;
    }
  }

  Future<void> updateGymPlanPurpose(String purpose) async {
    try {
      // Reference to the user document
      DocumentReference userDocument =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Update the purpose field in the user document
      await userDocument.update({
        'gymPlanPurpose': purpose,
      });

      print('Gym plan purpose updated successfully.');
    } catch (e) {
      print('Error updating gym plan purpose: $e');
      // Handle the error if needed
    }
  }

  Future<void> updateExperienceLevel(String experience) async {
    // Add logic to update experience level in the user's collection
    // You can use FirebaseFirestore.instance.collection('users')...

    // For example:
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'experienceLevel': experience,
    });
  }

  Future<double> calculateBMI() async {
  try {
    // Retrieve user's weight and height from the Firestore document
    DocumentReference userDocument =
        FirebaseFirestore.instance.collection('users').doc(userId);

    DocumentSnapshot snapshot = await userDocument.get();

    if (snapshot.exists) {
      // Check if 'bodyInfo' exists and contains 'weight' and 'height'
      if (snapshot['bodyInfo'] != null &&
          snapshot['bodyInfo']['weight'] != null &&
          snapshot['bodyInfo']['height'] != null) {
        // Get user's weight and height
        double weight = snapshot['bodyInfo']['weight'];
        double height =
            snapshot['bodyInfo']['height'] / 100; // Convert height to meters

        // Calculate BMI (BMI = weight (kg) / (height (m) * height (m)))
        double bmi = weight / (height * height);

        return bmi;
      }
    }

    // Return a special value (e.g., -1) if 'bodyInfo' or required fields are missing
    return -1.0;
  } catch (e) {
    print('Error calculating BMI: $e');
    // Handle the error if needed
    return -1.0;
  }
}


  Future<String?> getExperienceLevel() async {
    try {
      // Reference to the user document
      DocumentReference userDocument =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Get the user document snapshot
      DocumentSnapshot userSnapshot = await userDocument.get();

      // Return the experience level if the document exists
      if (userSnapshot.exists) {
        return userSnapshot['experienceLevel'] as String?;
      } else {
        // Return null if the document doesn't exist
        return null;
      }
    } catch (e) {
      print('Error fetching experience level: $e');
      // Handle the error if needed
      return null;
    }
  }

  Future<Map<String, dynamic>> calculateNutritionalGoals() async {
    try {
      // Fetch user information
      Map<String, dynamic> userInfo =
          await InfoUserService(userId).getUserInfo();

      // Access 'bodyInfo' and 'gymPlanPurpose'
      Map<String, dynamic> bodyInfo = userInfo['bodyInfo'] ?? {};
      String gymPlanPurpose = userInfo['gymPlanPurpose'] ?? '';

      // Extract weight, height, and age from 'bodyInfo'
      double weight = bodyInfo['weight'] ?? 0.0;
      double height = bodyInfo['height'] ?? 0.0;
      int age = bodyInfo['age'] ?? 0;

      // Calculate BMR (Basal Metabolic Rate) using Harris-Benedict equation
      double bmr;
      if (gymPlanPurpose == 'lose_fat' ||
          gymPlanPurpose == 'maintain' ||
          gymPlanPurpose == 'muscle_gain') {
        bmr = 655 + 9.6 * weight + 1.8 * height - 4.7 * age;
      } else {
        // Default for weight maintenance
        bmr = 655 + 9.6 * weight + 1.8 * height - 4.7 * age;
      }

      // Calculate TDEE (Total Daily Energy Expenditure)
      double tdee = bmr * 1.2; // Assuming a sedentary activity level

      // Set nutritional goals based on the provided values
      Map<String, dynamic> nutritionalGoals = {
        'protein': 0.8 * weight, // 0.8 grams of protein per kg of body weight
        'carbs': tdee * 0.45 / 4, // 45% of TDEE from carbohydrates
        'fat': tdee * 0.25 / 9, // 25% of TDEE from fat
        'sugar': 74, // Assuming a maximum of 74 grams of sugar per day
        'saturatedFat':
            31, // Assuming a maximum of 31 grams of saturated fat per day
        'calories': tdee,
        'kilojoules': tdee * 4.184, // Conversion from calories to kilojoules
      };

      //Ensure that the calculated values are within the specified ranges
      nutritionalGoals['protein'] =
          max<double>(88, min<double>(236, nutritionalGoals['protein']));
      nutritionalGoals['carbs'] =
          max<double>(295, min<double>(493, nutritionalGoals['carbs']));
      nutritionalGoals['fat'] =
          max<double>(63, min<double>(110, nutritionalGoals['fat']));

      // Return the calculated nutritional goals
      return nutritionalGoals;
    } catch (e) {
      print('Error calculating nutritional goals: $e');
      // Handle the error if needed
      throw e;
    }
  }
}
