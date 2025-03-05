import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';
import 'auth/auth_service.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final _authService = AuthService();
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    setState(() {
      _isCheckingSession = true;
    });

    try {
      // Verify if the current session is valid
      final isValid = await _authService.isUserSessionValid();
      if (!isValid) {
        // If session is invalid, sign out to clean up
        await _authService.signout();
      }
    } catch (e) {
      // On error, default to signed out state
      print('Session check error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingSession = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CupertinoActivityIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              if (snapshot.data == null) {
                return LoginScreen();
              } else {
                return HomeScreen();
              }
            }
          }
      ),
    );
  }
}