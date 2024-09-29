import 'package:cloud_firestore/cloud_firestore.dart';
class BodyProgression {
  final double weight;
  final double muscle;
  final double fat;
  final DateTime date;

  BodyProgression({
    required this.weight,
    required this.muscle,
    required this.fat,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'muscle': muscle,
      'fat': fat,
      'date': Timestamp.fromDate(date), 
    };
  }

  factory BodyProgression.fromFirestore(Map<String, dynamic> data) {
    double weight = data['weight'];
    double muscle = data['muscle'];
    double fat = data['fat'];
    DateTime date = (data['date'] as Timestamp).toDate();

    return BodyProgression(weight: weight, muscle: muscle, fat: fat, date: date);
  }
}
