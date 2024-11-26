import 'package:flutter/material.dart';

// Widget that displays the list of current modules
class ModuleList extends StatelessWidget {
  final List<Map<String, dynamic>> modules;

  const ModuleList({
    super.key,
    required this.modules,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(module['name']),
            subtitle: Text('${module['credits']} Credit Units'),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(
                Icons.book,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}