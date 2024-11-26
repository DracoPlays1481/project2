import 'package:flutter/material.dart';
import '../models/module.dart';
import '../data/module_data.dart';
import '../widgets/module_card.dart';
import '../widgets/app_drawer.dart';
import 'profile_screen.dart';

class GPAScreen extends StatefulWidget {
  final String userName;
  final String className;
  final String indexNumber;

  const GPAScreen({
    super.key,
    required this.userName,
    required this.className,
    required this.indexNumber,
  });

  @override
  State<GPAScreen> createState() => _GPAScreenState();
}

class _GPAScreenState extends State<GPAScreen> {
  double _gpa = 0.0;
  List<Module> _modules = [];
  Map<String, dynamic>? _selectedModule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userName: widget.userName,
                  className: widget.className,
                  indexNumber: widget.indexNumber,
                ),
              ),
            );
          },
        ),
        title: const Text('GPA Calculator'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedModule,
                  hint: Text("Select a Module",
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                  dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? Colors.grey[850] : Colors.white,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: moduleList
                      .map((module) => DropdownMenuItem<Map<String, dynamic>>(
                    value: module,
                    child: Text(
                      '${module["name"]} (${module["credits"]} CU)',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ))
                      .toList(),
                  onChanged: (selectedModule) {
                    setState(() => _selectedModule = selectedModule);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedModule != null) {
                        _addModule(_selectedModule!);
                      } else {
                        _showSnackBar('Please select a module first.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Add Module", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _modules.isEmpty
                ? Center(
              child: Text(
                'No modules added yet',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white60 : Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _modules.length,
              itemBuilder: (context, index) {
                return ModuleCard(
                  module: _modules[index],
                  onGradeChanged: (value) {
                    // Grade change handler removed for manual calculation
                  },
                  onDelete: () => _removeModuleAt(index),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _updateGPA,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Calculate GPA",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _gpa == 0.0 ? "GPA: -" : "GPA: ${_gpa.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addModule(Map<String, dynamic> selectedModule) {
    if (_modules.any((module) => module.moduleName == selectedModule["name"])) {
      _showSnackBar('This module has already been added.');
      return;
    }

    setState(() {
      _modules.add(
        Module(
          moduleName: selectedModule["name"],
          creditUnits: selectedModule["credits"].toDouble(),
        ),
      );
    });
  }

  void _removeModuleAt(int index) {
    setState(() {
      _modules.removeAt(index);
    });
  }

  void _updateGPA() {
    double totalGradePoints = 0.0;
    double totalCredits = 0.0;

    for (var module in _modules) {
      totalGradePoints += module.gradePoints;
      totalCredits += module.creditUnits;
    }

    setState(() {
      _gpa = totalCredits == 0.0 ? 0.0 : totalGradePoints / totalCredits;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}