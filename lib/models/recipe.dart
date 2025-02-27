class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final double calories;
  final String imageUrl;
  final int preparationTime; // in minutes
  final String difficulty;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.calories,
    required this.imageUrl,
    required this.preparationTime,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'calories': calories,
      'imageUrl': imageUrl,
      'preparationTime': preparationTime,
      'difficulty': difficulty,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      calories: json['calories']?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      preparationTime: json['preparationTime'] ?? 0,
      difficulty: json['difficulty'] ?? '',
    );
  }
}