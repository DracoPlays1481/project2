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
      age: json['age'] ?? 0,
      weight: json['weight'] ?? 0.0,
      height: json['height'] ?? 0.0,
      gender: json['gender'] ?? '',
    );
  }

  double calculateBMI() {
    return weight / ((height / 100) * (height / 100));
  }

  String getBMICategory() {
    double bmi = calculateBMI();
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  double calculateDailyCalorieNeeds() {
    // Basic BMR calculation using Harris-Benedict equation
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
    return bmr * 1.2; // Assuming sedentary lifestyle
  }
}