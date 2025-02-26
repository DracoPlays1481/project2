import 'package:firebase_database/firebase_database.dart';
import '../models/user_profile.dart';
import '../models/water_intake.dart';
import '../models/food_item.dart';
import '../models/recipe.dart';

class DatabaseService {
  final _database = FirebaseDatabase.instance.ref();

  // User Profile Methods
  Future<void> saveUserProfile(UserProfile profile) async {
    await _database.child('profiles/${profile.uid}').set(profile.toJson());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final snapshot = await _database.child('profiles/$uid').get();
    if (snapshot.exists) {
      return UserProfile.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }

  // Water Intake Methods
  Future<void> logWaterIntake(WaterIntake intake) async {
    final dateStr = _formatDate(intake.date);
    await _database
        .child('water_intake/${intake.userId}/$dateStr/${intake.id}')
        .set(intake.toJson());
  }

  Future<void> deleteWaterIntake(String userId, DateTime date, String intakeId) async {
    final dateStr = _formatDate(date);
    await _database
        .child('water_intake/$userId/$dateStr/$intakeId')
        .remove();
  }

  Future<List<WaterIntake>> getWaterIntakeForDate(String userId, DateTime date) async {
    final dateStr = _formatDate(date);
    final snapshot = await _database
        .child('water_intake/$userId/$dateStr')
        .get();

    if (snapshot.exists) {
      List<WaterIntake> intakes = [];
      Map<dynamic, dynamic> values = snapshot.value as Map;
      values.forEach((key, value) {
        intakes.add(WaterIntake.fromJson(Map<String, dynamic>.from(value)));
      });
      return intakes;
    }
    return [];
  }

  // Helper method to format date consistently
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Food Items Methods
  Future<List<FoodItem>> getFoodItems() async {
    final snapshot = await _database.child('food_items').get();
    if (snapshot.exists) {
      List<FoodItem> items = [];
      Map<dynamic, dynamic> values = snapshot.value as Map;
      values.forEach((key, value) {
        items.add(FoodItem.fromJson(Map<String, dynamic>.from(value)));
      });
      return items;
    }
    return [];
  }

  // Recipe Methods
  Future<List<Recipe>> getRecipes() async {
    final snapshot = await _database.child('recipes').get();
    if (snapshot.exists) {
      List<Recipe> recipes = [];
      Map<dynamic, dynamic> values = snapshot.value as Map;
      values.forEach((key, value) {
        recipes.add(Recipe.fromJson(Map<String, dynamic>.from(value)));
      });
      return recipes;
    }
    return [];
  }

  // Initialize default food items
  Future<void> initializeDefaultFoodItems() async {
    final List<FoodItem> defaultItems = [
      FoodItem(
        id: '1',
        name: 'Chicken Breast',
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6,
        servingSize: '100g',
      ),
    ];

    for (var item in defaultItems) {
      await _database.child('food_items/${item.id}').set(item.toJson());
    }
  }

  // Initialize default recipes
  Future<void> initializeDefaultRecipes() async {
    final List<Recipe> defaultRecipes = [
      Recipe(
        id: '1',
        name: 'Quinoa Buddha Bowl',
        description: 'A healthy and nutritious bowl packed with proteins and vegetables',
        ingredients: [
          '1 cup quinoa',
          '1 cup chickpeas',
          '2 cups mixed vegetables',
          '1 avocado',
          'Olive oil',
          'Lemon juice',
        ],
        instructions: [
          'Cook quinoa according to package instructions',
          'Roast vegetables in the oven',
          'Combine all ingredients in a bowl',
          'Dress with olive oil and lemon juice',
        ],
        calories: 450,
        imageUrl: 'https://example.com/buddha-bowl.jpg',
        preparationTime: 30,
        difficulty: 'Easy',
      ),
    ];

    for (var recipe in defaultRecipes) {
      await _database.child('recipes/${recipe.id}').set(recipe.toJson());
    }
  }
}