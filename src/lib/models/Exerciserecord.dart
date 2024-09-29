import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseRecord {
  final int reps;
  final int sets;
  final double weight;
  final DateTime date;

  ExerciseRecord({
    required this.reps,
    required this.sets,
    required this.weight,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'reps': reps,
      'sets': sets,
      'weight': weight,
      'date': date
          .toUtc(), 
    };
  }

  factory ExerciseRecord.fromFirestore(Map<String, dynamic> data) {
    int reps = data['reps'];
    int sets = data['sets'];
    double weight = data['weight'];
    DateTime date = (data['date'] as Timestamp).toDate();

    return ExerciseRecord(reps: reps, sets: sets, weight: weight, date: date);
  }
}
