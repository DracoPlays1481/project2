import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import 'theme/app_theme.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _databaseService = DatabaseService();
  final _authService = AuthService();
  bool _isInitialized = false;
  bool _isLoggingOut = false;

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

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return; // Prevent multiple logout attempts

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _authService.signout();
      // Navigate to login screen after successful logout
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const LoginScreen()),
              (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      // Show error message if logout fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Food Diary'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isLoggingOut
                ? const CupertinoActivityIndicator()
                : const Icon(CupertinoIcons.square_arrow_right),
            onPressed: _isLoggingOut ? null : _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to Your Food Diary',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildFeatureCard(
                    context,
                    'Food Diary',
                    CupertinoIcons.book_fill,
                        () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => DisplayItem()),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Add Meal',
                    CupertinoIcons.add_circled_solid,
                        () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => const AddItem()),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'BMI Calculator',
                    CupertinoIcons.chart_bar_fill,
                        () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const BMICalculatorScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Calories Calculator',
                    CupertinoIcons.flame_fill,
                        () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const CalorieCalculatorScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Water Intake',
                    CupertinoIcons.drop_fill,
                        () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const WaterIntakeScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Food Database',
                    CupertinoIcons.list_bullet,
                        () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const FoodListScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Healthy Recipes',
                    CupertinoIcons.doc_text_fill,
                        () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const RecipeScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    'Profile',
                    CupertinoIcons.person_fill,
                        () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}