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
  double? _bmr;
  String _activityLevel = 'sedentary';
  bool _isLoading = true;
  String? _errorMessage;

  final Map<String, String> _activityLevels = {
    'sedentary': 'Sedentary (little or no exercise)',
    'light': 'Light exercise 1-3 days/week',
    'moderate': 'Moderate exercise 3-5 days/week',
    'active': 'Hard exercise 6-7 days/week',
    'very_active': 'Very hard exercise & physical job',
  };

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

    setState(() {
      _bmr = _userProfile!.calculateBasalMetabolicRate();
      _dailyCalories = _userProfile!.calculateDailyCalorieNeeds(_activityLevel);
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
                        ).then((_) => _loadUserProfile());
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
                        ).then((_) => _loadUserProfile());
                      },
                      icon: Icons.person,
                    ),
                  ],
                ),
              )
            else ...[
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Level',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _activityLevel,
                            isExpanded: true,
                            items: _activityLevels.entries.map((entry) {
                              return DropdownMenuItem(
                                value: entry.key,
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _activityLevel = value;
                                });
                                _calculateCalories();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                if (_bmr != null && _dailyCalories != null) ...[
                  const SizedBox(height: 20),
                  CustomCard(
                    child: Column(
                      children: [
                        Text(
                          'Your Results',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(
                            'Basal Metabolic Rate (BMR)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            '${_bmr!.round()} calories/day',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(
                            'Daily Calorie Needs',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            '${_dailyCalories!.round()} calories/day',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Weight Goals',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          title: const Text('Weight Loss'),
                          subtitle: Text(
                            '${(_dailyCalories! - 500).round()} calories/day',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: const Text('-0.5 kg/week'),
                        ),
                        ListTile(
                          title: const Text('Weight Gain'),
                          subtitle: Text(
                            '${(_dailyCalories! + 500).round()} calories/day',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: const Text('+0.5 kg/week'),
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
                            _loadUserProfile();
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