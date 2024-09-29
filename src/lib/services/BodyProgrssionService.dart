import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_planner/models/BodyProgression.dart';

class BodyProgressionService {
  Future<void> addBodyProgression(
      String userId, BodyProgression bodyInfo) async {
    try {
      CollectionReference bodyCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('bodytracker');

      var existingBody = (await bodyCollection.get()).docs;
      var currentBody = existingBody.isNotEmpty
          ? existingBody[0]['body'] as List<dynamic>
          : [];

      currentBody.add({
        'weight': bodyInfo.weight,
        'muscle': bodyInfo.muscle,
        'fat': bodyInfo.fat,
        'date': Timestamp.fromDate(bodyInfo.date),
      });

      if (existingBody.isNotEmpty) {
        await bodyCollection.doc(existingBody[0].id).update({
          'body': currentBody,
        });
      } else {
        await bodyCollection.add({
          'body': currentBody,
        });
      }
    } catch (e) {
      print("Error adding bodyProgression: $e");
    }
  }

  Future<List<BodyProgression>> getAllEvents(String userId) async {
    try {
      CollectionReference bodyCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('bodytracker');

      var existingBody = (await bodyCollection.get()).docs;

      if (existingBody.isNotEmpty) {
        var eventsArray = existingBody[0]['body'] as List<dynamic>;

        List<BodyProgression> body = eventsArray.map((bodyData) {
          return BodyProgression(
            weight: bodyData['weight'],
            fat: bodyData['fat'],
            date: (bodyData['date'] as Timestamp).toDate(),
            muscle: bodyData['muscle'],
          );
        }).toList();

        return body;
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting events: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> calculateProgress(
      String userId, BodyProgression newBodyInfo) async {
    try {
      CollectionReference bodyCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('bodytracker');

      var existingBody = (await bodyCollection.get()).docs;

      if (existingBody.isNotEmpty) {
        var eventsArray = existingBody[0]['body'] as List<dynamic>;

        int newestIndex = eventsArray.length - 1;
        int secondToNewestIndex = newestIndex - 1;

        if (secondToNewestIndex >= 0) {
          var lastBodyInfo =
              eventsArray[secondToNewestIndex] as Map<String, dynamic>;

          double weightChangePercentage =
              ((newBodyInfo.weight - lastBodyInfo['weight']) /
                      lastBodyInfo['weight']) *
                  100;
          double fatChangePercentage =
              ((newBodyInfo.fat - lastBodyInfo['fat']) / lastBodyInfo['fat']) *
                  100;
          double muscleChangePercentage =
              ((newBodyInfo.muscle - lastBodyInfo['muscle']) /
                      lastBodyInfo['muscle']) *
                  100;

          Map<String, dynamic> progress = {
            'weightChangePercentage': weightChangePercentage,
            'fatChangePercentage': fatChangePercentage,
            'muscleChangePercentage': muscleChangePercentage,
          };

          return progress;
        } else {
          print("No previous body data available for progress calculation");
          return {};
        }
      } else {
        print("No body data available for progress calculation");
        return {};
      }
    } catch (e) {
      print("Error calculating progress: $e");
      return {};
    }
  }
}
