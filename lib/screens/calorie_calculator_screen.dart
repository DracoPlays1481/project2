import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/textfield.dart';
import '../widgets/button.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalorieCalculatorScreen> createState() => _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  final _databaseService = DatabaseService();
  UserProfile? _userProfile;
  double? _dailyCalories;
  String _activityLevel = 'sedentary';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await _databaseService.getUserProfile(user.uid);
      if (profile != null) {
        setState(() {
          _userProfile = profile;
        });
        _calculateCalories();
      }
    }
  }

  void _calculateCalories() {
    if (_userProfile == null) return;

    double activityMultiplier;
    switch (_activityLevel) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'active':
        activityMultiplier = 1.725;
        break;
      case 'very_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2;
    }

    double bmr;
    if (_userProfile!.gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * _userProfile!.weight) +
          (4.799 * _userProfile!.height) - (5.677 * _userProfile!.age);
    } else {
      bmr = 447.593 + (9.247 * _userProfile!.weight) +
          (3.098 * _userProfile!.height) - (4.330 * _userProfile!.age);
    }

    setState(() {
      _dailyCalories = bmr * activityMultiplier;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_userProfile == null)
              CustomCard(
                child: Column(
                  children: [
                    Text(
                      'Profile Required',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please complete your profile to calculate daily calorie needs.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else ...[
              CustomCard(
                child: Column(
                  children: [
                    Text(
                      'Activity Level',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _activityLevel,
                      decoration: const InputDecoration(
                        labelText: 'Select Activity Level',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'sedentary',
                          child: Text('Sedentary (little or no exercise)'),
                        ),
                        DropdownMenuItem(
                          value: 'light',
                          child: Text('Light (exercise 1-3 times/week)'),
                        ),
                        DropdownMenuItem(
                          value: 'moderate',
                          child: Text('Moderate (exercise 3-5 times/week)'),
                        ),
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active (exercise 6-7 times/week)'),
                        ),
                        DropdownMenuItem(
                          value: 'very_active',
                          child: Text('Very Active (hard exercise daily)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _activityLevel = value;
                          });
                          _calculateCalories();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'Calculate Calories',
                      onPressed: _calculateCalories,
                      icon: Icons.calculate,
                    ),
                  ],
                ),
              ),
              if (_dailyCalories != null) ...[
                const SizedBox(height: 20),
                CustomCard(
                  child: Column(
                    children: [
                      Text(
                        'Daily Calorie Needs',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${_dailyCalories!.round()} calories',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This is your estimated daily calorie needs for maintaining your current weight.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'For weight loss: ${(_dailyCalories! - 500).round()} calories\n'
                            'For weight gain: ${(_dailyCalories! + 500).round()} calories',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}