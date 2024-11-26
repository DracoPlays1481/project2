import 'package:flutter/material.dart';
import 'semester_details_screen.dart';

class PastResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> gpaData;

  const PastResultsScreen({
    super.key,
    required this.gpaData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Results'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: gpaData.length,
        itemBuilder: (context, index) {
          final result = gpaData[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SemesterDetailsScreen(
                      semester: result['semester'],
                      gpa: result['gpa'],
                    ),
                  ),
                );
              },
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  'Semester: ${result['semester']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'GPA: ${result['gpa'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}