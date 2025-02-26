import 'package:flutter/material.dart';
import 'auth/auth_service.dart';
import 'widgets/button.dart';
import 'display_item.dart';
import 'add_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome User",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: "Food Diary",
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisplayItem()),
                );
                //goToLogin(context);
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: "Meal Entries",
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItem()),
                );
                //goToLogin(context);
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: "Sign Out",
              onPressed: () async {
                await auth.signout();
                //goToLogin(context);
              },
            )
          ],
        ),
      ),
    );
  }

  // goToLogin(BuildContext context) => Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) => const LoginScreen()),
  // );
}


