import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/textfield.dart';
import '../widgets/button.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGender = 'male';
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();
  bool _isLoading = true;
  bool _isSaving = false;
  UserProfile? _userProfile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Loading profile for user: ${user.uid}');
        final profile = await _databaseService.getUserProfile(user.uid);

        if (profile != null) {
          setState(() {
            _userProfile = profile;
            _nameController.text = profile.name;
            _ageController.text = profile.age > 0 ? profile.age.toString() : '';
            _weightController.text = profile.weight > 0 ? profile.weight.toString() : '';
            _heightController.text = profile.height > 0 ? profile.height.toString() : '';
            _selectedGender = profile.gender.toLowerCase();
            print('Profile loaded successfully: ${profile.name}, Age: ${profile.age}, Weight: ${profile.weight}, Height: ${profile.height}');
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to load profile data';
          });
          print('Profile is null after loading');
        }
      } else {
        setState(() {
          _errorMessage = 'User not logged in';
        });
        print('Current user is null');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
      });
      print('Error in _loadProfile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Parse values safely
        final age = int.tryParse(_ageController.text) ?? 0;
        final weight = double.tryParse(_weightController.text) ?? 0.0;
        final height = double.tryParse(_heightController.text) ?? 0.0;

        final profile = UserProfile(
          uid: user.uid,
          name: _nameController.text,
          age: age,
          weight: weight,
          height: height,
          gender: _selectedGender,
        );

        print('Saving profile: ${profile.toJson()}');
        await _databaseService.saveUserProfile(profile);

        setState(() {
          _userProfile = profile;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
      } else {
        setState(() {
          _errorMessage = 'User not logged in';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to save your profile')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving profile: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
      print('Error in _saveProfile: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Save profile data before navigating back
        if (_formKey.currentState!.validate()) {
          await _saveProfile();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              // Save profile data before navigating back
              if (_formKey.currentState!.validate()) {
                await _saveProfile();
              }
              Navigator.of(context).pop();
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Name',
                        hint: 'Enter your name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _ageController,
                        label: 'Age',
                        hint: 'Enter your age',
                        prefixIcon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your age';
                          }
                          final age = int.tryParse(value!);
                          if (age == null || age < 0 || age > 120) {
                            return 'Please enter a valid age';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Female'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedGender = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Body Measurements',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _weightController,
                        label: 'Weight (kg)',
                        hint: 'Enter your weight',
                        prefixIcon: Icons.monitor_weight,
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your weight';
                          }
                          final weight = double.tryParse(value!);
                          if (weight == null || weight <= 0 || weight > 300) {
                            return 'Please enter a valid weight';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _heightController,
                        label: 'Height (cm)',
                        hint: 'Enter your height',
                        prefixIcon: Icons.height,
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your height';
                          }
                          final height = double.tryParse(value!);
                          if (height == null || height <= 0 || height > 300) {
                            return 'Please enter a valid height';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: "Save Profile",
                  onPressed: _saveProfile,
                  isLoading: _isSaving,
                  icon: Icons.save,
                ),
                if (_userProfile != null && _userProfile!.height > 0 && _userProfile!.weight > 0) ...[
                  const SizedBox(height: 20),
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Stats',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'BMI: ${_userProfile!.calculateBMI().toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Category: ${_userProfile!.getBMICategory()}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Daily Calorie Needs: ${_userProfile!.calculateDailyCalorieNeeds().toStringAsFixed(0)} kcal',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}