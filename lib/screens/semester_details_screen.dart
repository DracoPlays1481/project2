import 'package:flutter/material.dart';

class SemesterDetailsScreen extends StatelessWidget {
  final String semester;
  final double gpa;

  // Sample module data with your complete dataset
  final Map<String, List<Map<String, dynamic>>> semesterModules = {
    'APR 2023': [
      {
        'name': 'Fundamentals of Data',
        'grade': 'C',
        'credits': '3',
        'moduleClass': 'DE 33001FP',
        'session': '3-Month Term Jun Exam'
      },
      {
        'name': 'Introduction to UI/UX',
        'grade': 'B',
        'credits': '3',
        'moduleClass': 'IT 33002FP',
        'session': '3-Month Term Jun Exam'
      },
      {
        'name': 'Design Thinking',
        'grade': 'N/A',
        'credits': 'N/A',
        'moduleClass': 'LFS 89502X',
        'session': '3-Month Term Jun Exam'
      },
      {
        'name': 'Sports and Wellness 1',
        'grade': 'N/A',
        'credits': 'N/A',
        'moduleClass': 'SW 41081X',
        'session': '3-Month Term Jun Exam'
      },
      {
        'name': 'Software Development Practices',
        'grade': 'C',
        'credits': '3',
        'moduleClass': 'IT 43001FP',
        'session': '3-Month Term Sep Exam'
      },
      {
        'name': 'Programming Essentials',
        'grade': 'C',
        'credits': '3',
        'moduleClass': 'IT 43002FP',
        'session': '3-Month Term Sep Exam'
      },
      {
        'name': 'Data Visualisation for Business',
        'grade': 'C',
        'credits': '2',
        'moduleClass': 'IT 49431',
        'session': '3-Month Term Sep Exam'
      },
      {
        'name': 'Design Thinking',
        'grade': 'S',
        'credits': '2',
        'moduleClass': 'LFS 89502',
        'session': '3-Month Term Sep Exam'
      },
      {
        'name': 'Sports and Wellness 1',
        'grade': 'S',
        'credits': '1',
        'moduleClass': 'SW 41081',
        'session': '3-Month Term Sep Exam'
      },
    ],
    'OCT 2023': [
      {
        'name': 'Server-side Development',
        'grade': 'B',
        'credits': '3',
        'moduleClass': 'IT 43005FP',
        'session': '3-Month Term Mar Exam'
      },
      {
        'name': 'Website Optimisation Fundament',
        'grade': 'C',
        'credits': '3',
        'moduleClass': 'IT 43007FP',
        'session': '3-Month Term Mar Exam'
      },
      {
        'name': 'Innovation and Enterprise',
        'grade': 'S',
        'credits': '2',
        'moduleClass': 'LFS 89509',
        'session': '3-Month Term Mar Exam'
      },
      {
        'name': 'Service Excellence in Tech Support',
        'grade': 'C',
        'credits': '3',
        'moduleClass': 'SN 48010',
        'session': '3-Month Term Mar Exam'
      },
      {
        'name': 'Sports and Wellness 2',
        'grade': 'S',
        'credits': '1',
        'moduleClass': 'SW 41082',
        'session': '3-Month Term Mar Exam'
      },
      {
        'name': 'Sustainability Basecamp',
        'grade': 'N/A',
        'credits': 'N/A',
        'moduleClass': 'BS 2900SUBC',
        'session': '3-Month Term Dec Exam'
      },
      {
        'name': 'User Experience Development',
        'grade': 'C',
        'credits': '3',
        'moduleClass': 'IT 43003FP',
        'session': '3-Month Term Dec Exam'
      },
      {
        'name': 'Front-end Web Development',
        'grade': 'B',
        'credits': '3',
        'moduleClass': 'IT 43004FP',
        'session': '3-Month Term Dec Exam'
      },
      {
        'name': 'Web Content Management',
        'grade': 'C',
        'credits': '3',
        'moduleClass': 'IT 43006FP',
        'session': '3-Month Term Dec Exam'
      },
      {
        'name': 'Innovation & Enterprise',
        'grade': 'N/A',
        'credits': 'N/A',
        'moduleClass': 'LFS 89509X',
        'session': '3-Month Term Dec Exam'
      },
      {
        'name': 'Sports and Wellness 2',
        'grade': 'N/A',
        'credits': 'N/A',
        'moduleClass': 'SW 41082X',
        'session': '3-Month Term Dec Exam'
      },
    ],
    'APR 2024': [
      {
        'name': 'Industry Attachment',
        'grade': 'N/A',
        'credits': 'N/A',
        'moduleClass': 'IT 53006FPEX',
        'session': '3 Month Jun Exam'
      },
      {
        'name': 'Industry Attachment',
        'grade': 'C',
        'credits': '8',
        'moduleClass': 'IT 53006FPEX',
        'session': '3 Month SEP Exam'
      },
    ],
  };

  SemesterDetailsScreen({
    super.key,
    required this.semester,
    required this.gpa,
  });

  @override
  Widget build(BuildContext context) {
    final modules = semesterModules[semester] ?? [];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(semester),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.primary.withOpacity(0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GPA: ${gpa.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (module['moduleClass'] != null)
                          Text(
                            'Module Class: ${module['moduleClass']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                            ),
                          ),
                        if (module['session'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Session: ${module['session']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Credits: ${module['credits']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? theme.colorScheme.primary.withOpacity(0.2)
                                    : theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Grade: ${module['grade']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}