import 'package:fitness_planner/models/exerciserecord.dart';

class Exercise {
  final String name;
  final String image;
  final String level;
  final List<ExerciseRecord> records;

  Exercise({
    required this.name,
    required this.image,
    required this.level,
    required this.records,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'level': level,
      'records': records.map((record) => record.toMap()).toList(),
    };
  }

  factory Exercise.fromFirestore(Map<String, dynamic> data) {
    String name = data['name'];
    String image = data['image'];
    String level = data['level'];

    List<dynamic>? recordsData = data['records'];
    List<ExerciseRecord> records = [];

    if (recordsData != null) {
      records = recordsData
          .map((recordData) => ExerciseRecord.fromFirestore(recordData))
          .toList();
    }

    return Exercise(name: name, image: image, level: level, records: records);
  }
}
