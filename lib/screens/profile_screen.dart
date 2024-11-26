import 'package:flutter/material.dart';
import '../data/module_data.dart';
import '../widgets/app_drawer.dart';
import '../widgets/profile_header.dart';
import '../widgets/gpa_chart.dart';
import '../widgets/gpa_legend.dart';
import '../widgets/module_list.dart';
import 'past_results_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String className;
  final String indexNumber;

  static final List<Map<String, dynamic>> gpaData = [
    {'semester': 'APR 2023', 'gpa': 2.50},
    {'semester': 'OCT 2023', 'gpa': 2.33},
    {'semester': 'APR 2024', 'gpa': 2.00},
  ];

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.className,
    required this.indexNumber,
  });
@override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
    final filteredModules = moduleList.where((module) =>
    module['name'] == 'Enterprise Web Development' ||
        module['name'] == 'Mobile Apps Development'
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      drawer: AppDrawer(
        userName: userName,
        className: className,
        indexNumber: indexNumber,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              userName: userName,
              className: className,
              indexNumber: indexNumber,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'GPA Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GPAChart(gpaData: gpaData),
                  const SizedBox(height: 24),
                  GPALegend(gpaData: gpaData),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PastResultsScreen(gpaData: gpaData),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Past Results',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Current Modules',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ModuleList(modules: filteredModules),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}