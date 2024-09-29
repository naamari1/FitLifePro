class Food {
  final String name;
  final double carbs;
  final double fat;
  final double protein;
  final String image; 

  Food({
    required this.name,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.image, 
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'carbs': carbs,
      'fat': fat,
      'protein': protein,
      'image': image, 
    };
  }

  factory Food.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      throw Exception("Food data is null");
    }

    try {
      String name = data['name'] ?? ''; 
      double carbs = (data['carbs'] ?? 0.0).toDouble(); 
      double fat = (data['fat'] ?? 0.0).toDouble(); 
      double protein = (data['protein'] ?? 0.0).toDouble(); 
      String image = data['image'] ?? ''; 

      return Food(
        name: name,
        carbs: carbs,
        fat: fat,
        protein: protein,
        image: image,
      );
    } catch (e) {
      print("Error parsing Food data: $e");
      throw Exception("Error parsing Food data");
    }
  }
}
