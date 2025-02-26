import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/textfield.dart';
import '../widgets/button.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({Key? key}) : super(key: key);

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  double? _bmi;
  String _bmiCategory = '';
  final _databaseService = DatabaseService();

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
          _weightController.text = profile.weight.toString();
          _heightController.text = profile.height.toString();
        });
      }
    }
  }

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid weight and height')),
      );
      return;
    }

    final bmi = weight / ((height / 100) * (height / 100));
    String category;
    if (bmi < 18.5) {
      category = 'Underweight';
    } else if (bmi < 25) {
      category = 'Normal';
    } else if (bmi < 30) {
      category = 'Overweight';
    } else {
      category = 'Obese';
    }

    setState(() {
      _bmi = bmi;
      _bmiCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              child: Column(
                children: [
                  Text(
                    'Calculate Your BMI',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _weightController,
                    label: 'Weight',
                    hint: 'Enter weight in kg',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.monitor_weight,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _heightController,
                    label: 'Height',
                    hint: 'Enter height in cm',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.height,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: 'Calculate BMI',
                    onPressed: _calculateBMI,
                    icon: Icons.calculate,
                  ),
                ],
              ),
            ),
            if (_bmi != null) ...[
              const SizedBox(height: 20),
              CustomCard(
                child: Column(
                  children: [
                    Text(
                      'Your BMI Results',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BMI: ${_bmi!.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: $_bmiCategory',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getBMIAdvice(),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
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

  String _getBMIAdvice() {
    if (_bmi == null) return '';
    if (_bmi! < 18.5) {
      return 'You are underweight. Consider consulting a healthcare provider about a balanced diet to gain weight safely.';
    } else if (_bmi! < 25) {
      return 'You have a healthy weight. Keep maintaining a balanced diet and regular exercise routine.';
    } else if (_bmi! < 30) {
      return 'You are overweight. Consider increasing physical activity and maintaining a balanced diet.';
    } else {
      return 'You are in the obese category. It\'s recommended to consult a healthcare provider for personalized advice.';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}