import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/module.dart';

class ModuleCard extends StatelessWidget {
  final Module module;
  final Function(String) onGradeChanged;
  final VoidCallback onDelete;

  const ModuleCard({
    super.key,
    required this.module,
    required this.onGradeChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: isDark ? theme.cardColor : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    module.moduleName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credit Units: ${module.creditUnits}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Grade Attained: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: module.gradeController,
                              textCapitalization: TextCapitalization.characters,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                                LengthLimitingTextInputFormatter(1),
                              ],
                              decoration: InputDecoration(
                                hintText: 'A-F',
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDark ? Colors.white24 : Colors.black12,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final upperValue = value.toUpperCase();
                                  module.gradeController.text = upperValue;
                                  module.gradeController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: upperValue.length),
                                  );
                                  module.updateGrade(upperValue);
                                  onGradeChanged(upperValue);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ValueListenableBuilder<double>(
                        valueListenable: module.gradePointsNotifier,
                        builder: (context, gradePoints, _) {
                          return Text(
                            'Grade Points: ${gradePoints.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: module.gradeScaleController,
                    readOnly: true,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Grade Scale',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}