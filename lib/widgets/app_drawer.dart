import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/profile_screen.dart';
import '../screens/gpa_screen.dart';
import '../screens/login_screen.dart';
import '../providers/theme_provider.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String className;
  final String indexNumber;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.className,
    required this.indexNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            accountName: Text(
              userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(
              className,
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 50,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userName: userName,
                    className: className,
                    indexNumber: indexNumber,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('GPA Calculator'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const GPAScreen(userName: 'Shawn', className: 'CQ2304W', indexNumber: '08',),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            title: Text(themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode'),
            onTap: () {
              themeProvider.toggleTheme();
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}