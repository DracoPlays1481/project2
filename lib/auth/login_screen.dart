import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'signup_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:food_diary_09_irrwanshawn/analytics_service.dart';

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
              onPressed: _login,
              child: Text("Login"),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () => Navigator.push(
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

    try {
      await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);

      await analyticsService.logLoginScreen();

      FirebaseAnalytics.instance.logEvent(name: 'login');
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    }
  }
}
