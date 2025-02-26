import 'package:firebase_analytics/firebase_analytics.dart';
class AnalyticsService {
  final _instance = FirebaseAnalytics.instance;
  Future<void> logLoginScreen() async {
    await _instance.logLogin(loginMethod: 'email');
  }
}