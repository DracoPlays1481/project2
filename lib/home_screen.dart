import 'package:flutter/material.dart';
import 'auth/auth_service.dart';
import 'widgets/custom_card.dart';
import 'screens/bmi_calculator_screen.dart';
import 'screens/calorie_calculator_screen.dart';
import 'screens/water_intake_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/food_list_screen.dart';
import 'screens/recipe_screen.dart';
import 'display_item.dart';
import 'add_item.dart';
import 'services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _databaseService = DatabaseService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!_isInitialized) {
      await _databaseService.initializeDefaultFoodItems();
      await _databaseService.initializeDefaultRecipes();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to Your Food Diary',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  'Food Diary',
                  Icons.book,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DisplayItem()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Add Meal',
                  Icons.add_circle,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddItem()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'BMI Calculator',
                  Icons.calculate,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BMICalculatorScreen(),
                    ),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Calories Calculator',
                  Icons.local_fire_department,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalorieCalculatorScreen(),
                    ),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Water Intake',
                  Icons.water_drop,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WaterIntakeScreen(),
                    ),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Food Database',
                  Icons.restaurant_menu,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FoodListScreen(),
                    ),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Healthy Recipes',
                  Icons.menu_book,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecipeScreen(),
                    ),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  'Profile',
                  Icons.person,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}