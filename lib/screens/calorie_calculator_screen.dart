import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/textfield.dart';
import '../widgets/button.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profile = await _databaseService.getUserProfile(user.uid);
        if (profile != null) {
          setState(() {
            _userProfile = profile;
            print('Profile loaded for calorie calculator: ${profile.name}, Age: ${profile.age}, Weight: ${profile.weight}, Height: ${profile.height}');
          });
          _calculateCalories();
        } else {
          setState(() {
            _errorMessage = 'Failed to load profile data';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'User not logged in';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
      });
      print('Error in _loadUserProfile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateCalories() {
    if (_userProfile == null) return;

    // Check if we have all required data
    if (_userProfile!.weight <= 0 || _userProfile!.height <= 0 || _userProfile!.age <= 0) {
      setState(() {
        _errorMessage = 'Please complete your profile with valid weight, height, and age';
      });
      return;
    }

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
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Calculator'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              CustomCard(
                child: Column(
                  children: [
                    Text(
                      'Attention',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'Go to Profile',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen()),
                        );
                      },
                      icon: Icons.person,
                    ),
                  ],
                ),
              )
            else if (_userProfile == null || _userProfile!.weight <= 0 || _userProfile!.height <= 0 || _userProfile!.age <= 0)
              CustomCard(
                child: Column(
                  children: [
                    Text(
                      'Profile Required',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please complete your profile with weight, height, and age to calculate daily calorie needs.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'Go to Profile',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen()),
                        );
                      },
                      icon: Icons.person,
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
                const SizedBox(height: 20),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Profile Data',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Name'),
                        subtitle: Text(_userProfile!.name.isEmpty ? 'Not set' : _userProfile!.name),
                      ),
                      ListTile(
                        leading: Icon(Icons.calendar_today),
                        title: Text('Age'),
                        subtitle: Text('${_userProfile!.age} years'),
                      ),
                      ListTile(
                        leading: Icon(Icons.monitor_weight),
                        title: Text('Weight'),
                        subtitle: Text('${_userProfile!.weight} kg'),
                      ),
                      ListTile(
                        leading: Icon(Icons.height),
                        title: Text('Height'),
                        subtitle: Text('${_userProfile!.height} cm'),
                      ),
                      ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text('Gender'),
                        subtitle: Text(_userProfile!.gender.capitalize()),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: CustomButton(
                          label: 'Edit Profile',
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileScreen()),
                            );
                            _loadUserProfile(); // Reload profile when returning
                          },
                          icon: Icons.edit,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}