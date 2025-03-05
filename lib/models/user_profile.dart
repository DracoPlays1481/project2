import 'package:firebase_database/firebase_database.dart';

class UserProfile {
  final String uid;
  final String name;
  final int age;
  final double weight;
  final double height;
  final String gender;

  UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      age: (json['age'] is int) ? json['age'] : int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      weight: (json['weight'] is double)
          ? json['weight']
          : (json['weight'] is int)
          ? (json['weight'] as int).toDouble()
          : double.tryParse(json['weight']?.toString() ?? '0') ?? 0.0,
      height: (json['height'] is double)
          ? json['height']
          : (json['height'] is int)
          ? (json['height'] as int).toDouble()
          : double.tryParse(json['height']?.toString() ?? '0') ?? 0.0,
      gender: json['gender'] ?? 'male',
    );
  }

  double calculateBMI() {
    if (height <= 0 || weight <= 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  String getBMICategory() {
    double bmi = calculateBMI();
    if (bmi <= 0) return 'Unknown';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Mifflin-St Jeor Equation
  double calculateBasalMetabolicRate() {
    if (weight <= 0 || height <= 0 || age <= 0) return 0;

    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    if (gender.toLowerCase() == 'male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    return bmr;
  }

  double calculateDailyCalorieNeeds(String activityLevel) {
    double bmr = calculateBasalMetabolicRate();
    if (bmr <= 0) return 0;

    // Activity Multipliers based on calculator.net
    switch (activityLevel) {
      case 'sedentary':
        return bmr * 1.2; // Little or no exercise
      case 'light':
        return bmr * 1.375; // Light exercise/sports 1-3 days/week
      case 'moderate':
        return bmr * 1.55; // Moderate exercise/sports 3-5 days/week
      case 'active':
        return bmr * 1.725; // Hard exercise/sports 6-7 days/week
      case 'very_active':
        return bmr * 1.9; // Very hard exercise/sports & physical job or training
      default:
        return bmr * 1.2;
    }
  }
}