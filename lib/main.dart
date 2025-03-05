import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'wrapper.dart';
import 'theme/app_theme.dart';
import 'services/database_service.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDwr0VjbAk4aefz2ee4rakwHyJ_eiktJaU",
            authDomain: "shawn-msdprj-food-diary.firebaseapp.com",
            databaseURL: "https://shawn-msdprj-food-diary-default-rtdb.asia-southeast1.firebasedatabase.app",
            projectId: "shawn-msdprj-food-diary",
            storageBucket: "shawn-msdprj-food-diary.firebasestorage.app",
            messagingSenderId: "1087627108607",
            appId: "1:1087627108607:web:2629a77a36139f77beacca",
            measurementId: "G-83PNWW6ENK"
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    // Initialize database service
    final databaseService = DatabaseService();

    // Check if data exists before initializing
    final hasExistingData = await databaseService.checkIfDataExists();
    if (!hasExistingData) {
      print('Initializing default data...');
      await databaseService.initializeDefaultFoodItems();
      await databaseService.initializeDefaultRecipes();
      print('Default data initialized successfully');
    } else {
      print('Data already exists, skipping initialization');
    }

    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Initialization error: $e');
    print('Stack trace: $stackTrace');
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Diary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        '/profile': (context) => const ProfileScreen(),
      },
      home: const Wrapper(),
      builder: (context, child) {
        // Apply iOS-style page transitions
        return CupertinoTheme(
          data: const CupertinoThemeData(
            primaryColor: AppTheme.primaryColor,
            brightness: Brightness.light,
            textTheme: CupertinoTextThemeData(
              primaryColor: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}