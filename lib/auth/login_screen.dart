import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'signup_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:food_diary_09_irrwanshawn/analytics_service.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              "Login",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 50),
            TextField(
              controller: _email,
              decoration: InputDecoration(
                hintText: "Enter Email",
                labelText: "Email",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter Password",
                labelText: "Password",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  )
              )
                  : Text("Login"),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  ),
                  child: const Text("Signup", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    final analyticsService = AnalyticsService();
    if (_email.text.isEmpty || _password.text.isEmpty) {
      setState(() {
        errorMessage = "Please enter both email and password.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);
      await analyticsService.logLoginScreen();
      await FirebaseAnalytics.instance.logEvent(name: 'login');

      // Navigate to home screen on successful login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}