import 'package:firebase_database/firebase_database.dart';
import '../models/user_profile.dart';
import '../models/water_intake.dart';
import '../models/food_item.dart';
import '../models/recipe.dart';

class DatabaseService {
  final _database = FirebaseDatabase.instance.ref();

  // Check if data exists
  Future<bool> checkIfDataExists() async {
    try {
      final foodSnapshot = await _database.child('food_items').get();
      final recipeSnapshot = await _database.child('recipes').get();
      return foodSnapshot.exists && recipeSnapshot.exists;
    } catch (e) {
      print('Error checking data existence: $e');
      return false;
    }
  }

  // User Profile Methods
  Future<void> saveUserProfile(UserProfile profile) async {
    await _database.child('profiles/${profile.uid}').set(profile.toJson());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final snapshot = await _database.child('profiles/$uid').get();
      if (snapshot.exists && snapshot.value != null) {
        return UserProfile.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      }
    } catch (e) {
      print('Error getting user profile: $e');
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
    try {
      final dateStr = _formatDate(date);
      final snapshot = await _database
          .child('water_intake/$userId/$dateStr')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        List<WaterIntake> intakes = [];
        final values = snapshot.value as Map;
        values.forEach((key, value) {
          if (value is Map) {
            intakes.add(WaterIntake.fromJson(Map<String, dynamic>.from(value)));
          }
        });
        return intakes;
      }
    } catch (e) {
      print('Error getting water intake: $e');
    }
    return [];
  }

  // Helper method to format date consistently
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Food Items Methods
  Future<List<FoodItem>> getFoodItems() async {
    try {
      print('Fetching food items...');
      final snapshot = await _database.child('food_items').get();

      if (!snapshot.exists) {
        print('No food items found in database');
        return [];
      }

      print('Raw food items data: ${snapshot.value}');

      if (snapshot.value == null) {
        print('Food items data is null');
        return [];
      }

      List<FoodItem> items = [];
      final value = snapshot.value;

      if (value is List) {
        // Handle list format
        for (var i = 0; i < value.length; i++) {
          try {
            if (value[i] != null && value[i] is Map) {
              final item = FoodItem.fromJson(Map<String, dynamic>.from(value[i] as Map));
              items.add(item);
              print('Successfully parsed food item: ${item.name}');
            }
          } catch (e) {
            print('Error parsing food item at index $i: $e');
          }
        }
      } else if (value is Map) {
        // Handle map format
        value.forEach((key, value) {
          try {
            if (value is Map) {
              final item = FoodItem.fromJson(Map<String, dynamic>.from(value));
              items.add(item);
              print('Successfully parsed food item: ${item.name}');
            } else {
              print('Invalid food item data format: $value');
            }
          } catch (e) {
            print('Error parsing food item: $e');
          }
        });
      }

      print('Successfully retrieved ${items.length} food items');
      return items;
    } catch (e) {
      print('Error getting food items: $e');
      return [];
    }
  }

  // Recipe Methods
  Future<List<Recipe>> getRecipes() async {
    try {
      print('Fetching recipes...');
      final snapshot = await _database.child('recipes').get();

      if (!snapshot.exists) {
        print('No recipes found in database');
        return [];
      }

      print('Raw recipes data: ${snapshot.value}');

      if (snapshot.value == null) {
        print('Recipes data is null');
        return [];
      }

      List<Recipe> recipes = [];
      final value = snapshot.value;

      if (value is List) {
        // Handle list format
        for (var i = 0; i < value.length; i++) {
          try {
            if (value[i] != null && value[i] is Map) {
              final recipe = Recipe.fromJson(Map<String, dynamic>.from(value[i] as Map));
              recipes.add(recipe);
              print('Successfully parsed recipe: ${recipe.name}');
            }
          } catch (e) {
            print('Error parsing recipe at index $i: $e');
          }
        }
      } else if (value is Map) {
        // Handle map format
        value.forEach((key, value) {
          try {
            if (value is Map) {
              final recipe = Recipe.fromJson(Map<String, dynamic>.from(value));
              recipes.add(recipe);
              print('Successfully parsed recipe: ${recipe.name}');
            } else {
              print('Invalid recipe data format: $value');
            }
          } catch (e) {
            print('Error parsing recipe: $e');
          }
        });
      }

      print('Successfully retrieved ${recipes.length} recipes');
      return recipes;
    } catch (e) {
      print('Error getting recipes: $e');
      return [];
    }
  }

  // Initialize default food items
  Future<void> initializeDefaultFoodItems() async {
    try {
      print('Starting to initialize default food items...');
      final List<FoodItem> defaultItems = [
        FoodItem(
          id: '1',
          name: 'Grilled Chicken Breast',
          calories: 165,
          protein: 31,
          carbs: 0,
          fat: 3.6,
          servingSize: '100g',
        ),
        FoodItem(
          id: '2',
          name: 'Quinoa (Cooked)',
          calories: 120,
          protein: 4.4,
          carbs: 21.3,
          fat: 1.9,
          servingSize: '100g',
        ),
        FoodItem(
          id: '3',
          name: 'Salmon Fillet',
          calories: 208,
          protein: 22,
          carbs: 0,
          fat: 13,
          servingSize: '100g',
        ),
        FoodItem(
          id: '4',
          name: 'Greek Yogurt',
          calories: 59,
          protein: 10,
          carbs: 3.6,
          fat: 0.4,
          servingSize: '100g',
        ),
        FoodItem(
          id: '5',
          name: 'Sweet Potato',
          calories: 86,
          protein: 1.6,
          carbs: 20,
          fat: 0.1,
          servingSize: '100g',
        ),
        FoodItem(
          id: '6',
          name: 'Avocado',
          calories: 160,
          protein: 2,
          carbs: 8.5,
          fat: 14.7,
          servingSize: '100g',
        ),
        FoodItem(
          id: '7',
          name: 'Almonds',
          calories: 579,
          protein: 21.2,
          carbs: 21.7,
          fat: 49.9,
          servingSize: '100g',
        ),
        FoodItem(
          id: '8',
          name: 'Lentils (Cooked)',
          calories: 116,
          protein: 9,
          carbs: 20,
          fat: 0.4,
          servingSize: '100g',
        ),
        FoodItem(
          id: '9',
          name: 'Spinach (Raw)',
          calories: 23,
          protein: 2.9,
          carbs: 3.6,
          fat: 0.4,
          servingSize: '100g',
        ),
        FoodItem(
          id: '10',
          name: 'Banana',
          calories: 89,
          protein: 1.1,
          carbs: 22.8,
          fat: 0.3,
          servingSize: '100g',
        ),
      ];

      // Create a single update map for all items
      final Map<String, dynamic> updates = {};
      for (var item in defaultItems) {
        updates['food_items/${item.id}'] = item.toJson();
      }

      // Update all items at once
      await _database.update(updates);
      print('Default food items initialized successfully');
    } catch (e) {
      print('Error initializing default food items: $e');
      throw e;
    }
  }

  // Initialize default recipes
  Future<void> initializeDefaultRecipes() async {
    try {
      print('Starting to initialize default recipes...');
      final List<Recipe> defaultRecipes = [
        Recipe(
          id: '1',
          name: 'Quinoa Buddha Bowl',
          description: 'A nutritious bowl packed with proteins and vegetables',
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
          imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-4.0.3',
          preparationTime: 30,
          difficulty: 'Easy',
        ),
        Recipe(
          id: '2',
          name: 'Grilled Salmon with Asparagus',
          description: 'Heart-healthy salmon with crispy asparagus',
          ingredients: [
            '200g salmon fillet',
            '1 bunch asparagus',
            '2 tbsp olive oil',
            'Lemon',
            'Salt and pepper',
          ],
          instructions: [
            'Season salmon with salt, pepper, and lemon',
            'Grill salmon for 4-5 minutes each side',
            'Grill asparagus until tender',
            'Serve with lemon wedges',
          ],
          calories: 380,
          imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?ixlib=rb-4.0.3',
          preparationTime: 25,
          difficulty: 'Medium',
        ),
        Recipe(
          id: '3',
          name: 'Mediterranean Chickpea Salad',
          description: 'Fresh and light salad with protein-rich chickpeas',
          ingredients: [
            '2 cans chickpeas',
            'Cherry tomatoes',
            'Cucumber',
            'Red onion',
            'Feta cheese',
            'Olive oil',
          ],
          instructions: [
            'Drain and rinse chickpeas',
            'Chop vegetables',
            'Combine all ingredients',
            'Dress with olive oil and seasonings',
          ],
          calories: 320,
          imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-4.0.3',
          preparationTime: 15,
          difficulty: 'Easy',
        ),
        Recipe(
          id: '4',
          name: 'Sweet Potato and Black Bean Burrito',
          description: 'Vegetarian burrito with roasted sweet potatoes',
          ingredients: [
            'Sweet potatoes',
            'Black beans',
            'Brown rice',
            'Avocado',
            'Whole wheat tortillas',
          ],
          instructions: [
            'Roast sweet potato cubes',
            'Cook rice and beans',
            'Assemble burritos',
            'Optional: grill burritos',
          ],
          calories: 420,
          imageUrl: 'https://images.unsplash.com/photo-1464219222984-216ebffaaf85?ixlib=rb-4.0.3',
          preparationTime: 40,
          difficulty: 'Medium',
        ),
        Recipe(
          id: '5',
          name: 'Greek Yogurt Parfait',
          description: 'Protein-rich breakfast parfait with fresh fruits',
          ingredients: [
            'Greek yogurt',
            'Mixed berries',
            'Granola',
            'Honey',
            'Chia seeds',
          ],
          instructions: [
            'Layer yogurt in a glass',
            'Add fresh berries',
            'Top with granola and seeds',
            'Drizzle with honey',
          ],
          calories: 280,
          imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?ixlib=rb-4.0.3',
          preparationTime: 10,
          difficulty: 'Easy',
        ),
        Recipe(
          id: '6',
          name: 'Lentil and Spinach Curry',
          description: 'Hearty vegetarian curry with protein-rich lentils',
          ingredients: [
            'Red lentils',
            'Spinach',
            'Onion',
            'Garlic',
            'Curry spices',
            'Coconut milk',
          ],
          instructions: [
            'Cook lentils until tender',
            'Sauté onions and garlic',
            'Add spices and coconut milk',
            'Stir in spinach',
          ],
          calories: 350,
          imageUrl: 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?ixlib=rb-4.0.3',
          preparationTime: 35,
          difficulty: 'Medium',
        ),
        Recipe(
          id: '7',
          name: 'Almond-Crusted Chicken',
          description: 'Healthy alternative to breaded chicken',
          ingredients: [
            'Chicken breast',
            'Ground almonds',
            'Eggs',
            'Herbs',
            'Olive oil',
          ],
          instructions: [
            'Crush almonds finely',
            'Dip chicken in egg then almonds',
            'Bake until golden',
            'Serve with vegetables',
          ],
          calories: 390,
          imageUrl: 'https://images.unsplash.com/photo-1432139509613-5c4255815697?ixlib=rb-4.0.3',
          preparationTime: 45,
          difficulty: 'Medium',
        ),
        Recipe(
          id: '8',
          name: 'Banana Oatmeal Smoothie',
          description: 'Filling breakfast smoothie with oats',
          ingredients: [
            'Banana',
            'Oats',
            'Almond milk',
            'Greek yogurt',
            'Honey',
            'Cinnamon',
          ],
          instructions: [
            'Blend all ingredients',
            'Add ice if desired',
            'Adjust thickness with milk',
            'Serve immediately',
          ],
          calories: 245,
          imageUrl: 'https://images.unsplash.com/photo-1577805947697-89e18249d767?ixlib=rb-4.0.3',
          preparationTime: 5,
          difficulty: 'Easy',
        ),
        Recipe(
          id: '9',
          name: 'Grilled Vegetable Quinoa Bowl',
          description: 'Colorful bowl with grilled vegetables',
          ingredients: [
            'Quinoa',
            'Zucchini',
            'Bell peppers',
            'Mushrooms',
            'Olive oil',
            'Herbs',
          ],
          instructions: [
            'Cook quinoa',
            'Grill vegetables',
            'Combine in bowl',
            'Add dressing',
          ],
          calories: 310,
          imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?ixlib=rb-4.0.3',
          preparationTime: 30,
          difficulty: 'Easy',
        ),
        Recipe(
          id: '10',
          name: 'Avocado Toast with Poached Egg',
          description: 'Classic healthy breakfast',
          ingredients: [
            'Whole grain bread',
            'Avocado',
            'Eggs',
            'Cherry tomatoes',
            'Red pepper flakes',
          ],
          instructions: [
            'Toast bread',
            'Mash avocado and spread',
            'Poach eggs',
            'Top with tomatoes and seasonings',
          ],
          calories: 320,
          imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?ixlib=rb-4.0.3',
          preparationTime: 15,
          difficulty: 'Medium',
        ),
      ];

      // Create a single update map for all recipes
      final Map<String, dynamic> updates = {};
      for (var recipe in defaultRecipes) {
        updates['recipes/${recipe.id}'] = recipe.toJson();
      }

      // Update all recipes at once
      await _database.update(updates);
      print('Default recipes initialized successfully');
    } catch (e) {
      print('Error initializing default recipes: $e');
      throw e;
    }
  }
}