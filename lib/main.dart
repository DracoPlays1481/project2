import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'wrapper.dart';

void main() async{

WidgetsFlutterBinding.ensureInitialized() ;

if(kIsWeb){
await Firebase.initializeApp(options: FirebaseOptions(
    apiKey: "AIzaSyDwr0VjbAk4aefz2ee4rakwHyJ_eiktJaU",
    authDomain: "shawn-msdprj-food-diary.firebaseapp.com",
    databaseURL: "https://shawn-msdprj-food-diary-default-rtdb.asia-southeast1.firebasedatabase.app",
    projectId: "shawn-msdprj-food-diary",
    storageBucket: "shawn-msdprj-food-diary.firebasestorage.app",
    messagingSenderId: "1087627108607",
    appId: "1:1087627108607:web:2629a77a36139f77beacca",
    measurementId: "G-83PNWW6ENK"
));
}else{
  await Firebase.initializeApp();
}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: Wrapper());
  }
}
