import 'package:flutter/material.dart';

// Widget that displays the GPA legend below the chart
class GPALegend extends StatelessWidget {
  final List<Map<String, dynamic>> gpaData;

  const GPALegend({
    super.key,
    required this.gpaData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: List.generate(
        gpaData.length,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${gpaData[index]['semester']}: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'GPA ${(gpaData[index]['gpa'] as num).toStringAsFixed(2)}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}