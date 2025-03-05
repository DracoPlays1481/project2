import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _databaseService = DatabaseService();

  Future<User?> createUserWithEmailAndPassword(String email, String password, {String? name}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Create initial profile if user is created successfully
      if (cred.user != null && name != null) {
        final initialProfile = UserProfile(
          uid: cred.user!.uid,
          name: name,
          age: 0,
          weight: 0.0,
          height: 0.0,
          gender: 'male',
        );

        await _databaseService.saveUserProfile(initialProfile);
      }

      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseAuthErrorMessage(e.code);
    } catch (e) {
      log("Unexpected error: $e");
      throw "An unexpected error occurred. Please try again.";
    }
  }

  Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Ensure user profile exists in database
      if (cred.user != null) {
        await _databaseService.getUserProfile(cred.user!.uid);
      }

      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseAuthErrorMessage(e.code);
    } catch (e) {
      log("Unexpected error: $e");
      throw "An unexpected error occurred. Please try again.";
    }
  }

  Future<void> signout() async {
    try {
      // Force token refresh before signing out to ensure clean state
      final user = _auth.currentUser;
      if (user != null) {
        try {
          await user.getIdToken(true); // Force refresh the token
        } catch (e) {
          log("Token refresh failed: $e");
          // Continue with signout even if token refresh fails
        }
      }

      await _auth.signOut();
      log("User signed out successfully");
    } catch (e) {
      log("Sign out failed: $e");
      throw "Failed to sign out. Please try again.";
    }
  }

  // Check if the current user session is valid
  Future<bool> isUserSessionValid() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Try to get a fresh token to verify the session is still valid
      await user.getIdToken(true);
      return true;
    } catch (e) {
      log("Session validation failed: $e");
      return false;
    }
  }

  String _getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case "invalid-credential":
        return "Your login credentials are invalid";
      case "wrong-password":
        return "The password does not match. Please try again.";
      case "invalid-email":
        return "The email address is not valid.";
      case "user-not-found":
        return "No user found with this email.";
      case "email-already-in-use":
        return "An account already exists with this email.";
      case "weak-password":
        return "Your password must be at least 6 characters";
      case "user-disabled":
        return "This user account has been disabled.";
      default:
        return "An unknown error occurred. Please try again.";
    }
  }
}