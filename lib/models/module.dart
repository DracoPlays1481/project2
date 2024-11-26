import 'package:flutter/material.dart';

// Model class representing a module with grade calculation functionality
class Module {
  final String moduleName;
  final double creditUnits;
  final TextEditingController gradeController;
  final TextEditingController gradeScaleController;
  final ValueNotifier<double> gradePointsNotifier;
  String _moduleGrade = '';

  // Getters for module properties
  double get gradePoints => gradePointsNotifier.value;
  String get moduleGrade => _moduleGrade;

  // Setter for module grade that triggers grade calculation
  set moduleGrade(String value) {
    _moduleGrade = value;
    updateGrade(value);
  }

  Module({
    required this.moduleName,
    required this.creditUnits,
  }) : gradeController = TextEditingController(),
        gradeScaleController = TextEditingController(),
        gradePointsNotifier = ValueNotifier(0.0);

  // Updates the grade and calculates grade points based on the input grade
  void updateGrade(String grade) {
    if (grade.isEmpty) return;

    final upperGrade = grade.toUpperCase();
    double scale = 0.0;
    _moduleGrade = upperGrade;

    // Convert letter grade to numerical scale
    switch (upperGrade) {
      case 'A':
        scale = 4.0;
        break;
      case 'B':
        scale = 3.0;
        break;
      case 'C':
        scale = 2.0;
        break;
      case 'D':
        scale = 1.0;
        break;
      case 'E':
        scale = 1.0;
        break;
      case 'F':
        scale = 0.0;
        break;
      default:
        return; // Invalid grade, don't update
    }

    // Update the grade scale display and calculate grade points
    gradeScaleController.text = scale.toStringAsFixed(1);
    gradePointsNotifier.value = scale * creditUnits;
  }

  // Clean up resources when the module is no longer needed
  void dispose() {
    gradeController.dispose();
    gradeScaleController.dispose();
    gradePointsNotifier.dispose();
  }
}